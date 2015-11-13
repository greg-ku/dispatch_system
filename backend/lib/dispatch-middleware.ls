# 3rd party module
require! \path
# self module
MAIN_DIR = path.dirname require.main.filename
globalVars = require MAIN_DIR + \/lib/global-vars
CODE = globalVars.STATUS_CODE

dispatchMiddleware = {}

dispatchMiddleware.loginRequired = (req, res, next) ->
    if !req.session.logined
        res.json code: CODE.E_AUTH_FAILED
        return
    next!

module.exports = dispatchMiddleware