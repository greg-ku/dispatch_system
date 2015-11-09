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

    $scope.openLangModal = ->
        modalInstance = $modal.open do
            animation: true
            templateUrl: \language_modal.html
            controller: \languageCtrl
]
