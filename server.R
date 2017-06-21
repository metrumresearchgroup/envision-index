server <- shinyServer(
  function(input, output, session) {
    
    # App Table ---------------------------------------------------------------
    
    clientURL <- reactive({
      paste0(session$clientData$url_protocol,
             "//",
             session$clientData$url_hostname)
    })
    
    output$appTable <- renderUI({
      
      appTableHTML <- tags$table(class = "table table-striped",
                                 style = "font-size:16px;",
                                 tags$thead(tags$tr(tags$th("Name"),
                                                    tags$th("Author"),
                                                    # tags$th("Size (bytes)"),
                                                    tags$th("Last Modified"),
                                                    tags$th(""))))
      appTableBodyHTML <- tags$tbody()
      
      for(app.i in globals$apps){
        
        info.i <- file.info(file.path('/data', 'shiny-server', app.i))
        name.i <- tagList(
          tags$a(href = file.path(clientURL(), "envision", app.i, ""),
                 # target = "_blank",   
                 app.i)# ,
          # tags$span(style = "color:#686868",
          #           class = "glyphicon glyphicon-new-window", `aria-hidden` = "true")
        )
        
        author.i <- info.i$uname
        # size.i <- info.i$size
        
        files.i <- list.files(file.path('/data', 'shiny-server', app.i), full.names = TRUE)
        if(length(files.i) > 0){
          difftime.i <- difftime(Sys.time(), max(do.call("rbind", lapply(files.i, file.info))$mtime)) #### exclude restart.txt
          modified.i <- paste(round(as.numeric(difftime.i), 0), units(difftime.i), collapse = " ")
        } else {
          modified.i <- ""
        }
        
        logButton.i <- tags$div(class = "text-right",
                                tags$a(class="btn btn-warning btn-xs metrum-log-button",
                                       id = app.i,
                                       "View Log"))
        
        appTableBodyHTML <- tagAppendChild(appTableBodyHTML,
                                           tags$tr(tags$td(name.i),
                                                   tags$td(author.i),
                                                   # tags$td(size.i),
                                                   tags$td(modified.i),
                                                   tags$td(logButton.i)))
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
        
        updateSelectInput(session, 'logFile', choices = "No Logs Found")
        
      } else {
        
        appLogs <- logs[grepl(input$logApp, logs)]
        userAppLogs <- appLogs[grepl(globals$user, appLogs)]
        
        if(length(userAppLogs) > 0){
          
          userAppLogsInfo <- do.call("rbind", lapply(file.path(input$logDir, userAppLogs), file.info))
          newestUserAppLog <- rownames(userAppLogsInfo)[order(userAppLogsInfo$mtime, decreasing = TRUE)][1]
          
          updateSelectInput(session,
                            'logFile',
                            choices = appLogs,
                            selected = gsub(paste0(input$logDir, "/"), "", newestUserAppLog))
        } else {
          
          updateSelectInput(session, 'logFile', choices = appLogs)
        }
      }
    })
    
    autoInvalidate <- reactiveTimer(1000, session = session)
    
    output$logContents <- renderPrint({
      req(input$logFile)
      
      if(input$liveStream & (input$logFile != "No Logs Found") & (input$indexDisplay == "logs")){
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
