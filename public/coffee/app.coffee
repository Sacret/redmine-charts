app = angular.module('charts', [])

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
      method: 'jsonp'
      cache: true

  get: (path, params) ->
    @_request('GET', path, params)
]

app.controller 'ChartsController', ['Api', (Api) ->
  @site = 'http://redmine.pfrus.com'
  @key = '261e9890fc1b2aa799f942ff2d6daa9fa691bd91'

  @getProjects = =>
    Api.key = @key
    Api.get('projects')
      .then (data) ->
        @projects = data
]
