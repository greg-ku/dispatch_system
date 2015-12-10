dispatchApp.controller \dispatchCtrl, [\$scope, \$modal, \$http, \$route, \globalVars, \loginInfo,
($scope, $modal, $http, $route, globalVars, loginInfo) ->
    api = globalVars.API

    $scope.openLoginModal = ->
        modalInstance = $modal.open do
            animation: true
            templateUrl: \login_modal.html
            controller: \loginCtrl
            scope: $scope

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

    $scope.updateLoginInfo = ->
        $scope.loggedIn = loginInfo.loggedIn
        $scope.userInfo = loginInfo.userInfo

    # listen events
    $scope.$on \loggedIn, (event) ->
        $scope.updateLoginInfo!

    # fetch current user info
    $http.get api.account.getCurrent
    .then (responseObj) ->
        res = responseObj.data
        loginInfo.setLoggedIn true, res.userInfo if res.userInfo
        $scope.updateLoginInfo!
    , (responseObj) ->

    $scope.logout = ->
        $http.post api.account.logout
        .then (responseObj) ->
            if responseObj.data.code == 200
                loginInfo.setLoggedIn false, null
                $scope.updateLoginInfo!
            # TODO: handle logout failed
        , (responseObj) ->

    $scope.currentUrl = \home #default url
    $scope.$on \$routeChangeSuccess, ->
        switch $route.current.action
        case \home then $scope.currentUrl = \home
        case \profile then $scope.currentUrl = \profile
]
