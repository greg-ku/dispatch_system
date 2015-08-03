require! \gulp
require! \gulp-util
require! \gulp-bower-files
require! \gulp-filter
require! \gulp-concat
require! \gulp-if
require! \gulp-uglify
require! \gulp-ls

# environment
env = gulpUtil.env.env || \dev

builtNames = 
	appJs: \app.js
	vendorJs: \vendor.js

paths =
	html:
		src: \app/*.html
		dest: \_public/
	scripts:
		src: \app/js/**/*.ls
		dest: \_public/js
		vendorDest: \_public/js

gulp.task \html, ->
	gulp.src paths.html.src
		.pipe gulp.dest paths.html.dest

gulp.task \js-vendor, ->
	gulpBowerFiles!
		.pipe gulpFilter (file) -> /\.js$/.test file.path
		.pipe gulpConcat builtNames.vendorJs
		.pipe gulpIf env == \production, gulpUglify()
		.pipe gulp.dest paths.scripts.vendorDest

gulp.task \js-app, ->
	gulp.src paths.scripts.src
		.pipe gulpLs { bare: true }
		.pipe gulpConcat builtNames.appJs
		.pipe gulp.dest paths.scripts.dest

gulp.task \build, [\html, \js-vendor, \js-app]