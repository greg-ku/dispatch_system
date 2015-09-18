templates = angular.module \templates, []

dispatchApp = angular.module \dispatchApp, [\ui.bootstrap, \templates]

dispatchApp.controller \dispatchCtrl, [\$scope, \$modal, ($scope, $modal) ->
	$scope.openLoginModal = ->
		modalInstance = $modal.open do
			animation: true
			templateUrl: \login_modal.html
			controller: \loginCtrl

	$scope.openRegisterModal = ->
		modalInstance = $modal.open do
			animation: true
			templateUrl: \register_modal.html
			controller: \registerCtrl
]

dispatchApp.controller \loginCtrl, [\$scope, \$modalInstance, ($scope, $modalInstance) ->
	$scope.close = !-> $modalInstance.dismiss(\cancel);
]

dispatchApp.controller \registerCtrl, [\$scope, \$modalInstance, ($scope, $modalInstance) ->
	$scope.close = !-> $modalInstance.dismiss(\cancel);
]