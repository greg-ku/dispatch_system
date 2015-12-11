dispatchApp.controller \profileCtrl, [\$scope, \$http, \$routeParams, \globalVars, \loginInfo,
($scope, $http, $routeParams, globalVars, loginInfo) ->
    api = globalVars.API

    # default values
    $scope.isCurrentUser = false

    if !$routeParams.username
        throw new Error 'no username parameter'

    eraseProfile = ->
        $scope.userInfo = null
        $scope.isCurrentUser = false

    fetchProfile = ->
        $http.get api.account.fetch + \/ + $routeParams.username,
        .then (responseObj) ->
            res = responseObj.data
            if res.code == 200
                $scope.userInfo = res.userInfo
                $scope.isCurrentUser = true if res.userInfo.username == loginInfo.getUserInfo().username
            else
                eraseProfile!
        , (responseObj) ->
            # error handle
            eraseProfile!

    # listening events
    $scope.$on \refreshProfile, (event) -> fetchProfile!

    # fetch user profile
    fetchProfile!
]