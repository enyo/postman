
url = require "url"
Request = require "../models/request"


keys = [
  "name"
  "protocol"
  "pathname"
  "port"
  "hostname"
  "method"
  "timeout"
  "search"
  "body"
]


exports.postToDoc = (object) ->
  requestDoc = new Request

  for key in keys
    requestDoc[key] = object[key]

  requestDoc.headers = ({ name: header.name, value: header.value } for header in object.headers when header.name)


  urlInfo =
    protocol: requestDoc.protocol
    hostname: requestDoc.hostname
    port: requestDoc.port
    search: requestDoc.search
    pathname: requestDoc.pathname

  requestDoc.formattedUrl = url.format urlInfo

  requestDoc


exports.headerObjectToArray = (headers) ->
  { name: key, value: val } for key, val of headers when key

exports.headerArrayToObject = (headers) ->
  obj = { }
  for header in headers
    obj[header.name] = header.value if header.name
  obj

