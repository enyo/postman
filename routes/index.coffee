

request = require "request"
url = require "url"
Request = require "../models/request"
convert = require "./convert"
config = require "config"



_loadAllRequests = (bookmarks, callback) ->
  query = Request
    .find()
    .sort("-_id")
    .limit(config.general.historyLength)
    .select("_id name formattedUrl")

  if bookmarks
    query.where("name").ne("").exists()
  else
    query.where("name").equals("")

  query.exec (err, docs) -> callback err, docs


# Renders the index site with given requestDoc
_showRequest = (requestDoc, req, res, next) ->
  _addHistory requestDoc, (err, doc) ->
    return next err if err?
    res.render "index",
      request: requestDoc


_addHistory = (object, callback) ->
  _loadAllRequests false, (err, requests) ->
    callback err if err?
    object._history = requests
    _loadAllRequests true, (err, requests) ->
      callback err if err?
      object._bookmarks = requests
      callback null, object



# Shows a dummy request
exports.index = (req, res, next) ->
  fakeRequest =
    protocol: "http"
    pathname: "/test"
    hostname: "localhost"
    method: "GET"
    port: config.general.port
    timeout: 10 # seconds
    body: '{ "name": "Postman" }'
    headers: [
      {
        name: "Content-Type"
        value: "application/json; charset=utf-8"
      }
      {
        name: "Accept"
        value: "application/json"
      }
      {
        name: "Accept-Charset"
        value: "ISO-8859-1,utf-8;q=0.7,*;q=0.3"
      }
      {
        name: "Accept-Encoding"
        value: "gzip,deflate,sdch"
      }
    ]

  _showRequest fakeRequest, req, res, next





# Shows a given rquest.
exports.request = (req, res, next) ->
  requestId = req.params?.id
  return next new Error "Invalid ID" unless requestId

  Request.findById requestId, (err, doc) ->
    return next err if err?
    return next new Error "Invalid ID" unless doc?
    if req.xhr
      _addHistory doc.toJSON(), (err, doc) ->
        return next err if err?
        res.send doc
    else
      _showRequest doc.toJSON(), req, res, next





# Actually perform the request and callback
doRequest = (requestDoc, callback) ->
  headers = convert.headerArrayToObject requestDoc.headers

  request {
    url: requestDoc.formattedUrl
    method: requestDoc.method
    body: requestDoc.body || null
    timeout: requestDoc.timeout * 1000
    headers: headers
    followRedirect: no
  }, (err, response, body) ->
    callback err, response, body


# Post a new request
exports.post = (req, res, next) ->

  requestData = req.body?.request
  return next new Error "Nothing submitted" unless requestData

  requestDoc = convert.postToDoc requestData

  requestDoc.save (err) ->
    return next err if err?

    onFinish = (doc) ->
      _addHistory doc.toJSON(), (err, doc) ->
        return next err if err?
        res.send doc

    if req.body.saveOnly
      onFinish requestDoc
    else
      doRequest requestDoc, (err, response, body) ->
        requestDoc.response = { } unless requestDoc.response?

        if err?
          requestDoc.response.error = err.code

        if response?
          requestDoc.response.statusCode = response.statusCode
          requestDoc.response.headers = convert.headerObjectToArray response.headers

        if body?
          requestDoc.response.body = body

        requestDoc.save (err) ->
          return next err if err?
          onFinish requestDoc




# To show a test request
exports.test = (req, res, next) ->
  data = currentTime: new Date().getTime()
  data.hello = req.body.name if req.body?.name?
  res.send data


