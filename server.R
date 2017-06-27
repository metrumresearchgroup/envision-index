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
      apps[!(apps %in% c("index"))]
    })
    
    observeEvent(session, {
      
      www_files <- list.files("www")
      
      for(www_file.i in www_files){
        file.remove(file.path("www", www_file.i))
      }
      
    })
    
    output$appTable <- renderUI({
      
      if(length(apps()) == 0){
        return(
          tags$h3(paste0("No Apps Found at ", globals$appsLoc))
        )
      }
      
      appTableHTML <- tags$table(class = "table table-striped",
                                 style = "font-size:16px;")
      
      appTableHeadHTML <- tags$thead()
      
      appTableHeadHTML <-  tagAppendChild(appTableHeadHTML,
                                          tags$tr(tags$th(""),
                                                  tags$th("Name"),
                                                  tags$th("Description"),
                                                  tags$th(""),
                                                  # tags$th("Author"),
                                                  # tags$th("Last Modified"),
                                                  tags$th("")))
      
      appTableHTML <- tagAppendChild(appTableHTML, appTableHeadHTML)
      
      appTableBodyHTML <- tags$tbody()
      
      for(app.i in apps()){
        
        # Pull info to use to fill in author (if not provided), last save date, etc.
        info.i <- file.info(file.path(globals$appsLoc, app.i))
        
        yaml_file.i <- file.path(globals$appsLoc,
                                 app.i,
                                 "envision-manifest",
                                 "app-info.yaml")
        
        if(file.exists(yaml_file.i)){
          
          app_options.i <- yaml::yaml.load_file(yaml_file.i)
          
          ## Need to copy icon to index/www (if provided)
          if("icon" %in% names(app_options.i)){
            
            icon_file.i <-  file.path(globals$appsLoc,
                                      app.i,
                                      'envision-manifest',
                                      app_options.i$icon)
            
            file.copy(from = icon_file.i,
                      to = file.path('www', paste0(app.i, "-", app_options.i$icon)))
            
            # update where icon points to
            app_options.i$icon <- paste0(app.i, "-", app_options.i$icon)
          }
          
        }  else {
          
          # Provide default icon
          app_options.i <- list(
            icon = "https://raw.githubusercontent.com/metrumresearchgroup/envision-index/master/img/default-icon.png"
          )
        }
        
        ## Icon
        icon.i <- tags$img(alt = "Icon Not Found", 
                           height = "200px",
                           width = "200px",
                           src = app_options.i$icon)
        
        ## Name
        if("name" %in% names(app_options.i)){
          name.i <- app_options.i$name
        } else {
          name.i <- app.i
        }
        
        ## Launch button
        launch_button.i <- tags$a(class="btn btn-primary btn-lg",
                                  target = "_blank",
                                  href = file.path(clientURL(), "envision", app.i, ""),
                                  tags$span(class = "glyphicon glyphicon-new-window",
                                            `aria-hidden` = "true"),
                                  "Launch App")
        
        ## Author
        if("author" %in% names(app_options.i)){
          author.i <- app_options.i$author
        } else {
          author.i <- info.i$uname
        }
        
        ## Description
        if("description" %in% names(app_options.i)){
          description.i <- app_options.i$description
        } else {
          description.i <- ""
        }
        
        ## Log button
        log_button.i <- tags$div(class = "text-right",
                                 tags$a(class="btn btn-warning metrum-log-button",
                                        id = app.i,
                                        tags$span(class = "glyphicon glyphicon-list-alt",
                                                  `aria-hidden` = "true"),
                                        "View Logs"))
        
        ## clear out if option is set to false
        if("log_button" %in% names(app_options.i)){
          if(app_options.i$log_button == FALSE){
            log_button.i <- ""
          } 
        }
        
        ## Last Modified
        files.i <- list.files(file.path(globals$appsLoc, app.i), full.names = TRUE)
        
        if(length(files.i) > 0){
          difftime.i <- difftime(Sys.time(),
                                 max(do.call("rbind", lapply(files.i[files.i != "restart.txt"], file.info))$mtime))
          last_modified.i <- paste(round(as.numeric(difftime.i), 0), units(difftime.i), collapse = " ")
        } else {
          last_modified.i <- ""
        }
        
        appTableBodyHTML <- tagAppendChild(appTableBodyHTML,
                                           tags$tr(tags$td(icon.i),
                                                   tags$td(name.i),
                                                   tags$td(description.i),
                                                   tags$td(launch_button.i),
                                                   # tags$td(author.i),
                                                   # tags$td(last_modified.i),
                                                   tags$td(log_button.i)))
      }
      tagAppendChild(appTableHTML, appTableBodyHTML)
    })
    
    # Log  --------------------------------------------------------------------
    
    output$logAppName <- renderUI({
      tags$div(
        class = "text-center",
        tags$h1(style = "display:inline", input$logApp),
        tags$button(type="button", class="btn btn-link", id="defaultToolTip", `data-toggle`="tooltip", `data-placement`="bottom",
                    title= paste0("By default, the newest log for the current user (", globals$user, ") is displayed"), 
                    tags$span(style = "display:inline;font-size:8px;", class = "badge", "?")
        ),
        tags$script(
          '$("#defaultToolTip").tooltip();'
        )
      )
    })
    
    autoInvalidate <- reactiveTimer(1000, session = session)
    
    observe({
      req(input$logApp)
      
      # If no logs found, re-check every second
      if(!is.null(input$logFile)){
        if(grepl("No Logs Found", input$logFile) & (input$indexDisplay == "logs")){
          autoInvalidate()
        }
      }
      
      logs <- list.files(input$logDir)
      
      if(length(logs) == 0){
        return(
          updateSelectInput(session, 'logFile', choices = "No Logs Found")
        )
      }
      
      appLogs <- logs[grepl(input$logApp, logs)]
      
      if(length(appLogs) == 0){
        return(
          updateSelectInput(session, 'logFile', choices = "No Logs Found")
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
    
    output$logContents <- renderPrint({
      req(input$logFile)
      
      if(input$liveStream & !grepl("No Logs Found", input$logFile) & (input$indexDisplay == "logs")){
        autoInvalidate()
      }
      
      logFilePath <- file.path(input$logDir, input$logFile)
      
      # Catch cases where the root path with selected file does not exist
      if(file.exists(logFilePath)){
        
        log <- tail(readLines(logFilePath), 200)
        writeLines(log)
      } else {
        # Reset to NULL so it stops trying to print
        updateSelectInput(session, inputId = "logFile", choices = "No Logs Found")
        writeLines("")
      }
      
    })
    
    output$noLogWarning <- renderUI({
      if(grepl("No Logs Found", input$logFile)){
        
        tags$div(class="alert alert-warning container", role="alert",
                 tags$span(class = "glyphicon glyphicon-exclamation-sign", `aria-hidden` = "true"),
                 tags$span(class="sr-only", "Error:"),
                 "No logs were found. By default, logs are deleted when an Envision app stops running. To change this setting, see help file here: ."
        )
        
      }
    })
    
    observeEvent(input$envisionHelpModal, {
      showModal(modalDialog(
        size = "l",
        title = "Metworx EnvIsion Shiny-server",
        HTML("This dashboard is generated using the apps found in /data/shiny-server.<br><br> The additional information (Description, Icon, etc.) is stored in an envision-manifest folder. <br><br>Please see link <a href = 'www.google.com' target ='_blank'>here</a> for more help.")
      ))
    })
    
  }
)
