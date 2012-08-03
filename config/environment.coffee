express = require "express"
mongoose = require "mongoose"
crypto = require "crypto"
fs = require "fs"
config = require "config"



module.exports = (app) ->

  mongoose.connect config.mongoose.connectPath
  app.configure ->
    app.use express.logger()  if config.general.useLogger
    app.set "packageInfo", JSON.parse(fs.readFileSync(__dirname + "/../package.json", "utf8"))
    app.use express.favicon(__dirname + "/../public/images/favicon.ico")
    app.set "views", __dirname + "/../views"
    app.set "view engine", "jade"
    app.dynamicHelpers messages: require("express-messages")
    app.helpers
      moment: require("moment")

      # Creates the url for a thumbnail including hash
      createThumbnailUrl: (fileId, width, height, method = "crop", extension = "jpg") ->
        path = "#{method}/#{fileId}-#{width}x#{height}.#{extension}"
        hash = crypto.createHash("md5").update(path + config.general.imageSecret).digest("hex")
        "/" + path + "?hash=" + hash

      createResizeHash: (width, height, method = "crop") ->
        crypto.createHash("md5").update("#{method}-#{width}x#{height}" + config.general.imageSecret).digest("hex")

      version: app.set("packageInfo").version
      publicUrl: config.general.publicUrl
      imageSecret: config.general.imageSecret
      environment: process.env.ENV_VARIABLE

    app.use express.bodyParser(uploadDir: config.uploadDir)
    app.use express.methodOverride()
    app.use express.cookieParser()

  app.configure "noredis", -> app.use express.session(secret: config.session.secret)

  app.configure "development", "production", ->
    RedisStore = require("connect-redis")(express)

    app.use express.session
      store: new RedisStore
        socket: "/tmp/redis.sock"
        host: "localhost"
      secret: config.session.secret

  app.configure ->
    app.use app.router
    app.use require("connect-assets")(buildDir: "cache/built_assets")
    day = 1000 * 60 * 60 * 24
    app.use express.static "#{__dirname}/../public", maxAge: day
    app.use express.static __dirname + "/.." + config.paths.resizedCacheDir, maxAge: day
    app.use require("../lib/node-shrink")(
      cachePath: __dirname + "/.." + config.paths.resizedCacheDir
      tmpPath: __dirname + "/.." + config.paths.tmpDir
      secret: config.general.imageSecret
    )

  app.configure "development", "noredis", ->
    app.use express.errorHandler
      dumpExceptions: true
      showStack: true

    app.set "view options",
      layout: false
      pretty: true

  app.configure "production", ->
    app.use express.errorHandler()
    app.set "view options", layout: false