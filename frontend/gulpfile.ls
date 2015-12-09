    require! \gulp
require! \gulp-util
require! \gulp-bower-files
require! \gulp-filter
require! \gulp-concat
require! \gulp-if
require! \gulp-uglify
require! \gulp-ls
require! \gulp-ruby-sass
require! \gulp-angular-templatecache
require! \gulp-notify
require! \browser-sync
require! \merge-stream
require! \karma

KarmaServer = karma.Server

reload = browserSync.reload

# environment
env = gulpUtil.env.env || \dev

builtNames = 
    appJs: \app.js
    vendorJs: \vendor.js
    extraCss: \tmp.css
    css: \style.css

paths =
    outputDir: \_public
    bootstrapDir: \bower_components/bootstrap-sass-official/assets/stylesheets
    icons:
        src: \bower_components/bootstrap-sass-official/assets/fonts/**/*.*
        dest: \_public/fonts
    lang:
        src: \app/lang/**/*.json
        dest: \_public/lang
    html:
        src: \app/index.html
        dest: \_public/
        templateSrc: \app/partials/**/*.html
        tmp: \tmp/templates.js
    scripts:
        src: \app/js/**/*.ls
        dest: \_public/js
        vendorDest: \_public/js
    css:
        dir: \app/css
        src: \app/css/style.scss
        dest: \_public/css
        tmp: \tmp/tmp.css
    tmp: \tmp

gulp.task \html, ->
    gulp.src paths.html.src
        .pipe gulp.dest paths.html.dest
        .pipe reload { stream: true }

gulp.task \template, ->
    gulp.src paths.html.templateSrc
        .pipe gulpAngularTemplatecache!
        .pipe gulp.dest paths.tmp
        .pipe reload { stream: true }

gulp.task \js-vendor, ->
    gulpBowerFiles!
        .pipe gulpFilter (file) -> /\.js$/.test file.path
        .pipe gulpConcat builtNames.vendorJs
        .pipe gulpIf env == \production, gulpUglify!
        .pipe gulp.dest paths.scripts.vendorDest
        .pipe reload { stream: true }

gulp.task \js-app, [\template], ->
    gulp.src [paths.scripts.src, paths.html.tmp]
        .pipe gulpLs { bare: true }
        .pipe gulpConcat builtNames.appJs
        .pipe gulp.dest paths.scripts.dest
        .pipe reload { stream: true }

gulp.task \css, ->
    # extra plugin css
    cssStream = gulpBowerFiles!
        .pipe gulpFilter (file) -> /\.css$/.test file.path
        .pipe gulpConcat builtNames.extraCss
        .pipe gulp.dest paths.tmp

    # compile sass
    sassStream = gulpRubySass do
        paths.css.src
        style: \compressed
        loadPath:
            paths.css.dir
            paths.bootstrapDir
    .pipe gulp.dest paths.tmp

    mergeStream sassStream, cssStream
    .pipe gulpConcat builtNames.css
    .pipe gulp.dest paths.css.dest
    .pipe reload { stream: true }

gulp.task \icons, ->
    gulp.src paths.icons.src
        .pipe gulp.dest paths.icons.dest

gulp.task \lang, ->
    gulp.src paths.lang.src
        .pipe gulp.dest paths.lang.dest

gulp.task \test, [\build], (done) ->
    new KarmaServer { configFile: __dirname + \/karma.conf.js, singleRun: true }, done .start!

# watch files for changes and reload
gulp.task \watch, [\build], ->
    browserSync do
        browser: "google chrome"
        server:
            baseDir: paths.outputDir
            routes:
                '/api': 'test/mocks'

    gulp.watch [paths.html.src, paths.html.templateSrc, paths.scripts.src, paths.css.src, paths.lang.src], [\build]

gulp.task \build, [\html, \js-vendor, \js-app, \css, \icons, \lang]