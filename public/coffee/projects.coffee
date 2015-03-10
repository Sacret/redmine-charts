projects = angular.module('charts-projects', [])

projects.directive 'projectNames', ->
  restrict: 'E'
  templateUrl: 'templates/project-names.html'

projects.directive 'projectInfo', ->
  restrict: 'E'
  templateUrl: 'templates/project-info.html'
