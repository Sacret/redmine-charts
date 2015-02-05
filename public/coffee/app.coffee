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
      data.data[path]

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
    Api.get('projects')
      .then (projects) ->
        $scope.projects = projects

  @setSelectedProject = (project) =>
    $scope.currentProject = project
    console.log project
    @getIssueStatuses()

  @isSelectedProject = (project) ->
    $scope.currentProject?.id == project.id

  @getIssueStatuses = =>
    Api.key = $scope.key
    Api.get('issue_statuses')
      .then (issueStatuses) =>
        $scope.statuses = issueStatuses
        $q.all $scope.statuses.map (status) =>
          @getIssuesByStatus($scope.currentProject, status)

  @getIssuesByStatus = (project, status) ->
    Api.key = $scope.key
    Api.get('issues', project_id: project.id, status_id: status.id, limit: 1)
]
