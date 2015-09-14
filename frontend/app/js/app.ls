dispatchApp = angular.module \dispatchApp, ["ui.bootstrap"]

dispatchApp.controller \dispatchCtrl, [\$scope, \$modal, ($scope, $modal) ->
	$scope.test = "hello world!! Greg"

	$scope.openLoginModal = ->
		modalInstance = $modal.open do
			animation: true
			templateUrl: \login_modal.html
			controller: \loginCtrl
			# size: \sm
]

dispatchApp.controller \loginCtrl, [\$scope, \$modalInstance, ($scope, $modalInstance) ->
	$scope.close = !-> $modalInstance.dismiss(\cancel);
]