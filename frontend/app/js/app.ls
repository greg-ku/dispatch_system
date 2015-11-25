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

dispatchApp.factory \globalVars, ->
    prefix = \/api
    vars =
        API: {}

    vars.API.account =
        create: prefix + \/account
        login: prefix + \/account/login
        logout: prefix + \/account/logout

    return vars
