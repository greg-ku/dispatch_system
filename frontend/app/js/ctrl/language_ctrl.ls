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