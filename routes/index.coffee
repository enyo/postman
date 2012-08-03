

request = require "request"
url = require "url"
Request = require "../models/request"
convert = require "./convert"



exports.index = (req, res) ->
  res.render "index",
    request:
      protocol: "http"
      pathname: "/"
      hostname: "localhost"
      method: "GET"
      port: 80
      timeout: 10 # seconds
      headers: [
        {
          name: "Content-Type"
          value: "application/json; charset=utf-8"
        }
      ]




exports.request = (req, res, next) ->
  requestId = req.params.id
  return next new Error "Invalid ID" unless requestId

  Request.findById requestId, (err, doc) ->
    return next err if err?
    return next new Error "Invalid ID" unless doc?
    res.render "index",
      request: doc




doRequest = (requestDoc, callback) ->
  headers = convert.headerArrayToObject requestDoc.headers

  request {
    url: requestDoc.formattedUrl
    method: requestDoc.method
    body: requestDoc.body
    timeout: requestDoc.timeout * 1000
    headers: headers
    followRedirect: no
  }, (err, response, body) ->
    callback err, response, body



exports.post = (req, res, next) ->

  requestData = req.body?.request
  return next new Error "Nothing submitted" unless requestData


  requestDoc = convert.postToDoc requestData

  requestDoc.save (err) ->
    return next err if err?
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
        res.send requestDoc
