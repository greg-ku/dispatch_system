# 3rd party module
require! \mongoose
require! \crypto
require! \path
# self module
MAIN_DIR = path.dirname require.main.filename
globalVars = require "#{MAIN_DIR}/lib/global-vars"

CODE = globalVars.STATUS_CODE
Schema = mongoose.Schema

# password encrypt function
encrypt = (pw) -> crypto.createHmac \sha256, pw .digest \hex

# schemas
HeadshotSchema = new Schema {
    content: Buffer
    contentType: String
    owner: Schema.Types.ObjectId
}

AccountSchema = new Schema {
    type: String
    username: String
    password: String
    email: String
    profile:
        firstName: String
        lastName: String
        companyName: String
        headshotUrl: String
    ownCases: [Schema.Types.ObjectId]
    createDate: { type: Date, default: Date.now }
}

# models
Headshot = mongoose.model \Headshot, HeadshotSchema
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
        return callback err if err
        return callback code: CODE.E_FAIL, msg: 'account name exist' if accs.length

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
        .save (err, accSaved) ->
            if err
            then callback err
            else callback null, accSaved._id

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
    return callback code: CODE.E_INVALID_ARGUMENT, msg: 'incorrect parameter' if !username

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

    Account.find conditions, null, skip: options.skip, limit: 10, (err, accs) ->
        if err then callback err else callback null, accs

# headshot functions
Account.saveHeadshot = (img, username, callback) ->
    return callback code: CODE.E_FAIL, msg: 'empty image' if !img
    return callback code: CODE.E_FAIL, msg: 'empty username' if !username

    Account.find username: username, (err, accs) ->
        return callback err if err
        return callback code: CODE.E_FAIL, msg: 'account not found' if !accs.length
        return callback code: CODE.E_FAIL, msg: 'already had headshot' if accs[0].profile.headshotUrl
        new Headshot do
            content: img.buffer
            contentType: img.mimetype
            owner: accs[0]._id
        .save (err, headshot) ->
            return callback err if err
            # set headshot url
            accs[0].profile.headshotUrl = "/api/account/headshot/#{headshot._id}"
            err <- accs[0].save
            if err
            then callback err
            else callback null, headshot._id

Account.updateHeadshot = (img, imgId, username, callback) ->
    return callback code: CODE.E_FAIL, msg: 'incorrect parameter' if !img or !imgId or !username
    Headshot.findById imgId, (err, headshot) ->
        return callback err if err
        return callback code: CODE.E_FAIL, msg: 'headshot not found' if !headshot
        err, acc <- Account.findById headshot.owner
        return callback err if err
        return callback code: CODE.E_FAIL, msg: 'not image\'s owner' if !acc or acc.username != username
        headshot.content = img.buffer
        headshot.contentType = img.mimetype
        err, savedImg <- headshot.save
        return callback err if err
        callback null, savedImg._id

Account.deleteHeadshot = (id, username, callback) ->
    return callback code: CODE.E_FAIL, msg: 'incorrect parameter' if !id or !username
    Headshot.findById id, (err, headshot) ->
        return callback err if err
        return callback code: CODE.E_FAIL, msg: 'headshot not found' if !headshot
        err, acc <- Account.findById headshot.owner
        return callback err if err
        return callback code: CODE.E_FAIL, msg: 'not image\'s owner' if !acc or acc.username != username
        err, deletedImg <- headshot.remove
        return callback err if err
        acc.profile.headshotUrl = ''
        err <- acc.save
        return callback err if err
        callback null, deletedImg

Account.getHeadshot = (id, callback) ->
    return callback code: CODE.E_FAIL, msg: 'empty account id' if !id

    Headshot.findById id, (err, headshot) ->
        return callback err if err
        return callback code: CODE.E_FAIL, msg: 'headshot not found' if !headshot
        callback null, headshot
