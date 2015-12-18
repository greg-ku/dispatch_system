dispatchApp.controller \caseEditCtrl, [\$scope, \$http, \$uibModalInstance, \globalVars, \loginInfo,
($scope, $http, $uibModalInstance, globalVars, loginInfo) ->

    $scope.close = !-> $uibModalInstance.dismiss(\cancel);

    api = globalVars.API

    # manage datepicker's opening status
    $scope.dpStatus = [opened: false]
    $scope.open = (index) -> $scope.dpStatus[index]?.opened = true

    # manage workdays
    $scope.addNewWorkday = (wd) ->
        tomorrow =
            begin: if wd.begin then new Date wd.begin.getTime! + (24 * 60 * 60 * 1000) else new Date!
            end: if wd.end then new Date wd.end.getTime! + (24 * 60 * 60 * 1000) else new Date!
        $scope.caseInfo.workday.push tomorrow
        $scope.dpStatus.push opened: false
    $scope.removeWorkday = (index) ->
        $scope.caseInfo.workday.splice index, 1
        $scope.dpStatus.splice index, 1

    $scope.confirm = (info) ->
        $http.post api.case.createCase, info
        .then (responseObj) ->
            res = responseObj.data
            if res.code == 200
                $scope.close!
            else
                console.log res.msg
        , (responseObj) ->

    # default values
    $scope.unitOpts =
        * item: \PAY_HOURLY
          value: \UNIT_HOURLY
        * item: \PAY_DAILY
          value: \UNIT_DAILY
        * item: \PAY_MONTHLY
          value: \UNIT_MONTHLY

    $scope.caseInfo =
        workday: [begin: new Date!, end: new Date!]
]