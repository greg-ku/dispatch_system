# 3rd party module
require! \mongoose
require! \path
# self module
MAIN_DIR = path.dirname require.main.filename
globalVars = require "#{MAIN_DIR}/lib/global-vars"
# self db module
Account = require "#{MAIN_DIR}/lib/db-account"

CODE = globalVars.STATUS_CODE
Schema = mongoose.Schema

# schemas
CaseSchema = new Schema do
    company: String
    title: String
    description: String
    salary:
        payment: Number
        unit: String
    position: String
    workday: [Begin: Date, End: Date]
    owner: Schema.Types.ObjectId
    ownerName: String
    totalRequired: Number
    candidates: [
        id: Schema.Types.ObjectId
        status: String
    ]
    createDate: { type: Date, default: Date.now }
    updated: { type: Date, default: Date.now }

# models
Case = module.exports = mongoose.model \Case, CaseSchema

paramsNeeded =
    \title
    \description
    \payment
    \paymentUnit
    \position
    \totalRequired
    \workday

# public functions
Case.createCase = (caseIns, username, callback) ->
    # check parameter existence
    return callback code: CODE.E_FAIL, msg: 'incorrect parameter' if !caseIns or !username
    for p, i in paramsNeeded
        return callback code: CODE.E_FAIL, msg: 'incorrect parameter' if !caseIns[p]

    Account.getAccountByName username, (err, acc) ->
        return callback err if err
        return callback code: CODE.E_FAIL, msg: 'account not found' if !acc
        return callback code: CODE.E_FAIL, msg: 'not a company acc' if acc.type != \COMPANY
        new Case do
            company: acc.profile.companyName
            title: caseIns.title
            description: caseIns.description
            salary:
                payment: caseIns.payment
                unit: caseIns.paymentUnit
            position: caseIns.position
            workday: caseIns.workday
            owner: acc._id
            ownerName: acc.username
        .save (err, caseSaved) ->
            return callback err if err
            # add case to user info
            acc.ownCases.push caseSaved._id
            err <- acc.save
            return callback err if err
            callback null, caseSaved._id

Case.getCases = (conditions, options, callback) ->
    conditions = conditions || {}
    options = options || {}

    # do not return 'description' field when it fetch multiple cases
    projection = paramsNeeded.filter((str) -> str != \description).join ' '
    Case.find conditions, projection, skip: options.skip, limit: 10, (err, cases) ->
        if err then callback err else callback null, cases

Case.getCaseById = (id, callback) ->
    return callback code: CODE.E_FAIL, msg: 'incorrect parameter' if !id

    Case.findById id, (err, _case) ->
        return callback err if err
        return callback code: CODE.E_FAIL, msg: 'case not found' if !_case
        callback null, _case
