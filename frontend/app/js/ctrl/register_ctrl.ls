dispatchApp.controller \registerCtrl, [\$scope, \$modalInstance, \$http, \globalVars, ($scope, $modalInstance, $http, globalVars) ->
    $scope.close = !-> $modalInstance.dismiss(\cancel);

    api = globalVars.API

    PROMPT = globalVars.PROMPT

    $scope.LENGTH =
        NAME:
            MIN: 4
            MAX: 40
        PW:
            MIN: 6
            MAX: 100
        EMAIL: 100
        GENERAL: 100

    # default values
    $scope.regType = \PERSONAL
    $scope.acc = {}

    $scope.setErrorMsg = (target, msg) ->
        # remove name available message
        $scope.nameAvailableTarget = '' if target == \username or target == \company
        # show error message
        $scope.errMsg = msg
        $scope.errTarget = target

    $scope.showNameAvailable = (target) ->
        # remove all error message
        $scope.errTarget = '' if $scope.errTarget == \username
        $scope.nameAvailableTarget = target

    $scope.checkNameUsed = (target, name) ->
        if !$scope.checkUsernameValid name
            return

        # disable input
        $scope.requesting = true

        $http.get api.account.available, params: { username: name }
        .then (responseObj) -> # success callback
            res = responseObj.data
            if res.code == 200 and res.available
                $scope.showNameAvailable target
            else if res.code == 200 and !res.available
                $scope.setErrorMsg target, PROMPT.NAME_USED
            else if res.code != 200
                $scope.setErrorMsg res.errTarget, res.msg
            $scope.requesting = false
        , (responseObj) -> # error callback
            $scope.requesting = false

    $scope.checkUsernameValid = (name) ->
        if !name or !name.length or name.length < $scope.LENGTH.NAME.MIN
            $scope.setErrorMsg \username, PROMPT.INCORRECT_NAME_LENGTH
            return false
        if !/^\w[\w.-]+$/.test name
            $scope.setErrorMsg \username, PROMPT.INVALID_CHAR
            return false
        return true

    $scope.checkPasswordValid = (acc) ->
        if !acc.password?.length or acc.password.length < $scope.LENGTH.PW.MIN
            $scope.setErrorMsg \password, PROMPT.INCORRECT_PW_LENGTH
            return false
        if !/^[\w.-]+$/.test acc.password
            $scope.setErrorMsg \password, PROMPT.INVALID_CHAR
            return false
        if acc.password != acc.confirmPw
            $scope.setErrorMsg \confirmPw, PROMPT.PW_NOT_CONFIRM
            return false
        return true

    $scope.checkParam = (acc) ->
        if !acc
            return false

        if !$scope.checkUsernameValid acc.username
            return false

        if !$scope.checkPasswordValid acc
            return false

        if $scope.regType == \PERSONAL
            if !acc.firstName or !acc.lastName
                $scope.setErrorMsg \realname, PROMPT.SHOULD_NOT_EMPTY
                return false
            if acc.firstName.length > $scope.LENGTH.GENERAL or acc.lastName.length > $scope.LENGTH.GENERAL
                $scope.setErrorMsg \realname, PROMPT.CHAR_TOO_LONG
                return false
        else if $scope.regType == \COMPANY
            if !acc.companyName
                $scope.setErrorMsg \company, PROMPT.SHOULD_NOT_EMPTY
                return false
            if acc.companyName.length > $scope.LENGTH.GENERAL
                $scope.setErrorMsg \company, PROMPT.CHAR_TOO_LONG
                return false

        if !globalVars.isEmail acc.email
            $scope.setErrorMsg \email, PROMPT.WRONG_EMAIL_FORMAT
            return false
        return true

    $scope.registerAcc = (acc) ->
        if !$scope.checkParam acc
            return

        # all checking passed
        $scope.errTarget = ''

        delete acc.confirmPw
        delete acc.firstName if $scope.regType != \PERSONAL
        delete acc.lastName if $scope.regType != \PERSONAL
        delete acc.companyName if $scope.regType != \COMPANY
        acc.type = $scope.regType

        $scope.requesting = true
        $http.post api.account.create, acc
        .then (responseObj) -> # success callback
            res = responseObj.data
            # TODO: a better way to show success
            if res.code == 200
                alert 'register success'
                $scope.close!
            else if res.code != 200 and res.msg
                $scope.setErrorMsg res.errTarget, res.msg
            $scope.requesting = false
        , (responseObj) -> # error callback
            # error handle
            $scope.requesting = false
]
