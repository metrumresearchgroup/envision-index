appRepo <- "https://raw.githubusercontent.com/metrumresearchgroup/envision-index/master"

remoteCodeSourced <- TRUE

for(script.i in c("global.R", "ui.R", "server.R")){
  try.i <- try(
    source(file.path(appRepo, script.i))
  )
  
  if(class(try.i) == "try-error"){
    remoteCodeSourced <- FALSE
  }
}

runRemoteApp <- remoteCodeSourced & exists("globals") & exists("ui") & exists("server")

if(runRemoteApp){
  shinyApp(ui = ui, server = server)
  
} else {
  
  fallBackUI <- fluidPage(uiOutput("shinyServerApps"))
  
  fallBackServer <- function(input, output, session){
    
    output$shinyServerApps <- renderUI({
      clientURL <- paste0(session$clientData$url_protocol, "//", session$clientData$url_hostname)
      apps <- sort(list.dirs('/data/shiny-server', recursive = FALSE, full.names = FALSE))
      notApps <- c("index")
      indexLinks <- tags$ul(style = "font-size:18px")
      
      for(app.i in apps[!(apps %in% notApps)]){
        link.i <- file.path(clientURL, "envision", app.i, "")
        indexLinks <- tagAppendChild(indexLinks,
                                     tags$li(tags$a(href = link.i, app.i)))
      }
      tagList(
        tags$h1("Envision Apps"),
        indexLinks
      )
    })
  }
  
  shinyApp(ui = fallBackUI, server = fallBackServer)
}
