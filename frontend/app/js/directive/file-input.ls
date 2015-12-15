angular.module \file-input-directive, [] .directive \fileInput, ->
    link = (scope, element, attrs) ->
        btn = element.find \a
        fileInput = element.find \input

        btn.on \click, (event) -> fileInput[0].click!

        fileInput.on \change, (event) -> scope.change file: fileInput[0].files[0]

    # return object
    restrict: \E
    transclude: true
    template:
        '<a class="btn btn-default upload-headshot-input">' +
            '<span ng-transclude></span>' +
        '</a>' +
        '<input type="file" class="hidden-file-input">'
    scope:
        change: '&onChange'
    link: link
