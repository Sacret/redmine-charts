path = require 'path'

gulp = require 'gulp'
less = require 'gulp-less'
coffee = require 'gulp-coffee'

paths =
  less: './public/less/**/*.less'
  css: './public/css'
  coffee: './public/coffee/**/*.coffee'
  js: './public/js'

gulp.task 'less', ->
  gulp.src(paths.less)
    .pipe less
      paths: [path.join(__dirname, './bower_components/bootstrap/less')]
    .pipe gulp.dest(paths.css)

gulp.task 'coffee', ->
  gulp.src(paths.coffee)
    .pipe coffee()
    .pipe gulp.dest(paths.js)

gulp.task 'watch', ->
  gulp.watch(paths.less, ['less'])
  gulp.watch(paths.coffee, ['coffee'])

gulp.task 'default', ['less', 'coffee', 'watch']
