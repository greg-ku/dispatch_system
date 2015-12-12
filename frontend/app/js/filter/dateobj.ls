angular.module \date-obj-filter, [] .filter \dateobj, [\$filter, ($filter) ->
    (input, filterStr) -> 
        date = new Date input
        $filter(\date)(date.getTime!, filterStr)
]
