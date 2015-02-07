app = angular.module('charts', ['charts-projects'])

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
      result =
        data: data.data[path]
        count: data.data.total_count

  get: (path, params) ->
    @_request('get', path, params)
]

app.controller 'ChartsController', ['Api', '$scope', '$q', (Api, $scope, $q) ->
  $scope.site = 'http://redmine.pfrus.com'
  $scope.key = '261e9890fc1b2aa799f942ff2d6daa9fa691bd91'
  $scope.projects = []
  $scope.statuses = []

  @getProjects = ->
    Api.key = $scope.key
    Api.get('projects', limit: 100)
      .then (projects) ->
        $scope.projects = projects.data
        $scope.projectsCount = projects.count

  @setSelectedProject = (project) =>
    $scope.currentProject = project
    @getIssueStatuses()

  @isSelectedProject = (project) ->
    $scope.currentProject?.id == project.id

  @getIssueStatuses = =>
    Api.key = $scope.key
    Api.get('issue_statuses')
      .then (issueStatuses) =>
        $scope.statuses = issueStatuses.data
        $q.all $scope.statuses.map (status) =>
          @getIssuesByStatus($scope.currentProject, status)
      .then (issuesbyStatuses) =>
        $scope.currentProject?.issuesbyStatuses = issuesbyStatuses
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
      .then (issuesByStatus) ->
        result = [
          "#{ status.name } (#{ issuesByStatus.count })"
          issuesByStatus.count
        ]
]
