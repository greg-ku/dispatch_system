# 3rd party module
require! \express
require! \cookie-session
require! \body-parser
# self module
middleware = require \./lib/dispatch-middleware
app = express!

# db
require \./lib/db

# routes
routesDir = \./routes
account = require routesDir + \/account

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
app.post \/account, middleware.loginRequired, account.create
app.post \/login, account.login
app.post \/logout, middleware.loginRequired, account.logout

# bootstrap server
app.listen 8080
console.log 'server up'