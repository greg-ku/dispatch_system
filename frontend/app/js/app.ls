templates = angular.module \templates, []

dispatchApp = angular.module \dispatchApp,[
    \ngRoute,
    \ui.bootstrap,
    \templates,
    \pascalprecht.translate,
    \date-obj-filter,
    \file-input-directive,
    \select-emulation-directive
]

dispatchApp.config [\$routeProvider, \$translateProvider, ($routeProvider, $translateProvider) ->
    # translation setting
    $translateProvider.useStaticFilesLoader do
        prefix: \/lang/
        suffix: \.json
    preferLang = window.localStorage[\lang] || \en-US
    $translateProvider.preferredLanguage preferLang
    $translateProvider.useSanitizeValueStrategy \escape

    # config url routes
    $routeProvider
    .when \/profile/:username, action: \profile
    .when \/case/:id, action: \previewCase
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
        getCase: prefix + \/case

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
    loggedIn = false
    userInfo = {}
    callbacks = []

    doCallbacks = ->
        for cb, i in callbacks
            cb userInfo, loggedIn

    # public functions
    info.setLoggedIn = (isLoggedIn, newUserInfo) ->
        loggedIn := isLoggedIn
        userInfo := newUserInfo
        doCallbacks!
    info.getUserInfo = -> userInfo
    info.isLoggedIn = -> loggedIn

    info.register = (callback) ->
        callbacks.push callback
    info.unregister = (callback) ->
        index = callbacks.indexOf callback
        callbacks.splice index, 1 if index >= 0
    return info
