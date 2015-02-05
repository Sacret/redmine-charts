app = angular.module('charts-projects', [])

app.directive 'projectNames', ->
  restrict: 'E'
  templateUrl: 'templates/project-names.html'
  ###controller: ->###
  ###controllerAs: 'projects'###

app.directive 'projectInfo', ->
  restrict: 'E'
  templateUrl: 'templates/project-info.html'
  ###controller: ->###
  ###controllerAs: 'projects'###
