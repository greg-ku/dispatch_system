templates = angular.module \templates, []

dispatchApp = angular.module \dispatchApp, [\ui.bootstrap, \templates, \pascalprecht.translate]

dispatchApp.config [\$translateProvider, ($translateProvider) ->
    $translateProvider.useStaticFilesLoader do
        prefix: \/lang/
        suffix: \.json
    preferLang = window.localStorage[\lang] || \en-US
    $translateProvider.preferredLanguage preferLang
]

dispatchApp.controller \dispatchCtrl, [\$scope, \$modal, ($scope, $modal) ->
    $scope.openLoginModal = ->
        modalInstance = $modal.open do
            animation: true
            templateUrl: \login_modal.html
            controller: \loginCtrl

    $scope.openRegisterModal = ->
        modalInstance = $modal.open do
            animation: true
            templateUrl: \register_modal.html
            controller: \registerCtrl

    $scope.openLangModal = ->
        modalInstance = $modal.open do
            animation: true
            templateUrl: \language_modal.html
            controller: \languageCtrl
]

dispatchApp.controller \loginCtrl, [\$scope, \$modalInstance, ($scope, $modalInstance) ->
    $scope.close = !-> $modalInstance.dismiss(\cancel);
]

dispatchApp.controller \registerCtrl, [\$scope, \$modalInstance, ($scope, $modalInstance) ->
    $scope.close = !-> $modalInstance.dismiss(\cancel);

    $scope.LENGTH =
        NAME: 40
        GENERAL: 100

    # default
    $scope.regType = \PERSONAL

    $scope.registerAcc = (acc) ->
        if acc.confirmPw == acc.pw && acc.pw?.length > $scope.LENGTH.GENERAL
            delete acc.confirmPw
        else
            alert 'password incorrect' # use alert temporary
            return

        delete acc.username if $scope.regType == \PERSONAL
        delete acc.company if $scope.regType == \COMPANY
        acc.type = $scope.regType

        $http.post \/account, acc
        .then (responseObj) -> # success callback
            res = responseObj.data
            if res.code == 200
                alert 'register success'
                $scope.close!
        , (responseObj) -> # error callback
            # error handle
]

dispatchApp.controller \languageCtrl, [\$scope, \$translate, \$modalInstance, \$http, ($scope, $translate, $modalInstance, $http) ->
    # modal close function
    $scope.close = !-> $modalInstance.dismiss(\cancel);

    # language list
    $scope.langs = 
        * lang: "ENGLISH"
          value: \en-US
        * lang: "TRAD_CHINESE"
          value: \zh-TW

    # set current language
    $scope.selectedLang = $scope.langs[0] # default
    if window.localStorage[\lang]?
        $scope.langs.forEach (lang) -> $scope.selectedLang = lang if window.localStorage[\lang] == lang.value

    prefix = \/lang/
    suffix = \.json
    $scope.changeLang = (lang) ->
        $scope.langUsed = lang || $scope.selectedLang.value
        if not $scope.langUsed?
            return

        $http.get prefix + $scope.langUsed + suffix
        .then (response) -> # success callback
            $translate.use $scope.langUsed
            window.localStorage[\lang] = $scope.langUsed # store language
        , (response) -> # error callback
            # error handle
]