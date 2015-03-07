app = angular.module('charts', ['charts-projects', 'angular-ladda', 'LocalStorageModule'])

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
      data: data.data[path] ? data.data
      count: data.data.total_count

  get: (path, params) ->
    @_request('get', path, params)
]

app.controller 'ChartsController', [
  '$q', 'jQuery', 'lodash', 'moment', 'Api', 'localStorageService'
, ($q, $, _, moment, Api, localStorageService) ->
  @projects = []
  @statuses = []
  @key = undefined
  @projectsCount = undefined
  @currentProject = undefined
  @currentUser = undefined
  @signinLoading = false
  @errorLogin = false
  @errorProjectsInfo = false
  @errorDefaultProjectInfo = false
  @errorGeneralInfo = false
  @errorOverallIssues = false
  @errorPerMonthIssues = false
  @errorTodayIssues = false
  @errorMyProgress = false

  @login = ->
    @key = localStorageService.get('api-key')
    if @key
      @getUser(@key)

  @logout = ->
    localStorageService.remove('api-key')
    @currentProject = undefined
    @projects = []

  @setDefaultProject = () ->
    localStorageService.set('default-project', @currentProject.id)

  @isDefaultProject = () ->
    @currentProject?.id == localStorageService.get('default-project')

  @getUser = (@cachedKey) =>
    if !@cachedKey
      @key = $('#api-key').val().trim()
    Api.key = @key
    isRemembered = $('#remember-me').prop('checked')
    Api.get('users/current')
      .then (user) =>
        return unless user?
        if isRemembered
          localStorageService.set('api-key', @key)
        @currentUser = user.data.user
        @getProjects()
      .catch (error) =>
        @errorLogin = true

  @getProjects = =>
    @signinLoading = true
    Api.key = @key
    Api.get('projects', limit: 100)
      .then (projects) =>
        @projects = projects.data
        @projectsCount = projects.count
        @signinLoading = false
        if localStorageService.get('default-project')
          defaultProject = _.find(
            @projects, 'id': localStorageService.get('default-project'))
          @errorDefaultProjectInfo = false
          @setSelectedProject(defaultProject)
      .catch (error) =>
        @errorProjectsInfo = true
        @errorGeneralInfo = true

  @setSelectedProject = (project) =>
    if !project
      @errorDefaultProjectInfo = true
      return
    @errorGeneralInfo = false
    @errorOverallIssues = false
    @errorPerMonthIssues = false
    @errorTodayIssues = false
    @errorMyProgress = false
    @currentProject = project
    $('#datepicker').daterangepicker
      format: 'MMM/YY'
      startDate: moment.max(moment().startOf('year'), moment(project.created_on)).toDate()
      endDate: moment().toDate()
      minDate: moment(project.created_on).toDate()
      maxDate: moment().toDate()
      showDropdowns: true
      ranges:
        'Last 3 Months': [moment().subtract('month', 3).startOf('month'), moment().endOf('month')]
        'Last 6 Months': [moment().subtract('month', 6).startOf('month'), moment().endOf('month')]
        'Last Year': [moment().subtract('month', 12).startOf('month'), moment().endOf('month')]
    , (start, end) =>
      @getIssuesPerMonth(project)
    $('#datepicker').val(moment().startOf('year').format('MMM/YY') + ' - ' + moment().format('MMM/YY'))

    $('#datepicker-user').daterangepicker
      format: 'MMM/YY'
      startDate: moment.max(moment().startOf('year'), moment(project.created_on)).toDate()
      endDate: moment().toDate()
      minDate: moment(project.created_on).toDate()
      maxDate: moment().toDate()
      showDropdowns: true
      ranges:
        'Last 3 Months': [moment().subtract('month', 3).startOf('month'), moment().endOf('month')]
        'Last 6 Months': [moment().subtract('month', 6).startOf('month'), moment().endOf('month')]
        'Last Year': [moment().subtract('month', 12).startOf('month'), moment().endOf('month')]
    , (start, end) =>
      @getIssuesByUser(project)
    $('#datepicker-user').val(moment().startOf('year').format('MMM/YY') + ' - ' + moment().format('MMM/YY'))

    @getIssueStatuses(project)
    @getIssuesPerMonth(project)
    @getTodayIssues(project)
    @getIssuesByUser(project)

  @isSelectedProject = (project) ->
    @currentProject?.id == project.id

  @getIssueStatuses = (project) =>
    project.overallIssuesLoaded = false
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
        project.overallIssuesLoaded = true
      .catch (error) =>
        @errorOverallIssues = true

  @getIssuesByStatus = (project, status) =>
    Api.key = @key
    Api.get('issues', project_id: project.id, status_id: status.id, limit: 1)
      .then (issuesByStatus) -> [
        "#{ status.name } (#{ issuesByStatus.count })"
        issuesByStatus.count
      ]

  @getIssuesPerMonth = (project) ->
    project.perMonthIssuesLoaded = false
    startDate = $('#datepicker').data().daterangepicker.startDate ? moment().startOf('year')
    endDate = $('#datepicker').data().daterangepicker.endDate ? moment()
    range = moment().range(startDate.startOf('month'), endDate)
    dateRanges = []
    range.by 'months', (start) ->
      end = start.clone().endOf('month')
      dateRanges.push
        start: start.clone().startOf('month').format('YYYY-MM-DD')
        end: end.format('YYYY-MM-DD')
        monthName: start.format('MMM') + '/' + start.format('YY')

    $q.all dateRanges.map ({start, end}) ->
      q = "><#{ start }|#{ end }"
      $q.all [
        Api.get('issues', project_id: project.id, limit: 1, status_id: '*', created_on: q)
        Api.get('issues', project_id: project.id, limit: 1, status_id: 'closed', closed_on: q)
      ]
    .then (issuesPerMonth) ->
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
      project.perMonthIssuesLoaded = true
    .catch (error) =>
      @errorPerMonthIssues = true

  @getTodayIssues = (project) =>
    today = moment().format('YYYY-MM-DD')
    Api.key = @key
    $q.all([
      Api.get('issues', project_id: project.id, limit: 1, status_id: '*', created_on: today)
      Api.get('issues', project_id: project.id, limit: 1, status_id: 'closed', closed_on: today)
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
    .catch (error) =>
        @errorTodayIssues = true

  @getIssuesByUser = (project) ->
    project.byUserIssuesLoaded = false
    startDate = $('#datepicker-user').data().daterangepicker.startDate ? moment().startOf('year')
    endDate = $('#datepicker-user').data().daterangepicker.endDate ? moment()
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
        Api.get('issues', project_id: project.id, limit: 1, status_id: '*', assigned_to_id: 'me', created_on: q)
        Api.get('issues', project_id: project.id, limit: 1, status_id: 'closed', assigned_to_id: 'me', closed_on: q)
      ]
    .then (issuesByUserPerWeek) ->
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
    .catch (error) =>
      @errorMyProgress = true
]
