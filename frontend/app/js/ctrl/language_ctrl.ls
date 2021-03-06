dispatchApp.controller \languageCtrl, [\$scope, \$translate, \$uibModalInstance, \$http,
($scope, $translate, $uibModalInstance, $http) ->

    # modal close function
    $scope.close = !-> $uibModalInstance.dismiss(\cancel);

    # language list
    $scope.langs = 
        * item: "ENGLISH"
          value: \en-US
        * item: "TRAD_CHINESE"
          value: \zh-TW

    # set current language
    $scope.selectedLang = if window.localStorage[\lang] then window.localStorage[\lang] else $scope.langs[0].value

    $scope.changeLang = ->
        $translate.use $scope.selectedLang
        window.localStorage[\lang] = $scope.selectedLang # store language
]