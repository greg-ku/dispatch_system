dispatchApp.controller \homepageCtrl, [\$scope, \$http, \$uibModal, \globalVars, \loginInfo,
($scope, $http, $uibModal, globalVars, loginInfo) ->

    api = globalVars.API

    # default values
    $scope.userInfo = loginInfo.getUserInfo!
    $scope.cases = []
    $scope.isFetchEnabled = true
    $scope.lastUpdatedDate = null
    $scope.noMore = false

    $scope.openCaseEditModal = ->
        modalInstance = $uibModal.open do
            animation: true
            templateUrl: \case_edit_modal.html
            controller: \caseEditCtrl
            size: \lg

    # redirect to preview url
    $scope.previewCase = (id) -> location.hash = "#/case/#{id}?r=#{Date.now!}"

    # callback of updating login info
    updateLoginInfo = -> $scope.userInfo = loginInfo.getUserInfo!

    fetchCases = (params) ->
        $scope.isFetchEnabled = false
        $http.get api.case.getCases, params: params
        .then (responsiveObj) ->
            res = responsiveObj.data
            if res.code == 200
                if res.cases?.length
                    $scope.lastUpdatedDate = res.cases[res.cases.length - 1].updated 
                    $scope.cases = $scope.cases.concat res.cases
                else
                    $scope.noMore = true

            $scope.isFetchEnabled = true
        , (responsiveObj) ->
            # error handle
            $scope.isFetchEnabled = true

    $scope.moreCases = (str) -> $scope.searchCases str
    $scope.refreshCases = (str) -> $scope.searchCases str, true
    $scope.searchCases = (str, erase) ->
        if erase
            $scope.noMore = false
            $scope.cases = []
            $scope.lastUpdatedDate = null
        search = str.replace /[\s\t,;]+/g, ',' if str
        fetchCases updated: $scope.lastUpdatedDate, search: search

    # registering login info callback
    loginInfo.register updateLoginInfo
    # unregistering login info callback in destructor
    $scope.$on \$destroy, -> loginInfo.unregister updateLoginInfo

    fetchCases!
]
