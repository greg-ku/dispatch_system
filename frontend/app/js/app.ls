templates = angular.module \templates, []

dispatchApp = angular.module \dispatchApp, [\ui.bootstrap, \templates, \pascalprecht.translate]

dispatchApp.config [\$translateProvider, ($translateProvider) ->
    # translation setting
    $translateProvider.useStaticFilesLoader do
        prefix: \/lang/
        suffix: \.json
    preferLang = window.localStorage[\lang] || \en-US
    $translateProvider.preferredLanguage preferLang
]

# global variables service
dispatchApp.factory \globalVars, ->
    prefix = \/api
    vars =
        API: {}

    vars.API.account =
        create: prefix + \/account
        login: prefix + \/account/login
        logout: prefix + \/account/logout
        available: prefix + \/account/available
        getCurrent: prefix + \/account/current

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
