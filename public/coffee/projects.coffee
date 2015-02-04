app = angular.module('charts-projects', [])

app.directive 'projectNames', ->
  restrict: 'E'
  templateUrl: 'public/templates/project-names.html'
  ###controller: ->###
  ###controllerAs: 'projects'###
