# 3rd party module
require! \express
require! \crypto
require! \mongoose
require! \path
# self module
MAIN_DIR = path.dirname require.main.filename
middleware = require MAIN_DIR + \/lib/dispatch-middleware

api = express.Router!

Account = mongoose.model \Account

# password encrypt function
encrypt = (pw) -> crypto.createHmac \sha256, pw .digest \hex

api.post \/, middleware.loginRequired, (req, res) ->
    acc = {}
    acc.type = req.body.type

    # check parameter existence
    if acc.type != \PERSONAL and acc.type != \COMPANY
        return
    if acc.type == \PERSONAL and req.body.username == undefined
        return
    if acc.type == \COMPANY and req.body.company == undefined
        return
    if req.body.email == undefined or req.body.password == undefined
        return

    acc.name = req.body.username if acc.type == \PERSONAL
    acc.name = req.body.company if acc.type == \COMPANY
    acc.email = req.body.email
    acc.pw = encrypt req.body.password

    Account.find Name: acc.name, (err, accs) ->
        res.send err if err
        if accs.length
            console.log 'account name exist'
            res.json code: 405, msg: 'account name exist'
            return

        new Account {
            Type: acc.type
            Name: acc.name
            Email: acc.email
            Password: acc.pw
        }
        .save (err) ->
            if err
                console.log 'create account error'
                res.send err
                return
            res.json code: 200

api.post \/login, (req, res) ->
    # check parameter existence
    if req.body.username == undefined or req.body.password == undefined
        return

    acc = {}
    acc.name = req.body.username
    acc.pw = encrypt req.body.password

    Account.find Name: acc.name, (err, accs) ->
        res.send err if err
        if accs.length != 1 or accs[0]?.Password != acc.pw
            res.json code: 404, msg: 'incorrect username or password'
            return
        req.session.logined = true
        res.json code: 200

api.post \/logout, middleware.loginRequired, (req, res) ->
    # check parameter existence
    if req.body.username == undefined
        res.json code: 400
        return

    acc = {}
    acc.name = req.body.username

    Account.find Name: acc.name, (err, accs) ->
        res.send err if err
        if accs.length == 1
            req.session.logined = false
            res.json code: 200
        else
            res.json code: 405, msg: 'logout failed'

module.exports = api