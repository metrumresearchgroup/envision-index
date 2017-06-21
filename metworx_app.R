gitHubRepo <- "https://raw.githubusercontent.com/metrumresearchgroup/envision-index/mastr"

remoteCodeSourced <- TRUE

for(script.i in c("global.R", "ui.R", "server.R")){
  try.i <- try(
    source(file.path(gitHubRepo, script.i))
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
      
      indexLinks <- shiny::tags$ul(style = "font-size:18px")
      
      for(app.i in apps){
        link.i <- file.path(clientURL, "envision", app.i, "")
        indexLinks <- tagAppendChild(indexLinks,
                                     tags$li(tags$a(href = link.i, target = "_blank", app.i)))
      }
      tagList(
        tags$h1("Index of /"),
        indexLinks
      )
    })
  }
  
  shinyApp(ui = fallBackUI, server = fallBackServer)
}
