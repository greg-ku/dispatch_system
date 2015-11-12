dispatchMiddleware = {}

dispatchMiddleware.loginRequired = (req, res, next) ->
    if !req.session.logined
        res.json code: 401
        return
    next!

module.exports = dispatchMiddleware