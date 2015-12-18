angular.module \select-emulation-directive, [] .directive \selectEmulation, ->
    link = (scope, element, attrs) ->
        scope.select = (i) ->
            scope.selected = scope.options[i]
            scope.selectedValue = scope.options[i].value

        # init seelcted
        if scope.selectedValue
            scope.options.forEach (opt) -> scope.selected = opt if scope.selectedValue == opt.value
        else
            scope.select 0


    # return object
    restrict: \E
    transclude: true
    template:
        '<div class="btn-group">' +
            '<button class="btn btn-default" data-toggle="dropdown">{{ selected.item | translate }}</button>' +
            '<button class="btn btn-default dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">' +
                '<span class="caret"></span>' +
                '<span class="sr-only">Toggle Dropdown</span>' +
            '</button>' +
            '<ul class="dropdown-menu">' +
                '<li ng-repeat="opt in options track by $index"><a href="" ng-click="select($index)">{{opt.item | translate }}</a></li>' +
            '</ul>' +
        '</div>'
    scope:
        'options': '='
        'selectedValue': '=selectedValue'
    link: link
