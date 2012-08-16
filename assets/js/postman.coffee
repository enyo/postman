
reqwest = require "reqwest"
bean = require "bean"

escapeHtml = (unsafe) ->
  unsafe
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#039;")



requestKeys = [
  "name"
  "formattedUrl"
  "protocol"
  "hostname"
  "pathname"
  "port"
  "timeout"
  "search"
  "body"
  "method" # Works even with selects
]


window.postman =

  loading: no

  history: [ ]

  clear: ->
    $("#requests").html ""


  # Loads the request and shows it.  
  loadRequest: (id) ->
    @loading = yes
    $("#loading").addClass "visible"
    reqwest
      url: "/#{id}"
      type: "json"
      method: "get"
      success: (request) =>
        @showRequest request

      error: (err) =>
        alert "Error loading request #{id}. Status: #{err.status}"

      complete: =>
        @loading = no
        $("#loading").removeClass "visible"


  updateHistory: (@history) ->
    historyContainer = $ ".history-elements"
    historyContainer.html ""
    for request in history
      do (request) =>
        link = $ """<a class="history-request" href="javascript:undefined;">#{request.name || request.formattedUrl}</a>"""
        bean.add link.get(0), "click", => @loadRequest request._id
        historyContainer.append link

  # Inserts all fields to show the request
  showRequest: (request, fromHistory = false) ->

    @updateHistory request._history

    $("form *[name='request[name]']").val ""
    for key in requestKeys
      if key == "name"
        $("form h2#request-name span").text request[key]
      else
        $("form *[name='request[#{key}]']").val "#{request[key] || ""}"

    $("form input.header-name").val ""
    $("form input.header-value").val ""

    for header, i in request.headers
      $("form [name='request[headers][#{i}][name]']").val "#{header.name || ""}"
      $("form [name='request[headers][#{i}][value]']").val "#{header.value || ""}"

    responseContainer = $   """
                            <section class="request">
                              <header>
                                  <div class="url"><h3>#{request.formattedUrl ? ""}</h3></div>
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

    if request._id
      permaLink = "/#{request._id}"
      responseHeader.append $ """<div class="permaLink"><a href="#{permaLink}">Permalink</a></div>""" 
    
    
    if request.response?
      responseHeader.append $ """<div class="error">#{request.response.error}</div>""" if request.response.error


      headers = ("<tr><td>#{header.name}</td><td>#{header.value}</td></tr>" for header in request.response.headers).join("")
      headers = "<table><tr><td>Status Code:</td><td>#{request.response.statusCode}</td></tr>#{headers}</table>"

      responseHeaders.append headers

      if request.response.body
        body = request.response.body
        try
          body = JSON.stringify JSON.parse(body), null, " "
        catch e
          yes

        responseBody.html escapeHtml body

      responseContainer.append $ """<hr />"""
      
    $("#requests").html responseContainer

    unless fromHistory
      history.pushState request, request.formattedUrl, permaLink if permaLink

    window.onpopstate = (event) =>
      @showRequest event.state, yes if event?.state?

  

