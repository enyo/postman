

request = require "request"
url = require "url"
Request = require "../models/request"




exports.index = (req, res) ->
  res.render "index",
    request:
      protocol: "http"
      pathname: "/"
      hostname: "localhost"
      method: "GET"
      port: 80
      timeout: 120 # seconds
      headerName: [ "Content-Type" ]
      headerValue: [ "application/json; charset=utf-8" ]



convertDocToObject = (doc) ->
  obj = {
    protocol: doc.protocol
    pathname: doc.path
    port: doc.port
    hostname: doc.hostname
    method: doc.method
    timeout: doc.timeout
    search: doc.query
    body: doc.query
    headerName: [ ]
    headerValue: [ ]
  }

  for header in doc.headers
    obj.headerName.push header.name
    obj.headerValue.push header.value

  obj



convertObjectToDoc = (object) ->
  requestDoc = new Request
  requestDoc.protocol = object.protocol
  requestDoc.path = object.pathname
  requestDoc.hostname = object.hostname
  requestDoc.port = object.port
  requestDoc.method = object.method
  requestDoc.timeout = object.timeout
  requestDoc.query = object.search
  requestDoc.body  = object.body
  requestDoc.headers = [ ]

  for val, i in object.headerName
    if val
      requestDoc.headers.push
        name: val
        value: object.headerValue[i]

  requestDoc



exports.request = (req, res, next) ->
  requestId = req.params.id
  return next new Error "Invalid ID" unless requestId

  Request.findById requestId, (err, doc) ->
    return next err if err?
    return next new Error "Invalid ID" unless doc?
    res.render "index",
      request: convertDocToObject doc




doRequest = (requestDoc, callback) ->

  urlInfo =
    protocol: requestDoc.protocol
    hostname: requestDoc.hostname
    port: requestDoc.port
    search: requestDoc.query
    pathname: requestDoc.path

  formattedUrl = url.format urlInfo

  headers = { }
  for header in requestDoc.headers
    headers[header.name] = header.value

  request {
    url: formattedUrl
    method: requestDoc.method
    body: requestDoc.body
    timeout: requestDoc.timeout * 1000
    headers: headers
  }, (err, response, body) ->
    callback err, response, body, formattedUrl



exports.post = (req, res, next) ->

  requestData = req.body?.request
  return next new Error "Nothing submitted" unless requestData


  requestDoc = convertObjectToDoc requestData

  requestDoc.save (err) ->
    return next err if err?
    doRequest requestDoc, (err, response, body, formattedUrl) ->
      responseObject =
        url: formattedUrl
        error: err
        requestId: requestDoc.id

      responseObject.headers = response.headers if response?
      responseObject.body = body if body?

      res.send responseObject
