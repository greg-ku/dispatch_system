dispatchApp.controller \caseEditCtrl, [\$scope, \$http, \$uibModalInstance, \globalVars, \loginInfo, ($scope, $http, $uibModalInstance, globalVars, loginInfo) ->
    $scope.close = !-> $uibModalInstance.dismiss(\cancel);

    api = globalVars.API

    $scope.status = opened: false
    $scope.open = ($event) -> $scope.status.opened = true
    $scope.dateOptions =
        formatYear: 'yy'
        startingDay: 1
    $scope.dt = new Date!

    # default values
    $scope.unitOpts =
        * item: \PAY_HOURLY
          value: \hour
        * item: \PAY_DAILY
          value: \day
        * item: \PAY_MONTH
          value: \month
]
