
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


  reqwest: (options) ->
    return if @loading

    @loading = yes
    $("#loading").addClass "visible"

    error = options.error
    complete = options.complete
    options.error = (err) =>
      alert "Error loading request #{id}. Status: #{err.status}"
      error err if error?
    options.complete = =>
      @loading = no
      $("#loading").removeClass "visible"
      complete() if complete?

    reqwest options


  # Loads the request and shows it.  
  loadRequest: (id) ->
    @reqwest
      url: "/#{id}"
      type: "json"
      method: "get"
      success: (request) =>
        @showRequest request


  deleteRequest: (id) ->
    @reqwest
      url: "/#{id}"
      type: "json"
      method: "delete"
      success: (response) =>
        @updateHistory response._history
        @updateBookmarks response._bookmarks

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
        row = $ """<div class="row"><div class="ten columns"><a class="link" href="javascript:undefined;">#{request.name || request.formattedUrl}</a></div><div class="two column"><a href="javascript:undefined;" class="delete right">✖</a></div></div>"""
        link = $ ".link", row
        deleteLink = $ ".delete", row
        bean.add link.get(0), "click", => @loadRequest request._id
        bean.add deleteLink.get(0), "click", => @deleteRequest request._id
        container.append row



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
      responseHeader.append $ """<div class="errosr">#{request.response.error}</div>""" if request.response.error

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

  

