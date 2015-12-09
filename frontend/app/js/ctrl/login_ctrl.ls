dispatchApp.controller \loginCtrl, [\$scope, \$http, \$modalInstance, \globalVars, \loginInfo, ($scope, $http, $modalInstance, globalVars, loginInfo) ->
    $scope.close = !-> $modalInstance.dismiss(\cancel);

    api = globalVars.API

    PROMPT = globalVars.PROMPT

    # default values
    $scope.acc = {}

    $scope.setErrorMsg = (target, msg) ->
        $scope.errMsg = msg
        $scope.errTarget = target

    $scope.login = (acc) ->
        if !acc.username
            $scope.setErrorMsg \username, PROMPT.SHOULD_NOT_EMPTY
        if !acc.password
            $scope.setErrorMsg \password, PROMPT.SHOULD_NOT_EMPTY

        $scope.requesting = true
        $http.post api.account.login, acc
        .then (responseObj) ->
            res = responseObj.data
            if res.code == 200
                loginInfo.setLoggedIn true, res.userInfo
                $scope.$emit \loggedIn
                $scope.close!
            else
                $scope.setErrorMsg res.errTarget, res.msg
            $scope.requesting = false
        , (responseObj) ->
            # error handle
            $scope.requesting = false
]
