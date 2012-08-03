
Formwatcher.defaultOptions.ajax = true
Formwatcher.defaultOptions.responseCheck = ->
  true
Formwatcher.defaultOptions.onSuccess = (response) ->
  $("#response").append $ "<pre>#{response}</pre>"
  


window.postman =
  clear: ->
    $("#response").html ""
  
