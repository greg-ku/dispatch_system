templates = angular.module \templates, []

dispatchApp = angular.module \dispatchApp, [\ui.bootstrap, \templates, \pascalprecht.translate]

dispatchApp.config [\$translateProvider, ($translateProvider) ->
    $translateProvider.useStaticFilesLoader do
        prefix: \/lang/
        suffix: \.json
    # $translateProvider.useLocalStorage!
    $translateProvider.preferredLanguage \en-US
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
]

dispatchApp.controller \languageCtrl, [\$scope, \$translate, \$modalInstance, \$http, ($scope, $translate, $modalInstance, $http) ->
    # modal close function
    $scope.close = !-> $modalInstance.dismiss(\cancel);

    # language list
    $scope.langs = 
        * lang: "English"
          value: \en-US
        * lang: "Traditional Chinese"
          value: \zh-TW
    $scope.selectedLang = $scope.langs[0]

    prefix = \/lang/
    suffix = \.json
    $scope.changeLang = (lang) ->
        $scope.langUsed = lang || $scope.selectedLang.value
        if not $scope.langUsed?
            return

        $http.get prefix + $scope.langUsed + suffix
        .then (response) ->
            $translate.use $scope.langUsed
        , (response) ->
            # error handle
]