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

bSync = browserSync.create!
KarmaServer = karma.Server

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
        tmp: \tmp/app.js
    css:
        dir: \app/css
        src: \app/css/style.scss
        dest: \_public/css
        tmp: \tmp/tmp.css
    tmp: \tmp

gulp.task \html, ->
    gulp.src paths.html.src
        .pipe gulp.dest paths.html.dest
gulp.task \html-watch, [\html], -> bSync.reload!

gulp.task \js-vendor, ->
    gulpBowerFiles!
        .pipe gulpFilter (file) -> /\.js$/.test file.path
        .pipe gulpConcat builtNames.vendorJs
        .pipe gulpIf env == \production, gulpUglify!
        .pipe gulp.dest paths.scripts.vendorDest

gulp.task \template, ->
    gulp.src paths.html.templateSrc
        .pipe gulpAngularTemplatecache!
        .pipe gulp.dest paths.tmp

gulp.task \js-app, ->
    gulp.src paths.scripts.src
        .pipe gulpLs { bare: true }
        .pipe gulpConcat builtNames.appJs
        .pipe gulp.dest paths.tmp

gulp.task \js-app-complete, [\template, \js-app], ->
    gulp.src [paths.scripts.tmp, paths.html.tmp]
        .pipe gulpConcat builtNames.appJs
        .pipe gulp.dest paths.scripts.dest

gulp.task \js-concat-only, ->
    gulp.src [paths.scripts.tmp, paths.html.tmp]
        .pipe gulpConcat builtNames.appJs
        .pipe gulp.dest paths.scripts.dest
gulp.task \js-concat-watch, [\js-concat-only], -> bSync.reload!

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
    .pipe bSync.stream!

gulp.task \icons, ->
    gulp.src paths.icons.src
        .pipe gulp.dest paths.icons.dest

gulp.task \lang, ->
    gulp.src paths.lang.src
        .pipe gulp.dest paths.lang.dest
gulp.task \lang-watch, [\lang], -> bSync.reload!

gulp.task \test, [\build], (done) ->
    new KarmaServer { configFile: __dirname + \/karma.conf.js, singleRun: true }, done .start!

# watch files for changes and reload
gulp.task \watch, [\build], ->
    bSync.init do
        browser: "google chrome"
        server:
            baseDir: paths.outputDir
            routes: { '/api': 'test/mocks' }

    gulp.watch paths.css.src, [\css]
    gulp.watch paths.lang.src, [\lang-watch]
    gulp.watch paths.html.src, [\html-watch]
    gulp.watch paths.html.templateSrc, [\template]
    gulp.watch paths.scripts.src, [\js-app]
    gulp.watch [paths.scripts.tmp, paths.html.tmp], [\js-concat-watch]

gulp.task \build, [\html, \js-vendor, \js-app-complete, \css, \icons, \lang]