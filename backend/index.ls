require! \express
require! \body-parser
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
    app.use express.static __dirname + "/_public"
    app.use bodyParser.json!
    app.use bodyParser.urlencoded extended: true

# APIs
app.post \/account, account.create
app.post \/login, account.login

# bootstrap server
app.listen 8080
console.log 'server up'