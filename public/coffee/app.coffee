app = angular.module('charts', ['charts-projects', 'angular-ladda'])

app.constant('jQuery', window.jQuery)
app.constant('lodash', window._)
app.constant('moment', window.moment)

app.factory 'Api', ['$http', '$window', ($http, $window) ->
  basePath: 'http://localhost:3000/api'
  key: ''

  _request: (method, path, params = {}) ->
    _.assign params,
      key: @key

    $http
      url: "#{ @basePath }/#{ path }.json"
      params: params
      method: method
    .then (data) ->
      data: data.data[path]
      count: data.data.total_count

  get: (path, params) ->
    @_request('get', path, params)
]

app.controller 'ChartsController', [
  '$q', 'jQuery', 'lodash', 'moment', 'Api',
, ($q, $, _, moment, Api) ->
  @site = 'http://redmine.pfrus.com'
  @key = '261e9890fc1b2aa799f942ff2d6daa9fa691bd91'
  @projects = []
  @statuses = []
  @projectsCount = undefined
  @currentProject = undefined
  @signinLoading = false
  @perMonthLoading = false

  @getUser = =>
    @getProjects()
    # @site = $('#site-url').val().trim()
    # @key = $('#api-key').val().trim()
    # Api.key = @key
    # Api.get('users/current')
      # .then (user) =>
        # return unless user?
        # @getProjects()

  @getProjects = =>
    @signinLoading = true
    Api.key = @key
    Api.get('projects', limit: 100)
      .then (projects) =>
        @projects = projects.data
        @projectsCount = projects.count
        @signinLoading = false

  @setSelectedProject = (project) =>
    @currentProject = project
    $('#datepicker').datepicker
      format: 'M/yy'
      minViewMode: 1
    startDate = moment(project.created_on).toDate()
    endDate = moment().toDate()
    $('#start-date').data('datepicker').setDate(moment().startOf('year').toDate())
    $('#start-date').data('datepicker').setStartDate(startDate)
    $('#start-date').data('datepicker').setEndDate(endDate)
    $('#end-date').data('datepicker').setDate(moment().toDate())
    $('#end-date').data('datepicker').setStartDate(startDate)
    $('#end-date').data('datepicker').setEndDate(endDate)
    @getIssueStatuses(project)
    @getTodayIssues(project)
    @getIssuesPerMonth(project)
    @getIssuesByUser(project)

  @isSelectedProject = (project) ->
    @currentProject?.id == project.id

  @getIssueStatuses = (project) =>
    Api.key = @key
    Api.get('issue_statuses')
      .then (issueStatuses) =>
        @statuses = issueStatuses.data
        $q.all @statuses.map (status) =>
          @getIssuesByStatus(project, status)
      .then (issuesbyStatuses) ->
        project.issuesbyStatuses = issuesbyStatuses
        project.issuesOverallCount = _(issuesbyStatuses)
          .pluck('1')
          .reduce (a, b) -> a + b
        $chart = $('#issues-overall')
        $chart.highcharts
          chart:
            plotBackgroundColor: null
            plotBorderWidth: null
            plotShadow: false
          title:
            text: null
          tooltip:
            pointFormat: "Status share: <b>{point.percentage:.1f}%</b>"
          plotOptions:
            pie:
              allowPointSelect: true
              cursor: 'pointer'
              dataLabels:
                enabled: true
                format: "<b>{point.name}</b>: {point.percentage:.1f} %"
              showInLegend: true
          series: [
            type: 'pie'
            name: 'Issues share'
            data: issuesbyStatuses
          ]
        chart = $chart.highcharts()

  @getIssuesByStatus = (project, status) =>
    Api.key = @key
    Api.get('issues', project_id: project.id, status_id: status.id, limit: 1)
      .then (issuesByStatus) -> [
        "#{ status.name } (#{ issuesByStatus.count })"
        issuesByStatus.count
      ]

  @getTodayIssues = (project) =>
    today = moment().format('YYYY-MM-DD')
    Api.key = @key
    $q.all([
      Api.get('issues', project_id: project.id, limit: 1, status_id: '*', created_on: today)
      Api.get('issues', project_id: project.id, limit: 1, status_id: 'closed', updated_on: today)
    ]).then ([todayIssuesCreated, todayIssuesClosed]) ->
      project.todayIssuesLoaded = true
      project.todayIssuesCount = todayIssuesCreated.count + todayIssuesClosed.count
      $chart = $('#issues-today')
      $chart.highcharts
        chart:
          type: 'column'
        title:
          text: null
        xAxis:
          categories: [
            "Today Issues (#{ project.todayIssuesCount })"
          ]
        yAxis: [
          min: 0
          title:
            text: 'Issues count'
        ]
        legend:
          shadow: false
        tooltip:
          shared: true
        plotOptions:
          column:
            shadow: false
            borderWidth: 0
            dataLabels:
              enabled: true
        series: [
          name: 'Created'
          color: 'rgba(165,170,217,1)'
          data: [todayIssuesCreated.count]
        ,
          name: 'Closed'
          color: 'rgba(153,214,13,.9)'
          data: [todayIssuesClosed.count]
        ]
      chart = $chart.highcharts()

  @getIssuesPerMonth = (project) =>
    @perMonthLoading = true
    startDateValue = $('#start-date').data('datepicker').getDate()
    endDateValue = $('#end-date').data('datepicker').getDate()
    startDate = if startDateValue then moment(startDateValue) else moment().startOf('year')
    endDate = if endDateValue then moment(endDateValue).endOf('month') else moment()
    range = moment().range(startDate, endDate)
    dateRanges = []
    range.by 'months', (start) ->
      end = moment.min(start.clone().endOf('month'), endDate)
      dateRanges.push
        start: start.format('YYYY-MM-DD')
        end: end.format('YYYY-MM-DD')
        monthName: start.format('MMM') + '/' + start.format('YY')

    $q.all dateRanges.map ({start, end}) ->
      q = "><#{ start }|#{ end }"
      $q.all [
        Api.get('issues', project_id: project.id, limit: 1, status_id: '*', created_on: q)
        Api.get('issues', project_id: project.id, limit: 1, status_id: 'closed', updated_on: q)
      ]
    .then (issuesPerMonth) =>
      return unless issuesPerMonth.length
      series = [
        name: 'Created Issues'
        data: _(issuesPerMonth).pluck('0').pluck('count').value()
      ,
        name: 'Closed Issues'
        data: _(issuesPerMonth).pluck('1').pluck('count').value()
      ]

      $chart = $('#issues-per-month')
      $chart.highcharts
        chart:
          type: 'column'
        title:
          text: null
        xAxis:
          categories: _.pluck(dateRanges, 'monthName')
        yAxis: [
          min: 0
          title:
            text: 'Issues count'
        ]
        plotOptions:
          pointPadding: 0.2
          borderWidth: 0
          dataLabels:
            enabled: true
        series: series
      chart = $chart.highcharts()
      @perMonthLoading = false
      project.perMonthIssuesLoaded = true

  @getIssuesByUser = (project) =>
    startDate = moment(project.created_on)
    endDate = moment()
    range = moment().range(startDate, endDate)
    dateRanges = []
    range.by 'weeks', (start) ->
      end = moment.min(start.clone().endOf('week'), endDate)
      dateRanges.push
        start: start.format('YYYY-MM-DD')
        end: end.format('YYYY-MM-DD')
        weekName: start.format('YYYY-MM-DD')  + '—' + end.format('YYYY-MM-DD')
    $q.all dateRanges.map ({start, end}) ->
      q = "><#{ start }|#{ end }"
      $q.all [
        Api.get('issues', project_id: project.id, limit: 1, status_id: 'open', assigned_to_id: 'me', created_on: q)
        Api.get('issues', project_id: project.id, limit: 1, status_id: 'closed', assigned_to_id: 'me', updated_on: q)
      ]
    .then (issuesByUserPerWeek) =>
      return unless issuesByUserPerWeek.length
      series = [
        name: 'Open Issues'
        data: _(issuesByUserPerWeek).pluck('0').pluck('count').value()
      ,
        name: 'Closed Issues'
        data: _(issuesByUserPerWeek).pluck('1').pluck('count').value()
      ]

      $chart = $('#my-issues')
      $chart.highcharts
        chart:
          type: 'area'
          zoomType: 'x'
          panning: true,
          panKey: 'shift'
        title:
          text: null
        xAxis:
          categories: _.pluck(dateRanges, 'weekName')
          tickmarkPlacement: 'on'
          title:
            enabled: false
          labels:
            enabled: false
        yAxis:
          title:
            text: 'Issues count'
        tooltip:
          shared: true,
        legend:
          enabled: true
        plotOptions:
          area:
            stacking: 'normal'
            lineColor: '#ffffff'
            lineWidth: 1
            marker:
              enabled: false
          dataLabels:
            enabled: true
          showInLegend: true
        series: series
      chart = $chart.highcharts()
      project.byUserIssuesLoaded = true
]
