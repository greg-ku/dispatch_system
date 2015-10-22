describe('main', function() {
    var scope, ctrl, modalInstance;
 
    beforeEach(module('dispatchApp'));

    beforeEach(inject(function($controller, $rootScope, $translate, $http) {
        scope = $rootScope.$new();
        modalInstance = {
            close: jasmine.createSpy('modalInstance.close'),
            dismiss: jasmine.createSpy('modalInstance.dismiss'),
            result: {
                then: jasmine.createSpy('modalInstance.then'),
            }
        };
        ctrl = $controller('languageCtrl', {
            $scope: scope,
            $translate: $translate,
            $modalInstance: modalInstance,
            $http: $http
        });
    }));

    it('should select English', function() {
        expect(scope.selectedLang.value).toBe('en-US');
    });
});