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
    
    output$appTable <- renderUI({
      
      if(length(apps()) == 0){
        return(
          tags$h3(paste0("No Apps Found at ", globals$appsLoc))
        )
      }
      
      appTableFields <- c("", "name", "", "description", "author", "last_modified", "")
      
      appTableHTML <- tags$table(class = "table table-striped",
                                 style = "font-size:16px;")
      
      appTableHeadHTML <- tags$thead()
      
      for(table_field.i in c(appTableFields)){
        
        clean_name.i <- tools::toTitleCase(gsub("_", " ", table_field.i, fixed = TRUE))
        column_title.i <- tags$th(clean_name.i)
        
        appTableHeadHTML <- tagAppendChild(appTableHeadHTML, column_title.i)
      }
      
      appTableHTML <- tagAppendChild(appTableHTML, appTableHeadHTML)
      
      appTableBodyHTML <- tags$tbody()
      
      for(app.i in apps()){
        
        info.i <- file.info(file.path(globals$appsLoc, app.i))
        
        files.i <- list.files(file.path(globals$appsLoc, app.i), full.names = TRUE)
        
        if(length(files.i) > 0){
          #### exclude restart.txt
          difftime.i <- difftime(Sys.time(),
                                 max(do.call("rbind", lapply(files.i, file.info))$mtime))
          last_modified.i <- paste(round(as.numeric(difftime.i), 0), units(difftime.i), collapse = " ")
        }
        
        yaml_file.i <- file.path(globals$appsLoc,
                                 app.i,
                                 'envision-manifest',
                                 'app-info.yaml')
        
        if(file.exists(yaml_file.i)){
          
          yaml.i <- yaml::yaml.load_file(yaml_file.i)
          
          # icon is a special case
          if("icon" %in% names(yaml.i)){
            
            icon_file.i <-  file.path(globals$appsLoc,
                                      app.i,
                                      'envision-manifest',
                                      yaml.i$icon)
            
            if(file.exists(icon_file.i)){
              icon.i <- tags$img(src = icon_file.i)
            }
          }
          
          if("log_button" %in% names(yaml.i)){
            
            if(yaml.i$log_button){
              
              log_button.i <- tags$div(class = "text-right",
                                       tags$a(class="btn btn-warning metrum-log-button",
                                              id = app.i,
                                              tags$span(class = "glyphicon glyphicon-list-alt",
                                                        `aria-hidden` = "true"),
                                              "View Logs"))
            } else {
              log_button.i <- ""
            }
            
          }
          
          for(yaml_field.i in appTableFields[!(appTableFields %in% c("", "last_modified"))]){
            
            if(yaml_field.i %in% names(yaml.i)){
              
              value.i <- yaml.i[names(yaml.i) == yaml_field.i]
              
              assign(x = paste0(yaml_field.i, ".i"),
                     value = value.i,
                     envir = .GlobalEnv)
            }
          }
        }
        
        # fill in fields not found in yaml
        for(field.i in paste0(appTableFields[appTableFields != ""], ".i")){
        
          if(!exists(field.i)){
            
            # name is a special case (gets fill with in app name)
            if(field.i == "name.i"){
              
              assign(x = "name.i",
                     value = app.i,
                     envir = .GlobalEnv)
              next
            }
            # author is a special case (gets filled in with uname)
            if(field.i == "author.i"){
              
              assign(x = "author.i",
                     value = info.i$uname,
                     envir = .GlobalEnv)
              next
            }
            
            assign(x = field.i,
                   value = "",
                   envir = .GlobalEnv)
          }
        }
        
        launch_button.i <- tags$a(class="btn btn-primary",
                                  target = "_blank",
                                  href = file.path(clientURL(), "envision", app.i, ""),
                                  tags$span(class = "glyphicon glyphicon-new-window",
                                            `aria-hidden` = "true"),
                                  "Launch App")
        
        
        appTableBodyHTML <- tagAppendChild(appTableBodyHTML,
                                           tags$tr(tags$td(icon.i),
                                                   tags$td(name.i),
                                                   tags$td(launch_button.i),
                                                   tags$td(description.i),
                                                   tags$td(author.i),
                                                   tags$td(last_modified.i),
                                                   tags$td(log_button.i)))
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
