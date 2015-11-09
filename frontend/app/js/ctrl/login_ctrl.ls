dispatchApp.controller \loginCtrl, [\$scope, \$modalInstance, ($scope, $modalInstance) ->
    $scope.close = !-> $modalInstance.dismiss(\cancel);
]
