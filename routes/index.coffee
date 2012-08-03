

request = require "request"
url = require "url"


lastRequest = 
  protocol: "http"
  hostname: ""
  method: "POST"
  timeout: 120 # seconds
  headerName: [ "Content-Type" ]
  headerValue: [ "application/json; charset=utf-8" ]


exports.index = (req, res) ->
  res.render "index",
    title: "Express"
    request: lastRequest



exports.post = (req, res, next) ->

  requestData = req.body?.request
  return next new Error "Nothing submitted" unless requestData

  formattedUrl = url.format requestData

  lastRequest = requestData

  headers = { }
  for val, i in requestData.headerName
    headers[val] = requestData.headerValue[i]

  request {
    url: formattedUrl
    method: requestData.method
    body: requestData.body
    timeout: requestData.timeout * 1000
    headers: headers
  }, (err, response, body) ->
    content = if err? then err.message else body
    res.send "#{formattedUrl}\n#{content}"

  # res.send url.format requestData