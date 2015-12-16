# 3rd party module
require! \express
require! \cookie-session
require! \body-parser
require! \mongoose

app = express!

# routes
ROUTES_DIR = \./routes
account = require ROUTES_DIR + \/account
cases = require ROUTES_DIR + \/case

# configures
env = process.env.NODE_ENV || "development";
switch env
case "development"
    # static files
    app.use express.static __dirname + "/_public"
    # body parser
    app.use bodyParser.json!
    app.use bodyParser.urlencoded extended: true
    # session
    app.use cookieSession do
        name: \session
        keys: [ \DispatchSignToken, \DisPatchVerifyToken ]

# APIs
app.use \/api/account, account
app.use \/api/case, cases

# connect to database
mongoose.connect \mongodb://localhost/dispatch-dev

# bootstrap server
app.listen 8080
console.log 'server up'