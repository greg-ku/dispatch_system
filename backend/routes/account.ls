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
    acc = {}
    acc.type = req.body.type
    acc.username = req.body.username
    acc.firstName = req.body.firstName if acc.type == \PERSONAL
    acc.lastName = req.body.lastName if acc.type == \PERSONAL
    acc.companyName = req.body.company if acc.type == \COMPANY
    acc.email = req.body.email
    acc.password = encrypt req.body.password

    Account.createAccount acc, (err) ->
        if err
        then res.json err
        else res.json code: CODE.S_OK

api.post \/login, (req, res) ->
    acc = {}
    acc.username = req.body.username
    acc.password = encrypt req.body.password

    Account.login acc, (err, userInfo) ->
        if err
        then res.json err 
        else
            req.session.loggedInUsername = userInfo.username
            res.json code: CODE.S_OK, userInfo: userInfo

api.post \/logout, middleware.loginRequired, (req, res) ->
    acc = {}
    acc.username = req.session.loggedInUsername

    Account.logout acc, (err) ->
        if err
        then res.json err 
        else
            delete req.session.loggedInUsername
            res.json code: CODE.S_OK

api.get \/available, (req, res) ->
    Account.isAccountAvailable req.query.username, (err) ->
        if err
        then res.json err
        else res.json code: CODE.S_OK

api.get \/current, middleware.loginRequired, (req, res) ->
    Account.getAccountByName req.session.loggedInUsername, (err, userInfo) ->
        if err
        then res.json err
        else res.json code: CODE.S_OK, userInfo: userInfo

module.exports = api