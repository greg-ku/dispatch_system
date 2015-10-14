describe('main', function() {
    beforeEach(module('dispatchApp'));

    beforeEach(inject(function($controller, $rootScope, $modal) {
        var scope = $rootScope.$new();
        var ctrl = $controller('dispatchCtrl', {$scope: scope, $modal: $modal});
    }));

    it('should select English', function() {
        expect(3).toBe(3);
    });
});