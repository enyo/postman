
Formwatcher.defaultOptions.ajax = true
Formwatcher.defaultOptions.responseCheck = ->
  true
Formwatcher.defaultOptions.onSuccess = (response) ->
  response = JSON.parse response

  headers = ("<tr><td>#{key}</td><td>#{val}</td></tr>" for key,val of response.response.headers).join("")

  body = response.body

  try
    body = JSON.stringify JSON.parse(body), null, " "
  catch e
    yes

  $("#responses").append $ """
                          <section class="response">
                            <header><table>#{headers}</table></header>
                            <div class="body">#{body}</div>
                          </section>
                          """
  


window.postman =
  clear: ->
    $("#responses").html ""
  
