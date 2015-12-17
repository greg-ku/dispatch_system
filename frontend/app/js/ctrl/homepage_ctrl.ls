dispatchApp.controller \homepageCtrl, [\$scope, \$http, \globalVars, \loginInfo, ($scope, $http, globalVars, loginInfo) ->
    api = globalVars.API

    # default values
    $scope.userInfo = loginInfo.getUserInfo!
    $scope.cases = []
    skip = 0

    # callback of updating login info
    updateLoginInfo = -> $scope.userInfo = loginInfo.getUserInfo!

    # registering login info callback
    loginInfo.register updateLoginInfo
    # unregistering login info callback in destructor
    $scope.$on \$destroy, -> loginInfo.unregister updateLoginInfo

    $http.get api.case.getCases, params: { skip: skip }
    .then (responsiveObj) ->
        res = responsiveObj.data
        if res.code == 200
            $scope.cases = $scope.cases.concat res.cases
            skip += res.cases.length
    , (responsiveObj) ->
        # error handle
]
