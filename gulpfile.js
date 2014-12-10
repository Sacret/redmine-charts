var path = require('path');

var gulp = require('gulp');
var less = require('gulp-less');
var coffee = require('gulp-coffee');

var lessPath = './public/less/**/*.less';

gulp.task('less', function() {
  gulp.src(lessPath)
    .pipe(less({
      paths: [path.join(__dirname, 'bower_components', 'bootstrap', 'less')]
    }))
    .pipe(gulp.dest('./public/css'));
});

gulp.task('watch', function() {
  gulp.watch(lessPath, ['less']);
});
