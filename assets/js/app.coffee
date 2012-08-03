
Formwatcher.defaultOptions.ajax = true
Formwatcher.defaultOptions.responseCheck = ->
  true


escapeHtml = (unsafe) ->
  unsafe
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#039;");


Formwatcher.defaultOptions.onSuccess = (response) ->
  response = JSON.parse response

  responseContainer = $   """
                          <section class="response">
                            <header>
                                <div class="url"><h3>#{response.url}</h3></div>
                            </header>
                            <div class="row">
                              <div class="five columns headers">
                              </div>
                              <div class="seven columns body">
                              </div>
                          </section>
                          """

  responseHeader = responseContainer.find "header"
  responseHeaders = responseContainer.find ".headers"
  responseBody = responseContainer.find ".body"


  if response.requestId?
    permaLink = "/#{response.requestId}"
    responseHeader.append $ """<div class="permaLink"><a href="#{permaLink}">Permalink</a></div>""" 
  
  if response.error
    responseHeader.append $ """<div class="error">#{response.error.code}</div>"""
  else

    headers = ("<tr><td>#{key}</td><td>#{val}</td></tr>" for key,val of response.headers).join("")
    headers = "<table>#{headers}</table>"

    responseHeaders.append headers

    body = response.body
    try
      body = JSON.stringify JSON.parse(body), null, " "
    catch e
      yes

    responseBody.html escapeHtml body

    console.log escapeHtml body

  responseContainer.append $ """<hr />"""
    
  $("#responses").prepend responseContainer

  history.pushState { requestId: response.requestId }, response.url, permaLink if permaLink
  window.onpopstate = (event) ->
    console.log event.state

window.postman =
  clear: ->
    $("#responses").html ""
  
