require! \gulp
require! \gulp-util
require! \gulp-bower-files
require! \gulp-filter
require! \gulp-concat
require! \gulp-if
require! \gulp-uglify
require! \gulp-ls
require! \gulp-ruby-sass
require! \gulp-notify
require! \browser-sync

reload = browserSync.reload

# environment
env = gulpUtil.env.env || \dev

builtNames = 
	appJs: \app.js
	vendorJs: \vendor.js

paths =
	outputDir: \_public
	bootstrapDir: \bower_components/bootstrap-sass-official/assets/stylesheets
	icons:
		src: \bower_components/bootstrap-sass-official/assets/fonts/**/*.*
		dest: \_public/fonts
	html:
		src: \app/*.html
		dest: \_public/
	scripts:
		src: \app/js/**/*.ls
		dest: \_public/js
		vendorDest: \_public/js
	css:
		dir: \app/css
		src: \app/css/style.scss
		dest: \_public/css

gulp.task \html, ->
	gulp.src paths.html.src
		.pipe gulp.dest paths.html.dest
		.pipe reload { stream: true }

gulp.task \js-vendor, ->
	gulpBowerFiles!
		.pipe gulpFilter (file) -> /\.js$/.test file.path
		.pipe gulpConcat builtNames.vendorJs
		.pipe gulpIf env == \production, gulpUglify!
		.pipe gulp.dest paths.scripts.vendorDest
		.pipe reload { stream: true }

gulp.task \js-app, ->
	gulp.src paths.scripts.src
		.pipe gulpLs { bare: true }
		.pipe gulpConcat builtNames.appJs
		.pipe gulp.dest paths.scripts.dest
		.pipe reload { stream: true }

gulp.task \css, ->
	gulpRubySass do
		paths.css.src
		style: \compressed
		loadPath:
			paths.css.dir
			paths.bootstrapDir
	.pipe gulp.dest paths.css.dest

gulp.task \icons, ->
	gulp.src paths.icons.src
		.pipe gulp.dest paths.icons.dest

# watch files for changes and reload
gulp.task \watch, [\build], ->
	browserSync do
		browser: "google chrome"
		server:
			baseDir: paths.outputDir

	gulp.watch [paths.html.src, paths.scripts.src], [\build]

gulp.task \build, [\html, \js-vendor, \js-app, \css, \icons]