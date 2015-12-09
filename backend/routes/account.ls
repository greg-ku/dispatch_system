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

api = express.Router!

Account = mongoose.model \Account

# password encrypt function
encrypt = (pw) -> crypto.createHmac \sha256, pw .digest \hex

api.route \/
.get middleware.loginRequired, (req, res) ->
    # list accounts, test api, should not open

    # check parameter existence
    if (req.query.type != \PERSONAL and req.query.type != \COMPANL
        or req.query.skip == undefined)
        res.json code: CODE.E_FAIL, msg: 'incorrect parameter'
        return

    Account.find {}, null, skip: req.query.skip, limit: 10, (err, accs) ->
        res.send err if err
        res.json accs

.post (req, res) ->
    # create a new account
    acc = {}
    acc.type = req.body.type

    # check parameter existence
    if (acc.type != \PERSONAL and acc.type != \COMPANY
        or acc.type == \PERSONAL and (req.body.firstName == undefined or req.body.lastName == undefined)
        or acc.type == \COMPANY and req.body.companyName == undefined
        or req.body.username == undefined or req.body.email == undefined or req.body.password == undefined)
        res.json code: CODE.E_FAIL, msg: 'incorrect parameter'
        return

    acc.username = req.body.username
    acc.firstName = req.body.firstName if acc.type == \PERSONAL
    acc.lastName = req.body.lastName if acc.type == \PERSONAL
    acc.companyName = req.body.company if acc.type == \COMPANY
    acc.email = req.body.email
    acc.pw = encrypt req.body.password

    # TODO: one email only able to register one account
    Account.find username: acc.username, (err, accs) ->
        res.send err if err
        if accs.length
            console.log 'account name exist'
            res.json code: CODE.E_FAIL, msg: 'account name exist'
            return

        new Account {
            type: acc.type
            username: acc.username
            email: acc.email
            password: acc.pw
            profile: 
                firstName: acc.firstName
                lastName: acc.lastName
                companyName: acc.companyName
        }
        .save (err) ->
            if err
                console.log 'create account error'
                res.send err
                return
            res.json code: CODE.S_OK

api.post \/login, (req, res) ->
    # check parameter existence
    if req.body.username == undefined or req.body.password == undefined
        return

    acc = {}
    acc.username = req.body.username
    acc.pw = encrypt req.body.password

    Account.find username: acc.username, (err, accs) ->
        res.send err if err
        if accs.length != 1 or accs[0]?.password != acc.pw
            res.json code: CODE.E_INVALID_ARGUMENT, msg: 'incorrect username or password'
            return
        req.session.loggedInUsername = accs[0].username
        res.json code: CODE.S_OK, userInfo: accs[0]

api.post \/logout, middleware.loginRequired, (req, res) ->
    # check parameter existence
    if req.body.username == undefined
        res.json code: CODE.E_INVALID_ARGUMENT
        return

    acc = {}
    acc.username = req.body.username

    Account.find username: acc.username, (err, accs) ->
        res.send err if err
        if accs.length == 1
            delete req.session.loggedInUsername
            res.json code: CODE.S_OK
        else
            res.json code: CODE.E_FAIL, msg: 'logout failed'

api.get \/available, (req, res) ->
    # check parameter existence
    if req.query.username == undefined
        res.json code: CODE.E_INVALID_ARGUMENT
        return

    Account.find username: req.query.username, (err, accs) ->
        res.send err if err
        if accs.length == 1
            res.json do
                available: false
                code: CODE.S_OK
        else
            res.json do
                available: true
                code: CODE.S_OK

api.get \/current, middleware.loginRequired, (req, res) ->
    Account.find username: req.session.loggedInUsername, (err, accs) ->
        res.send err if err
        if accs.length == 1
            res.json do
                userInfo: accs[0]
                code: CODE.S_OK
        else
            res.json code: CODE.E_FAIL

module.exports = api