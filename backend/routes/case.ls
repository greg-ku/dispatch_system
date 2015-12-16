# 3rd party module
require! \express
require! \mongoose
require! \path
require! \multer
# self module
MAIN_DIR = path.dirname require.main.filename
mw = require MAIN_DIR + \/lib/dispatch-middleware
globalVars = require MAIN_DIR + \/lib/global-vars
CODE = globalVars.STATUS_CODE
# self db module
Case = require MAIN_DIR + \/lib/db-case

api = express.Router!

storage = multer.memoryStorage!
upload = multer do
            storage: storage
            limiits:
                fileSize: 3000 # bytes

api.route \/
.get (req, res) ->
    # list cases
    skip = req.query.skip
    delete req.query.skip if skip != undefined

    Case.getCases req.query, skip: skip, (err, cases) ->
        res.json if err then err else code: CODE.S_OK, cases: cases
.post mw.loginRequired, (req, res) ->
    # create new case
    Case.createCase req.body, req.session.loggedInUsername, (err, caseId) ->
        res.json if err then err else code: CODE.S_OK, id: caseId

module.exports = api
