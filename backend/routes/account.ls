# 3rd party module
require! \express
require! \mongoose
require! \path
require! \multer
# self module
MAIN_DIR = path.dirname require.main.filename
middleware = require MAIN_DIR + \/lib/dispatch-middleware
globalVars = require MAIN_DIR + \/lib/global-vars
CODE = globalVars.STATUS_CODE
# self db module
Account = require MAIN_DIR + \/lib/db-account

api = express.Router!

storage = multer.memoryStorage!
upload = multer do
            storage: storage
            limiits:
                fileSize: 3000 # bytes

api.route \/
.get middleware.loginRequired, (req, res) ->
    # list accounts, test api, should not open
    Account.getAccounts req.query.type, null, skip: req.query.skip, (err, accs) ->
        if err then res.json err else res.json accs
.post (req, res) ->
    # create a new account
    Account.createAccount req.body, (err) ->
        if err
        then res.json err
        else res.json code: CODE.S_OK

api.get \/current, middleware.loginRequired, (req, res) ->
    Account.getAccountByName req.session.loggedInUsername, (err, userInfo) ->
        if err
        then res.json err
        else res.json code: CODE.S_OK, userInfo: userInfo

api.get \/available, (req, res) ->
    Account.getAccountByName req.query.username, (err, userInfo) ->
        return res.json err if err
        res.json code: CODE.S_OK, available: if userInfo then false else true

api.route \/:username
.get middleware.loginRequired, (req, res) ->
    # get account by username
    Account.getAccountByName req.params.username, (err, userInfo) ->
        if err
        then res.json err
        else res.json code: CODE.S_OK, userInfo: userInfo

api.post \/login, (req, res) ->
    return res.json code: CODE.E_FAIL, msg: 'already logged in' if req.session.loggedInUsername
    Account.login req.body, (err, userInfo) ->
        return res.json err if err
        req.session.loggedInUsername = userInfo.username
        res.json code: CODE.S_OK, userInfo: userInfo

api.post \/logout, middleware.loginRequired, (req, res) ->
    delete req.session.loggedInUsername
    res.json code: CODE.S_OK

# headshot routes
api.route \/headshot/:id
.get (req, res) ->
    Account.getHeadshot req.params.id, (err, headshot) ->
        return res.status 403 .jsonp err if err
        res.type headshot.contentType .send headshot.content
.put middleware.loginRequired, upload.single(\headshot), (req, res) ->
    # upload and update the headshot image
    username = req.session.loggedInUsername
    Account.updateHeadshot req.file, req.params.id, username, (err, id) ->
        return res.json err if err
        res.json code: CODE.S_OK, id: id
.delete middleware.loginRequired, (req, res) ->
    # delete the headshot image
    username = req.session.loggedInUsername
    Account.deleteHeadshot req.params.id, username, (err) ->
        return res.json err if err
        res.json code: CODE.S_OK

api.post \/headshot, middleware.loginRequired, upload.single(\headshot), (req, res) ->
    # upload and store the headshot image
    Account.saveHeadshot req.file, req.session.loggedInUsername, (err, id) ->
        return res.json err if err
        res.json code: CODE.S_OK, id: id


module.exports = api