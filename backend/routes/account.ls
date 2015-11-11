require! crypto
require! mongoose

Account = mongoose.model \Account

# password encrypt function
encrypt = (pw) -> crypto.createHmac \sha256, pw .digest \hex

exports.create = (req, res) ->
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
            return

        new Account {
            Type: acc.type,
            Name: acc.name,
            Email: acc.email,
            Password: acc.pw
        }
        .save (err) ->
            if err
                console.log 'create account error'
                res.send err
                return
            res.json code: 200


exports.login = (req, res) ->
    acc = {}

    # check parameter existence
    if req.body.username == undefined or req.body.password == undefined
        return

    acc.name = req.body.username
    acc.pw = encrypt req.body.password

    Account.find Name: acc.name, (err, accs) ->
        res.send err if err
        if accs.length != 1 or accs[0]?.Password != acc.pw
            res.json code: 401, msg: 'incorrect username or password'
        else
            res.json code: 200
