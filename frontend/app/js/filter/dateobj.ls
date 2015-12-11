angular.module \date-obj-filter, [] .filter \dateobj, ->
    (input, filterStr) ->
        return '' if !input
        date = new Date input
        return date.toString! if !filterStr
        filterStr = filterStr.replace \yyyy, date.getFullYear!
        filterStr = filterStr.replace \MM, if (date.getMonth! + 1 < 10) then \0 + date.getMonth! + 1 else date.getMonth! + 1
        filterStr = filterStr.replace \dd, if (date.getDate! < 10) then \0 + date.getDate! else date.getDate!
        filterStr = filterStr.replace \HH, if (date.getHours! + 1 < 10) then \0 + date.getHours! + 1 else date.getHours! + 1
        filterStr = filterStr.replace \mm, if (date.getMinutes! + 1 < 10) then \0 + date.getMinutes! + 1 else date.getMinutes! + 1
        filterStr = filterStr.replace \ss, if (date.getSeconds! + 1 < 10) then \0 + date.getSeconds! + 1 else date.getSeconds! + 1
