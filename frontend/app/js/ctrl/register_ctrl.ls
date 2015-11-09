dispatchApp.controller \registerCtrl, [\$scope, \$modalInstance, ($scope, $modalInstance) ->
    $scope.close = !-> $modalInstance.dismiss(\cancel);

    $scope.LENGTH =
        NAME: 40
        GENERAL: 100

    # default
    $scope.regType = \PERSONAL

    $scope.registerAcc = (acc) ->
        if acc.confirmPw == acc.pw && acc.pw?.length > $scope.LENGTH.GENERAL
            delete acc.confirmPw
        else
            alert 'password incorrect' # use alert temporary
            return

        delete acc.username if $scope.regType == \PERSONAL
        delete acc.company if $scope.regType == \COMPANY
        acc.type = $scope.regType

        $http.post \/account, acc
        .then (responseObj) -> # success callback
            res = responseObj.data
            if res.code == 200
                alert 'register success'
                $scope.close!
        , (responseObj) -> # error callback
            # error handle
]
