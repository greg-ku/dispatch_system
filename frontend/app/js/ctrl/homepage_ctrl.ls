dispatchApp.controller \homepageCtrl, [\$scope, \$http, \globalVars, ($scope, $http, globalVars) ->
    api = globalVars.API

    # default values
    $scope.cases = []
    skip = 0

    $http.get api.case.getCases, params: { skip: skip }
    .then (responsiveObj) ->
        res = responsiveObj.data
        if res.code == 200
            $scope.cases = $scope.cases.concat res.cases
            skip += res.cases.length
    , (responsiveObj) ->
        # error handle
]
