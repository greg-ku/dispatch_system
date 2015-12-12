# 3rd party module
require! mongoose
Schema = mongoose.Schema
require! \path
# self module
MAIN_DIR = path.dirname require.main.filename
globalVars = require MAIN_DIR + \/lib/global-vars
CODE = globalVars.STATUS_CODE

ProfileSchema = new Schema {
    firstName: String
    lastName: String
    companyName: String
    headShotUrl: String
}

AccountSchema = new Schema {
    type: String
    username: String
    password: String
    eamil: String
    profile: ProfileSchema
    ownCases: [Schema.Types.ObjectId]
    createDate: { type: Date, default: Date.now }
}

CaseSchema = new Schema {
    title: String
    discription: String
    salary:
        payment: Number
        unit: String
    position: String
    workday: [Begin: Date, End: Date]
    owner: Schema.Types.ObjectId
    candidates: [Schema.Types.ObjectId]
    createDate: { type: Date, default: Date.now }
    updated: { type: Date, default: Date.now }
}

mongoose.model \Profile, ProfileSchema
mongoose.model \Case, CaseSchema
Account = module.exports = mongoose.model \Account, AccountSchema

# public functions
Account.createAccount = (acc, callback) ->
    # check parameter existence
    if (acc.type != \PERSONAL and acc.type != \COMPANY
        or acc.type == \PERSONAL and (!acc.firstName or !acc.lastName)
        or acc.type == \COMPANY and !acc.companyName
        or !acc.username or !acc.email or !acc.password)
        callback code: CODE.E_FAIL, msg: 'incorrect parameter'
        return

    # TODO: one email only able to register one account
    Account.find username: acc.username, (err, accs) ->
        if err 
            return callback err
        if accs.length
            return callback code: CODE.E_FAIL, msg: 'account name exist'

        new Account {
            type: acc.type
            username: acc.username
            email: acc.email
            password: acc.password
            profile: 
                firstName: acc.firstName
                lastName: acc.lastName
                companyName: acc.companyName
        }
        .save (err) ->
            if err
            then callback err
            else callback!

Account.login = (acc, callback) ->
    # check parameter existence
    if acc.username == undefined or acc.password == undefined
        return callback code: CODE.E_FAIL, msg: 'incorrect parameter'

    Account.find username: acc.username, (err, accs) ->
        if err
            callback err
        else if accs.length != 1 or accs[0]?.password != acc.password
            callback code: CODE.E_INVALID_ARGUMENT, msg: 'incorrect username or password'
        else
            callback null, accs[0]

Account.logout = (acc, callback) ->
    Account.find username: acc.username, (err, accs) ->
        if err
            return callback err

        if accs.length == 1
        then callback!
        else callback code: CODE.E_FAIL, msg: 'logout failed'

Account.isAccountAvailable = (username, callback) ->
    # check parameter existence
    if username == undefined
        return callback code: CODE.E_INVALID_ARGUMENT

    Account.find username: username, (err, accs) ->
        if err
            return callback err

        if accs.length == 1
        then callback null, available: false, code: CODE.S_OK
        else callback null, available: true, code: CODE.S_OK

Account.getAccountByName = (username, callback) ->
    # check parameter existence
    if username == undefined
        return callback code: CODE.E_INVALID_ARGUMENT

    Account.find username: username, (err, accs) ->
        if err
            return callback err

        if accs.length == 1
        then callback null, accs[0]
        else callback code: CODE.E_FAIL

Account.getAccounts = (type, conditions, options, callback) ->
    conditions = conditions || {}
    options = options || {}

    # check parameter existence
    if type != \PERSONAL and type != \COMPANL
        return callback code: CODE.E_FAIL, msg: 'incorrect parameter'

    Account.find {}, null, skip: options.skip, limit: 10, (err, accs) ->
        if err then callback err else callback null, accs
