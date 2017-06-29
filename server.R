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
      appsDirs <- data.frame(AppDir = list.dirs(envisionGlobals$appsLoc, recursive = FALSE),
                             MTime = NA,
                             stringsAsFactors = FALSE)
      # Need modified time (mtime) at the file level (not directory level)
      for(appDir.i in appsDirs$AppDir){
        fileInfo.i <- do.call("rbind", lapply(list.files(appDir.i, full.names = TRUE), file.info))
        appsDirs$MTime[appsDirs$AppDir == appDir.i] <- max(fileInfo.i$mtime)
      }
      
      apps <- gsub(paste0(envisionGlobals$appsLoc, "/"), "", appsDirs$AppDir[rev(order(appsDirs$MTime))])
      apps[!(apps %in% c("index"))]
    })
    
    
    output$appTable <- renderUI({
      
      if(length(apps()) == 0){
        return(
          tags$h3(paste0("No Apps Found at ", envisionGlobals$appsLoc))
        )
      }
      
      appTableHTML <- tags$table(class = "table table-striped",
                                 style = "font-size:16px;")
      
      appTableHeadHTML <- tags$thead()
      appTableHTML <- tagAppendChild(appTableHTML, appTableHeadHTML)
      
      appTableBodyHTML <- tags$tbody()
      
      # Clear out old temp tiles
      lapply(list.files("www", full.names = TRUE), file.remove)
      
      for(app.i in apps()){
        
        # Set defaults
        app_options.i <- data.frame(EnvisionName = app.i, 
                                    EnvisionDescription = "",
                                    EnvisionViewLogs = TRUE,
                                    EnvisionTileLocation = "",
                                    EnvisionFlags = "",
                                    stringsAsFactors = FALSE)
        
        DESCRIPTION_file.i <- file.path(envisionGlobals$appsLoc, app.i, "DESCRIPTION")
        
        if(file.exists(DESCRIPTION_file.i)){
          DESCRIPTION_df.i <- as.data.frame(read.dcf(file = DESCRIPTION_file.i), stringsAsFactors = FALSE)
          
          for(column.i in colnames(app_options.i)){
            if(column.i %in% colnames(DESCRIPTION_df.i)){
              app_options.i[[column.i]] <- DESCRIPTION_df.i[[column.i]]
            }
          }
          
          app_options.i$Warnings <- ""
          
        } else {
          app_options.i$Warnings <- paste0("No description file found at:</br>", DESCRIPTION_file.i)
        }
        
        if(file.exists(app_options.i$EnvisionTileLocation)){
          
          temp_img_name.i <- paste0(app.i,
                                    "-temp-tile-",
                                    round(as.numeric(Sys.time()), 0),
                                    "-",
                                    basename(app_options.i$EnvisionTileLocation))
          file.copy(
            from = app_options.i$EnvisionTileLocation,
            to = paste0("/data/shiny-server/index/www/", temp_img_name.i)
          )
          
          tile_file.i <- temp_img_name.i
          
        } else {
          
          tile_file.i <- 
            "https://raw.githubusercontent.com/metrumresearchgroup/envision-index/master/img/default-icon.png"
        }
        
        tile.i <- tags$img(alt = "Tile Not Found", 
                           height = "140px",
                           width = "190px",
                           src = tile_file.i)
        
        ## Launch button
        launch_button.i <- tags$a(class="btn btn-primary btn-lg",
                                  target = "_blank",
                                  href = file.path(clientURL(), "envision", app.i, ""),
                                  tags$span(class = "glyphicon glyphicon-new-window",
                                            `aria-hidden` = "true"),
                                  "Launch App")
        
        ## Log button
        if(app_options.i$EnvisionViewLogs){
          log_button.i <- tags$div(class = "text-right",
                                   tags$a(class="btn btn-info metrum-log-button",
                                          id = app.i,
                                          tags$span(class = "glyphicon glyphicon-list-alt",
                                                    `aria-hidden` = "true"),
                                          "View Logs"))
          
        } else {
          log_button.i <- ""
        }
        
        if(app_options.i$Warnings != ""){
          warnings.i <- 
            tags$button(type="button",
                        class="btn btn-link appTableToolTip",
                        id=paste0(app.i, "-toolTip"),
                        `data-toggle`="tooltip",
                        `data-placement`="top",
                        title = paste0("<span style='font-weight:bold; font-size:16px;' >Envision Warning</span></br></br>", app_options.i$Warnings, "</br></br>For more info, click <b><a 'toolTipLink' href='http://metrumrg.com/' target='_blank'>here</a></b>"),
                        tags$span(style = "font-size:14px;", class = "badge alert-warning", HTML("&nbsp;!&nbsp;")))
        } else {
          warnings.i <- ""
        }
        
        appTableBodyHTML <- tagAppendChild(appTableBodyHTML,
                                           tags$tr(class = "", tags$td(tile.i),
                                                   tags$td(style = "font-size:24px;font-weight:bold;", app_options.i$EnvisionName),
                                                   tags$td(app_options.i$EnvisionDescription),
                                                   tags$td(launch_button.i),
                                                   tags$td(log_button.i),
                                                   tags$td(warnings.i)))
      }
      appsTable <- tagAppendChild(appTableHTML, appTableBodyHTML)
      
      tagList(
        appsTable,
        tags$script(
          '$(".appTableToolTip").tooltip({html: true, delay: { "show": 400, "hide": 1300 }});'
        )
      )
    })
    
    # Log  --------------------------------------------------------------------
    
    output$logAppName <- renderUI({
      tags$div(
        class = "text-center",
        tags$a(target = "_blank", href = file.path(clientURL(), "envision", input$logApp, ""), input$logApp),
        tags$button(type="button", class="btn btn-link", id="logToolTip", `data-toggle`="tooltip", `data-placement`="bottom",
                    title= paste0("By default, the newest log for the current user (", envisionGlobals$user, ") is displayed"), 
                    tags$span(style = "display:inline;font-size:8px;", class = "badge", "?")
        ),
        tags$script(
          '$("#logToolTip").tooltip();'
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
      
      userAppLogs <- appLogs[grepl(envisionGlobals$user, appLogs)]
      
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
  }
)
