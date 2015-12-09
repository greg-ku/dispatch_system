dispatchApp.controller \dispatchCtrl, [\$scope, \$modal, \$http, \globalVars, \loginInfo, ($scope, $modal, $http, globalVars, loginInfo) ->
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

    $scope.setLoginInfo = ->
        $scope.loggedIn = loginInfo.loggedIn
        $scope.userInfo = loginInfo.userInfo

    # listen events
    $scope.$on \loggedIn, (event) ->
        $scope.setLoginInfo!

    # fetch current user info
    $http.get globalVars.API.account.getCurrent
    .then (responseObj) ->
        res = responseObj.data
        loginInfo.setLoggedIn true, res.userInfo if res.userInfo
        $scope.setLoginInfo!
    , (responseObj) ->

]
