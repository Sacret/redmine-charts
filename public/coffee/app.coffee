app = angular.module('charts', ['charts-projects'])

app.factory 'Api', ['$http', '$window', ($http, $window) ->
  basePath: 'http://redmine.pfrus.com'
  key: ''

  _request: (method, path, params = {}) ->
    _.assign params,
      key: @key
      callback: 'JSON_CALLBACK'

    c = $window.angular.callbacks.counter.toString(36)
    $window['angularcallbacks_' + c] = (data) ->
      $window.angular.callbacks['_' + c](data)
      delete $window['angularcallbacks_' + c]

    $http
      url: "#{ @basePath }/#{ path }.json"
      params: params
      method: method
      limit: 100

  get: (path, params) ->
    @_request('jsonp', path, params)
]

app.controller 'ChartsController', ['Api', '$scope', (Api, $scope) ->
  @site = 'http://redmine.pfrus.com'
  @key = '261e9890fc1b2aa799f942ff2d6daa9fa691bd91'
  $scope.projects = []

  @getProjects = =>
    Api.key = @key
    Api.get('projects')
      .then (data) ->
        $scope.projects = data.data.projects

  @setSelectedProject = (project) =>
    $scope.currentProject = project
    console.log project

  @isSelectedProject = (projectId) =>
    $scope.currentProject.id == projectId
]
