mongoose = require "mongoose"
ObjectId = mongoose.Schema.ObjectId



HeaderSchema = new mongoose.Schema
  name: String
  value: String


RequestSchema = new mongoose.Schema
  protocol: String
  hostname: String
  path: String
  port: Number
  method: String
  timeout: Number # Seconds
  query: String
  body: String
  headers: [HeaderSchema]
, strict: true


module.exports = mongoose.model "Request", RequestSchema