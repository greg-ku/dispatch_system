# 3rd party module
require! \mongoose
require! \crypto
require! \path
# self module
MAIN_DIR = path.dirname require.main.filename
globalVars = require MAIN_DIR + \/lib/global-vars
CODE = globalVars.STATUS_CODE

Schema = mongoose.Schema

# password encrypt function
encrypt = (pw) -> crypto.createHmac \sha256, pw .digest \hex

HeadShotSchema = new Schema {
    content: Buffer
    contentType: String
}

ProfileSchema = new Schema {
    firstName: String
    lastName: String
    companyName: String
    headshotUrl: String
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
Headshot = mongoose.model \Headshot, HeadShotSchema
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
            password: encrypt acc.password
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
    if !acc.username or !acc.password
        return callback code: CODE.E_FAIL, msg: 'incorrect parameter'

    Account.find username: acc.username, (err, accs) ->
        if err
            callback err
        else if accs.length != 1 or accs[0]?.password != encrypt acc.password
            callback code: CODE.E_INVALID_ARGUMENT, msg: 'incorrect username or password'
        else
            callback null, accs[0]

Account.getAccountByName = (username, callback) ->
    # check parameter existence
    if !username
        return callback code: CODE.E_INVALID_ARGUMENT, msg: 'incorrect parameter'

    Account.find username: username, (err, accs) ->
        return callback err if err

        if accs.length == 1
        then callback null, accs[0]
        else callback!

Account.getAccounts = (type, conditions, options, callback) ->
    conditions = conditions || {}
    options = options || {}

    # check parameter existence
    if type != \PERSONAL and type != \COMPANL
        return callback code: CODE.E_FAIL, msg: 'incorrect parameter'

    Account.find {}, null, skip: options.skip, limit: 10, (err, accs) ->
        if err then callback err else callback null, accs

# headshot functions
Account.saveHeadshot = (img, accId, callback) ->
    return callback code: CODE.E_FAIL, msg: 'empty image' if !img
    return callback code: CODE.E_FAIL, msg: 'empty account id' if !accId

    Account.findById accId, (err, acc) ->
        return callback err if err
        return callback code: CODE.E_FAIL, msg: 'account not found' if !acc
        new Headshot do
            content: img.buffer
            contentType: img.mimetype
        .save (err, headshot) ->
            return callback err if err
            # set headshot url
            acc.profile.headshotUrl = \/api/account/headshot/ + headshot._id
            err <- acc.save
            callback if err then err else null

Account.updateHeadshot = (img, imgId, callback) ->
    return callback code: CODE.E_FAIL, msg: 'incorrect parameter' if !img or !imgId
    Headshot.findById imgId, (err, headshot) ->
        return callback err if err
        return callback code: CODE.E_FAIL, msg: 'headshot not found' if !headshot
        headshot.content = img.buffer
        headshot.contentType = img.mimetype
        err, savedImg <- headshot.save
        return callback err if err
        callback null, savedImg._id

Account.getHeadshot = (id, callback) ->
    return callback code: CODE.E_FAIL, msg: 'empty account id' if !id

    Headshot.findById id, (err, headshot) ->
        return callback err if err
        return callback code: CODE.E_FAIL, msg: 'headshot not found' if !headshot
        callback null, headshot
