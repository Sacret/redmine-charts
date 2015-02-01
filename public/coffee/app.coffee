app = angular.module('charts', [])

app.factory 'Api', ['$http', ($http) ->
  basePath: 'http://redmine.pfrus.com'
  key: ''

  _request: (method, path, params = {}) ->
    _.assign params,
      key: @key
      callback: 'JSON_CALLBACK'
    encodedParams = querystring.encode(params)
    ###$http
      url: '#{ @basePath }/#{ path }.json?#{ encodedParams }'
      method: method###
    debugger
    url1 = 'http://redmine.pfrus.com/projects.json?key=261e9890fc1b2aa799f942ff2d6daa9fa691bd91&callback=JSON_CALLBACK'
    url2 = '#{ @basePath }/#{ path }.json?#{ encodedParams }'
    debugger
    $http
      url: url1
      method: 'jsonp'
      cache: true
      crossDomain: true

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
