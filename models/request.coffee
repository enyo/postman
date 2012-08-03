mongoose = require "mongoose"
ObjectId = mongoose.Schema.ObjectId



HeaderSchema = new mongoose.Schema
  name: String
  value: String

RequestSchema = new mongoose.Schema
  formattedUrl: String
  protocol: String
  hostname: String
  pathname: String
  port: Number
  method: String
  timeout: Number # Seconds
  search: String
  body: String
  headers: [HeaderSchema]
  response:
    headers: [HeaderSchema]
    body: String
    statusCode: Number
    error: String
, strict: true


module.exports = mongoose.model "Request", RequestSchema