require! express
app = express!

# configures
env = process.env.NODE_ENV || "development";
switch env
case "development"
    app.use express.static __dirname + "/_public"

app.listen 8080