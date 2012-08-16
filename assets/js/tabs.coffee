
$ = ender



$.domReady ->

  $("dl.tabs").forEach (tabs) ->
    tabs = $ tabs
    allTabs = tabs.find("> dd")

    contentContainer = tabs.next()
    throw new Error "Tabs contentContainer not present." unless contentContainer.hasClass "tabs-content"
    allContents = contentContainer.find "> li"


    allTabs.forEach (tab) ->
      tab = $ tab
      tabLink = tab.find " > a"
      content = contentContainer.find "li#{tabLink.attr "href"}-tab"

      tabLink.click do (tab, content) ->
        ->
          allTabs.removeClass "active"
          allContents.removeClass "active"
          tab.addClass "active"
          content.addClass "active"
