templates = angular.module \templates, []

dispatchApp = angular.module \dispatchApp, [\ngRoute, \ui.bootstrap, \templates, \pascalprecht.translate, \date-obj-filter, \file-input-directive]

dispatchApp.config [\$routeProvider, \$translateProvider, ($routeProvider, $translateProvider) ->
    # translation setting
    $translateProvider.useStaticFilesLoader do
        prefix: \/lang/
        suffix: \.json
    preferLang = window.localStorage[\lang] || \en-US
    $translateProvider.preferredLanguage preferLang

    # config url routes
    $routeProvider
    .when \/profile/:username, action: \profile
    .otherwise redirectTo: '', action: \home
]

# global variables service
dispatchApp.factory \globalVars, ->
    prefix = \/api
    vars =
        API: {}

    vars.API.account =
        create: prefix + \/account
        fetch: prefix + \/account
        login: prefix + \/account/login
        logout: prefix + \/account/logout
        available: prefix + \/account/available
        getCurrent: prefix + \/account/current
        getHeadshot: prefix + \/account/headshot
        uploadHeadshot: prefix + \/account/headshot

    vars.API.case =
        createCase: prefix + \/case
        getCases: prefix + \/case

    vars.PROMPT =
        NAME_USED: \NAME_USED
        INVALID_CHAR: \INVALID_CHAR
        INCORRECT_NAME_LENGTH: \INCORRECT_NAME_LENGTH
        INCORRECT_PW_LENGTH: \INCORRECT_PW_LENGTH
        PW_NOT_CONFIRM: \PW_NOT_CONFIRM
        WRONG_EMAIL_FORMAT: \WRONG_EMAIL_FORMAT
        SHOULD_NOT_EMPTY: \SHOULD_NOT_EMPTY
        CHAR_TOO_LONG: \CHAR_TOO_LONG

    vars.isEmail = (str) ->
        if str?.length <= 0
            return false
        /^[\w.-]+@[\w.-]+\.[\w]{2,}/.test str

    return vars

# login info service
dispatchApp.factory \loginInfo, ->
    info = {}
    info.loggedIn = false
    info.userInfo = {}

    # public functions
    info.setLoggedIn = (loggedIn, userInfo) ->
        this.loggedIn = loggedIn
        this.userInfo = userInfo
    info.getUserInfo = -> this.userInfo
    info.isLoggedIn = -> this.loggedIn

    return info
