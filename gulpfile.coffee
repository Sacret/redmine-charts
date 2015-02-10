gulp = require 'gulp'
less = require 'gulp-less'
coffee = require 'gulp-coffee'
concat = require 'gulp-concat'
uglify = require 'gulp-uglify'
combiner = require 'stream-combiner2'

paths =
  less: './public/less/**/*.less'
  css: './public/css'
  components: './public/bower_components'
  coffee: './public/coffee/**/*.coffee'
  js: './public/js'

gulp.task 'less', ->
  combiner [
    gulp.src(paths.less)
    less
      paths: [__dirname + '/public/bower_components/bootstrap/less']
    gulp.dest(paths.css)
  ]

gulp.task 'components', ->
  components = [
    'jquery/dist/jquery.js'
    'bootstrap/dist/js/bootstrap.js'
    'highcharts-release/highcharts.js'
    'angular/angular.js'
    'lodash/dist/lodash.js'
    'ladda/js/spin.js'
    'ladda/js/ladda.js'
    'angular-ladda/dist/angular-ladda.js'
    'moment/moment.js'
    'moment-range/lib/moment-range.js'
    'bootstrap-daterangepicker/daterangepicker.js'
  ]
  gulp.src(components.map (p) -> paths.components + '/' + p)
    .pipe concat('components.js')
    # .pipe uglify()
    .pipe gulp.dest(paths.js)

gulp.task 'coffee', ->
  gulp.src(paths.coffee)
    .pipe coffee()
    .pipe gulp.dest(paths.js)

gulp.task 'watch', ->
  gulp.watch(paths.less, ['less'])
  gulp.watch(paths.coffee, ['coffee'])

gulp.task 'build', ['less', 'components', 'coffee']

gulp.task 'default', ['build']
