# 3rd party module
require! \express
require! \crypto
require! \mongoose
require! \path
# self module
MAIN_DIR = path.dirname require.main.filename
middleware = require MAIN_DIR + \/lib/dispatch-middleware
globalVars = require MAIN_DIR + \/lib/global-vars
CODE = globalVars.STATUS_CODE
# self db module
Account = require MAIN_DIR + \/lib/db-account

api = express.Router!

# password encrypt function
encrypt = (pw) -> crypto.createHmac \sha256, pw .digest \hex

api.route \/
.get middleware.loginRequired, (req, res) ->
    # list accounts, test api, should not open
    Account.getAccounts req.query.type, null, skip: req.query.skip, (err, accs) ->
        if err then res.json err else res.json accs
.post (req, res) ->
    # create a new account
    acc = req.body
    acc.password = encrypt req.body.password if req.body.password

    Account.createAccount acc, (err) ->
        if err
        then res.json err
        else res.json code: CODE.S_OK

api.post \/login, (req, res) ->
    acc = req.body
    acc.password = encrypt req.body.password

    Account.login acc, (err, userInfo) ->
        return res.json err if err
        req.session.loggedInUsername = userInfo.username
        res.json code: CODE.S_OK, userInfo: userInfo

api.post \/logout, middleware.loginRequired, (req, res) ->
    delete req.session.loggedInUsername
    res.json code: CODE.S_OK

api.get \/available, (req, res) ->
    Account.getAccountByName req.query.username, (err, userInfo) ->
        return res.json err if err
        res.json code: CODE.S_OK, available: if userInfo then false else true

api.get \/current, middleware.loginRequired, (req, res) ->
    Account.getAccountByName req.session.loggedInUsername, (err, userInfo) ->
        if err
        then res.json err
        else res.json code: CODE.S_OK, userInfo: userInfo

module.exports = api