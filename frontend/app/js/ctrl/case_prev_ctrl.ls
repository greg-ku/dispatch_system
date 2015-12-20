dispatchApp.controller \casePrevCtrl, [\$scope, \$http, \$sce, \$routeParams, \$uibModalInstance, \globalVars,
($scope, $http, $sce, $routeParams, $uibModalInstance, globalVars) ->

    $scope.close = !-> $uibModalInstance.dismiss(\cancel);

    api = globalVars.API

    $scope.caseInfo = {}

    if $routeParams.id
        $http.get "#{api.case.getCase}/#{$routeParams.id}"
        .then (responseObj) ->
            res = responseObj.data
            if res.code == 200
                if res.caseInfo.description
                    res.caseInfo.description = res.caseInfo.description.replace /\n/g, '<br>' if res.caseInfo.description
                    $scope.caseInfo = res.caseInfo
                    $scope.sceDescription = $sce.trustAsHtml res.caseInfo.description
        , (responseObj) ->
            # error handle
]