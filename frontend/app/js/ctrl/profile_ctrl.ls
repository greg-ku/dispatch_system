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

    $scope.uploadHeadshot = (file) ->
        data = new FormData!
        data.append \headshot, file

        if $scope.userInfo.profile.headshotUrl
        then # update
            request = $http.put
            url = api.account.uploadHeadshot + \/ + $scope.userInfo.profile.headshotUrl.split \/ .pop()
        else # create new one
            request = $http.post
            data.append \id, $scope.userInfo._id
            url = api.account.uploadHeadshot

        request url, data, headers: { 'Content-Type': undefined }
        .then (responseObj) ->
            res = responseObj.data
            if res.code == 200
                $scope.userInfo.profile.headshotUrl = api.account.getHeadshot + \/ + res.id + \? + Date.now!
                loginInfo.setLoggedIn true, $scope.userInfo
                $scope.$emit \loginInfoChanged
        , (responseObj) ->
            # error handle

    # listening events
    $scope.$on \refreshProfile, (event) -> fetchProfile!

    # fetch user profile
    fetchProfile!
]