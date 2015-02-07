path = require 'path'

gulp = require 'gulp'
less = require 'gulp-less'
coffee = require 'gulp-coffee'
combiner = require 'stream-combiner2'

paths =
  less: './public/less/**/*.less'
  css: './public/css'
  coffee: './public/coffee/**/*.coffee'
  js: './public/js'

gulp.task 'less', ->
  combiner [
    gulp.src(paths.less)
    less
      paths: [path.join(__dirname, './public/bower_components/bootstrap/less')]
    gulp.dest(paths.css)
  ]

gulp.task 'coffee', ->
  gulp.src(paths.coffee)
    .pipe coffee()
    .pipe gulp.dest(paths.js)

gulp.task 'watch', ->
  gulp.watch(paths.less, ['less'])
  gulp.watch(paths.coffee, ['coffee'])

gulp.task 'default', ['less', 'coffee', 'watch']
