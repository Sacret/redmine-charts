app = angular.module('charts-projects', [])

app.directive 'projectNames', ->
  restrict: 'E'
  templateUrl: 'public/templates/project-names.html'
  ###controller: ->###
  ###controllerAs: 'projects'###

app.directive 'projectInfo', ->
  restrict: 'E'
  templateUrl: 'public/templates/project-info.html'
  ###controller: ->###
  ###controllerAs: 'projects'###
