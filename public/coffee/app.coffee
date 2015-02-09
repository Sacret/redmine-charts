app = angular.module('charts', ['charts-projects', 'angular-ladda'])

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

app.controller 'ChartsController', ['Api', '$scope', '$q', '$filter', (Api, $scope, $q, $filter) ->
  $scope.site = 'http://redmine.pfrus.com'
  $scope.key = '261e9890fc1b2aa799f942ff2d6daa9fa691bd91'
  $scope.projects = []
  $scope.statuses = []

  @getProjects = ->
    $scope.signinLoading = true
    Api.key = $scope.key
    Api.get('projects', limit: 100)
      .then (projects) ->
        $scope.projects = projects.data
        $scope.projectsCount = projects.count
        $scope.signinLoading = false

  @setSelectedProject = (project) =>
    $scope.currentProject = project
    $('#start-date').val(moment().startOf('year').format('MMM/YY'))
    $('#end-date').val(moment().format('MMM/YY'))
    $('#datepicker').datepicker
      format: 'M/yy'
      minViewMode: 1
    $('#start-date').data('datepicker').setStartDate(moment(project.created_on).toDate())
    $('#start-date').data('datepicker').setEndDate(moment().toDate())
    $('#end-date').data('datepicker').setStartDate(moment(project.created_on).toDate())
    $('#end-date').data('datepicker').setEndDate(moment().toDate())
    @getIssueStatuses()
    @getTodayIssues()
    @getIssuesPerMonth()

  @isSelectedProject = (project) ->
    $scope.currentProject?.id == project.id

  @getIssueStatuses = =>
    return unless $scope.currentProject?
    Api.key = $scope.key
    Api.get('issue_statuses')
      .then (issueStatuses) =>
        $scope.statuses = issueStatuses.data
        $q.all $scope.statuses.map (status) =>
          @getIssuesByStatus($scope.currentProject, status)
      .then (issuesbyStatuses) =>
        $scope.currentProject.issuesbyStatuses = issuesbyStatuses
        $scope.currentProject.issuesOverallCount = _(issuesbyStatuses)
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

  @getIssuesByStatus = (project, status) ->
    Api.key = $scope.key
    Api.get('issues', project_id: project.id, status_id: status.id, limit: 1)
      .then (issuesByStatus) -> [
        "#{ status.name } (#{ issuesByStatus.count })"
        issuesByStatus.count
      ]

  @getTodayIssues = ->
    return unless $scope.currentProject?
    today = $filter('date')(new Date(), 'yyyy-MM-dd')
    Api.key = $scope.key
    $q.all([
      Api.get('issues', project_id: $scope.currentProject.id, limit: 1, status_id: '*', created_on: today)
      Api.get('issues', project_id: $scope.currentProject.id, limit: 1, status_id: 'closed', updated_on: today)
    ]).then ([todayIssuesCreated, todayIssuesClosed]) ->
      $scope.currentProject.todayIssuesCreatedCount = todayIssuesCreated.count
      $scope.currentProject.todayIssuesClosedCount = todayIssuesClosed.count
      $scope.currentProject.todayIssuesLoaded = true
      $scope.currentProject.todayIssuesCount = todayIssuesCreated.count + todayIssuesClosed.count
      $chart = $('#issues-today')
      $chart.highcharts
        chart:
          type: 'column'
        title:
          text: null
        xAxis:
          categories: [
            "Today Issues (#{ $scope.currentProject.todayIssuesCount })"
          ]
        yAxis: [
          min: 0
          title:
            text: 'Issues'
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

  @getIssuesPerMonth = ->
    return unless $scope.currentProject?
    $scope.perMonthLoading = true
    startDateValue = $('#start-date').val()
    endDateValue = $('#end-date').val()
    startDate = if startDateValue then moment('01/' + startDateValue) else moment().startOf('year')
    endDate = if endDateValue then moment('01/' + endDateValue).endOf('month') else moment()
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
        Api.get('issues', project_id: $scope.currentProject.id, limit: 1, status_id: '*', created_on: q)
        Api.get('issues', project_id: $scope.currentProject.id, limit: 1, status_id: 'closed', updated_on: q)
      ]
    .then (issuesPerMonth) ->
      $scope.currentProject.perMonthIssuesLoaded = true
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
      $scope.perMonthLoading = false

]
