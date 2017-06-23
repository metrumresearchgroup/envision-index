server <- shinyServer(
  function(input, output, session) {
    
    # App Table ---------------------------------------------------------------
    
    clientURL <- reactive({
      paste0(session$clientData$url_protocol,
             "//",
             session$clientData$url_hostname)
    })
    
    apps <- eventReactive(session, {
      message("apps refreshed")
      apps <- sort(list.dirs(globals$appsLoc,
                             recursive = FALSE, full.names = FALSE))
      apps[!(apps %in% c("index", "rmd"))]
    })
    
    output$appTable <- renderUI({
      
      if(length(apps()) == 0){
        return(
          tags$h3(paste0("No Apps Found at ", globals$appsLoc))
        )
      }
      
      appTableHTML <- tags$table(class = "table table-striped vertical-align",
                                 tags$thead(style = "font-size:18px;",
                                            tags$tr(tags$th("Name"),
                                                    tags$th(""),
                                                    tags$th("Author"),
                                                    # tags$th("Size (bytes)"),
                                                    tags$th("Last Modified"),
                                                    tags$th(""))))
      appTableBodyHTML <- tags$tbody()
      
      for(app.i in apps()){
        
        info.i <- file.info(file.path(globals$appsLoc, app.i))
        # name.i <- tagList(
        #   tags$a(href = file.path(clientURL(), "envision", app.i, ""),
        #          target = "_blank",
        #          app.i),
        # tags$span(style = "color:#C8C8C8;",
        #           class = "glyphicon glyphicon-new-window",
        #           `aria-hidden` = "true")
        # )
        name.i <- tags$div(
          style = "font-size:16px;",
          app.i
        )
        
        launch.i <- tags$a(class="btn btn-primary btn-lg",
                           target = "_blank",
                           href = file.path(clientURL(), "envision", app.i, ""),
                           tags$span(class = "glyphicon glyphicon-new-window",
                                     `aria-hidden` = "true"),
                           "Launch App")
        
        author.i <- info.i$uname
        # size.i <- info.i$size
        
        files.i <- list.files(file.path(globals$appsLoc, app.i), full.names = TRUE)
        if(length(files.i) > 0){
          difftime.i <- difftime(Sys.time(), max(do.call("rbind", lapply(files.i, file.info))$mtime)) #### exclude restart.txt
          modified.i <- paste(round(as.numeric(difftime.i), 0), units(difftime.i), collapse = " ")
        } else {
          modified.i <- ""
        }
        
        log.i <- tags$div(class = "text-right",
                                 tags$a(class="btn btn-warning metrum-log-button",
                                        id = app.i,
                                        tags$span(class = "glyphicon glyphicon-list-alt",
                                                  `aria-hidden` = "true"),
                                        "View Log"))
        
        appTableBodyHTML <- tagAppendChild(appTableBodyHTML,
                                           tags$tr(tags$td(name.i),
                                                   tags$td(launch.i),
                                                   tags$td(author.i),
                                                   # tags$td(size.i),
                                                   tags$td(modified.i),
                                                   tags$td(log.i)))
      }
      tagAppendChild(appTableHTML, appTableBodyHTML)
    })
    
    # Log  --------------------------------------------------------------------
    
    output$logAppName <- renderUI({
      tags$div(
        class = "text-center",
        tags$h1(style = "display:inline", input$logApp),
        tags$button(type="button", class="btn btn-link", id="defaultToolTip", `data-toggle`="tooltip", `data-placement`="bottom", title=
                      paste0("By default, the newest log for the current user (", globals$user, ") is displayed"), 
                    tags$span(style = "display:inline;font-size:8px;", class = "badge", "?")
        ),
        tags$script(
          '$("#defaultToolTip").tooltip();'
        )
      )
    })
    
    observe({
      req(input$logApp)
      logs <- list.files(input$logDir)
      
      if(length(logs) == 0){
        return(
          updateSelectInput(session, 'logFile', choices = "No Logs Found")
        )
      }
      
      appLogs <- logs[grepl(input$logApp, logs)]
      
      if(length(appLogs) == 0){
        message("no logs app")
        return(
          updateSelectInput(session, 'logFile', choices = "No Logs Found For This App")
        )
      }
      
      userAppLogs <- appLogs[grepl(globals$user, appLogs)]
      
      if(length(userAppLogs) == 0){
        return(
          updateSelectInput(session, 'logFile', choices = appLogs)
        )
      }
      
      userAppLogsInfo <- do.call("rbind", lapply(file.path(input$logDir, userAppLogs), file.info))
      newestUserAppLog <- rownames(userAppLogsInfo)[order(userAppLogsInfo$mtime, decreasing = TRUE)][1]
      
      updateSelectInput(session,
                        'logFile',
                        choices = appLogs,
                        selected = gsub(paste0(input$logDir, "/"), "", newestUserAppLog))
    })
    
    autoInvalidate <- reactiveTimer(1000, session = session)
    
    output$logContents <- renderPrint({
      req(input$logFile)
      
      if(input$liveStream & !grepl("No Logs Found", input$logFile) & (input$indexDisplay == "logs")){
        autoInvalidate()
      }
      
      logFilePath <- file.path(input$logDir, input$logFile)
      message(logFilePath)
      # Catch cases where the root path with selected file don't exist
      if(file.exists(logFilePath)){
        
        log <- tail(readLines(logFilePath), 200)
        writeLines(log)
      } else {
        # Reset to NULL so it stops trying to print
        updateSelectInput(session, inputId = "logFile", choices = NULL)
        writeLines("Log Not Found")
      }
      
    })
  }
)
