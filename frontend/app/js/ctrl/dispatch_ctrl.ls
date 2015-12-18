dispatchApp.controller \dispatchCtrl, [\$scope, \$uibModal, \$http, \$route, \globalVars, \loginInfo,
($scope, $uibModal, $http, $route, globalVars, loginInfo) ->

    api = globalVars.API

    $scope.openLoginModal = ->
        modalInstance = $uibModal.open do
            animation: true
            templateUrl: \login_modal.html
            controller: \loginCtrl

    $scope.openRegisterModal = ->
        modalInstance = $uibModal.open do
            animation: true
            templateUrl: \register_modal.html
            controller: \registerCtrl

    $scope.openLangModal = ->
        modalInstance = $uibModal.open do
            animation: true
            templateUrl: \language_modal.html
            controller: \languageCtrl

    $scope.logout = ->
        $http.post api.account.logout
        .then (responseObj) ->
            if responseObj.data.code == 200
                loginInfo.setLoggedIn false, null
                location.hash = \#
            # TODO: handle logout failed
        , (responseObj) ->

    # callback of updating login info
    updateLoginInfo = (userInfo, isLoggedIn) ->
        $scope.loggedIn = isLoggedIn
        $scope.userInfo = userInfo

    # registering login info callback
    loginInfo.register updateLoginInfo
    # unregistering login info callback in destructor
    $scope.$on \$destroy, -> loginInfo.unregister updateLoginInfo

    # fetch current user info
    $http.get api.account.getCurrent
    .then (responseObj) ->
        res = responseObj.data
        loginInfo.setLoggedIn true, res.userInfo if res.userInfo
    , (responseObj) ->

    # routing url
    $scope.currentUrl = \home #default url
    $scope.$on \$routeChangeSuccess, ->
        switch $route.current.action
        case \home then $scope.currentUrl = \home
        case \profile
            if $scope.currentUrl != \profile
                $scope.currentUrl = \profile
            else
                $scope.$broadcast \refreshProfile
]
