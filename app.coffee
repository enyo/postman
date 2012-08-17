###
Module dependencies.
###
express = require "express"
routes = require "./routes"
http = require "http"
path = require "path"
config = require "config"
mongoose = require "mongoose"
nib = require "nib"

app = express()

app.configure ->
  mongoose.connect config.mongoose.connectPath

  app.set "port", process.env.PORT or config.general.port
  app.set "views", __dirname + "/views"
  app.set "view engine", "jade"
  app.use express.favicon()
  app.use express.logger("dev")
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router
  app.use express.static(path.join(__dirname, "public"))
  app.use require("connect-assets")(src: "#{__dirname}/assets", buildDir: "#{__dirname}/cache/built-assets")

  RedisStore = require("connect-redis")(express)

  app.use express.session
    store: new RedisStore
      socket: config.session.redisSocket
      host: "localhost"
    secret: config.session.secret



app.configure "development", ->
  app.use express.errorHandler()

app.get "/", routes.index
app.get "/test", routes.test
app.get "/:id", routes.request
app.delete "/:id", routes.delete
app.post "/post", routes.post


http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")
