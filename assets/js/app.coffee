
#= require tabs
#= require postman

Formwatcher.defaultOptions.ajax = true
Formwatcher.defaultOptions.responseCheck = ->
  true

Formwatcher.defaultOptions.onSuccess = (request) ->
  request = JSON.parse request
  postman.showRequest request

