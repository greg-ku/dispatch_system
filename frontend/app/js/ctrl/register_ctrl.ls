dispatchApp.controller \registerCtrl, [\$scope, \$modalInstance, \$http, \globalVars, ($scope, $modalInstance, $http, globalVars) ->
    $scope.close = !-> $modalInstance.dismiss(\cancel);

    api = globalVars.API

    $scope.LENGTH =
        NAME: 40
        GENERAL: 100

    # default
    $scope.regType = \PERSONAL

    $scope.registerAcc = (acc) ->
        if acc.confirmPw == acc.password && acc.password?.length < $scope.LENGTH.GENERAL
            delete acc.confirmPw
        else
            alert 'password incorrect' # use alert temporary
            return

        delete acc.username if $scope.regType != \PERSONAL
        delete acc.company if $scope.regType != \COMPANY
        acc.type = $scope.regType

        $http.post api.account.create, acc
        .then (responseObj) -> # success callback
            res = responseObj.data
            if res.code == 200
                alert 'register success'
                $scope.close!
        , (responseObj) -> # error callback
            # error handle
]
