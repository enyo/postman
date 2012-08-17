
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


$.domReady -> postman.init()


window.postman =

  loading: no

  history: [ ]
  bookmarks: [ ]

  init: ->
    bookmarksLink = $ "#history .sub-nav .bookmarks a"
    historyLink = $ "#history .sub-nav .history a"

    bean.add $("#request-links .sub-nav .bookmarks a"), "click", ->
    bean.add $("#request-links .sub-nav .history a"), "click", ->
    @showRequest window.request if window.request



  clear: ->
    $("#request").html ""


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
    container = $ "#request-links #history-tab"
    @_updateRequestLinks container, @history

  updateBookmarks: (@bookmarks) ->
    container = $ "#request-links #bookmarks-tab"
    @_updateRequestLinks container, @bookmarks

  _updateRequestLinks: (container, requests) ->
    container.html ""
    for request in requests
      do (request) =>
        link = $ """<a href="javascript:undefined;">#{request.name || request.formattedUrl}</a>"""
        bean.add link.get(0), "click", => @loadRequest request._id
        container.append link



  # Inserts all fields to show the request
  showRequest: (request, fromHistory = false) ->

    @updateHistory request._history
    @updateBookmarks request._bookmarks

    $("form *[name='request[name]']").val ""
    for key in requestKeys
      if key == "name"
        $("h2#request-name span").text request[key] || ""
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
                                <div class="five columns">
                                  <div class="headers"></div>
                                </div>
                                <div class="seven columns">
                                  <div class="body"></div>
                                </div>
                            </section>
                            """

    responseHeader = responseContainer.find "header"
    responseHeaders = responseContainer.find ".headers"
    responseBody = responseContainer.find ".body"


    if request._id
      permaLink = "/#{request._id}"

    if request.response?
      responseHeader.append $ """<div class="error">#{request.response.error}</div>""" if request.response.error

      headers = request.response.headers
      headers = [
        { name: "Formatted URL", value: request.formattedUrl || "" }
        { name: "Status Code", value: request.response.statusCode }
      ].concat headers
      headers = [{ name: "Postman link", value: """<a href="#{permaLink}">#{permaLink}</a>""" }].concat headers if permaLink

      headers = ("""<tr><td class="name"><div>#{header.name}</div></td><td class="value"><div>#{header.value}</div></td></tr>""" for header in headers).join("")
      headers = "<table>#{headers}</table>"

      responseHeaders.append headers

      if request.response.body
        body = request.response.body
        try
          body = JSON.stringify JSON.parse(body), null, " "
        catch e
          yes

        responseBody.html escapeHtml body

      responseContainer.append $ """<hr />"""
      
    $("#request").html responseContainer

    unless fromHistory
      history.pushState request, request.formattedUrl, permaLink if permaLink

    window.onpopstate = (event) =>
      @showRequest event.state, yes if event?.state?

  

