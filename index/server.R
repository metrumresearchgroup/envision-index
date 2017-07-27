function(input, output, session) {
  
  rV <- reactiveValues()
  
  observeEvent(session, {
    ##  This entire block runs whenenver the page is refreshed
    
    rV$clientURL <- paste0(session$clientData$url_protocol, "//", session$clientData$url_hostname)
    
    rV$thisEnvisionUser <- Sys.info()[["user"]]
    
    passwd_df <- read.delim('/etc/passwd', sep = ":", header = FALSE, stringsAsFactors = FALSE)
    
    rV$envisionUsers <- passwd_df[passwd_df$V3 > 999 & passwd_df$V3 < 2000 & !(passwd_df$V1 %in% c("ubuntu", "piranajs", "sas")), ]
    
    rV$envisionDeveloper <- rV$envisionUsers$V1[which.min(rV$envisionUsers$V3)]
    
    rV$isDeveloper <- rV$thisEnvisionUser == rV$envisionDeveloper
  })
  
  output$envisionDeveloper <- renderUI({
    HTML(
    paste("User: ", rV$thisEnvisionUser, "</br>",
          "Developer: ", rV$envisionDeveloper, "</br>",
          "Is Developer: ", rV$isDeveloper)
    )
  })
  
  autoInvalidate <- reactiveTimer(1000, session = session)
  
  # App Table ---------------------------------------------------------------
  appsDF <- reactive({
    input$dismissAfterConfig
    
    shiny_server_directories <- list.dirs("../", recursive = FALSE, full.names = FALSE)
    not_apps <- c("index", ".git")
    apps <- shiny_server_directories[!(shiny_server_directories %in% not_apps)]
    
    apps_df <- data.frame(App = apps,
                          AppDir = file.path("../", apps),
                          MTime = NA,
                          HasDescription = NA,
                          EnvisionName = "",
                          EnvisionDescription = "",
                          EnvisionTileLocation = "default-tile.png",
                          EnvisionUsers = "all",
                          ShowThisUser = NA,
                          stringsAsFactors = FALSE)
    
    for(i in 1:nrow(apps_df)){
      
      files.i <- list.files(apps_df$AppDir[i], full.names = TRUE)
      file_info.i <- do.call("rbind", lapply(files.i[files.i != paste0(apps_df$AppDir[i], "/restart.txt")], file.info))
      apps_df$MTime[i] <- max(file_info.i$mtime)
      
      DESCRIPTION_location.i <- file.path(apps_df$AppDir[i], "DESCRIPTION")
      
      apps_df$HasDescription[i] <- file.exists(DESCRIPTION_location.i)
      
      if(apps_df$HasDescription[i]){
        
        DESCRIPTION_df.i <- as.data.frame(read.dcf(file = DESCRIPTION_location.i), stringsAsFactors = FALSE)
        
        for(column.i in colnames(DESCRIPTION_df.i)){
          
          if(!(column.i %in% colnames(apps_df))) next
          
          apps_df[[column.i]][i] <- DESCRIPTION_df.i[[column.i]]
        }
      }
      
      if(is.na(apps_df$EnvisionName[i])){
        apps_df$EnvisionName[i] <- apps_df$App[i]
      }
      
      apps_df$ShowThisUser[i] <- ifelse(
        grepl("all", apps_df$EnvisionUsers[i]) | rV$isDeveloper,
        TRUE,
        grepl(rV$thisEnvisionUser, apps_df$EnvisionUsers[i])
      )
      
    }
    
    apps_df[apps_df$ShowThisUser, ]
  })
  
  output$appBoxes <- renderUI({
    
    # Clear out old temp tiles
    tiles_to_keep <- paste("www/", c("metworx-logo.png", "default-tile.png"), sep = "")
    old_tiles <- list.files("www", full.names = TRUE)
    old_tiles <- old_tiles[!(old_tiles %in% tiles_to_keep)]
    lapply(old_tiles, file.remove)
    
    app_boxes <- tagList()
    
    for(i in 1:nrow(appsDF())){
      
      app_df.i <- appsDF()[i, ]
      
      ## Tile
      if(app_df.i$EnvisionTileLocation != "default-tile.png"){
        
        if(file.exists(app_df.i$EnvisionTileLocation)){
          
          # Create a name that will be unique to each session
          temp_img_name.i <- paste0(app_df.i$App,
                                    "-temp-tile-",
                                    round(as.numeric(Sys.time()), 0),
                                    "-",
                                    basename(app_df.i$EnvisionTileLocation))
          
          try(
            file.copy(
              from = app_df.i$EnvisionTileLocation,
              to = paste0("www/", temp_img_name.i)
            )
          )
          
          tile_file.i <- temp_img_name.i
          
        }
        
      } else {
        
        tile_file.i <- "default-tile.png"
      }
      
      tile.i <- tags$img(alt = "Tile Not Found", 
                         height = "120px",
                         width = "150px",
                         src = tile_file.i)
      
      ## Name
      name.i <- tags$span(
        style = "font-size:27px",
        app_df.i$EnvisionName
      )
      
      ## Description
      description.i <- tags$span(
        style = "font-size:16px",
        app_df.i$EnvisionDescription
      )
      
      ## Launch button
      launch_link.i <- tags$a(
        class="btn btn-primary btn-lg",
        target = "_blank",
        href = file.path(rV$clientURL, "envision", app_df.i$App, ""),
        icon("new-window", lib = "glyphicon"),
        "Launch App"
      )
      
      ## Developer warnings
      if(!app_df.i$HasDescription & rV$isDeveloper){
        warnings.i <-
          tags$button(
            type="button",
            class="btn btn-link appBoxesToolTip",
            id=paste0(app_df.i$App, "-toolTip"),
            `data-toggle`="tooltip",
            `data-placement`="bottom",
            title = paste0("<span style='font-weight:bold; font-size:16px;' >Envision Warning</span></br></br>",
                           "No description file found at:</br>",
                           app_df.i$AppDir,
                           "/DESCRIPTION",
                           "</br></br>For more info, click <b><a 'toolTipLink' href='https://github.com/metrumresearchgroup/envision-index/#description-file-in-envision-apps' target='_blank'>here</a></b>."),
            tags$span(style = "font-size:14px;", class = "badge alert-warning", HTML("&nbsp;!&nbsp;"))
          )
      } else {
        warnings.i <- tags$div()
      }
      
      app_boxes <- 
        tagAppendChild(app_boxes,
                       box(width = NULL, 
                           status = "primary",
                           fluidRow(
                             column(
                               width = 2,
                               tile.i
                             ),
                             column(
                               width = 2,
                               name.i
                             ),
                             column(
                               width = 4,
                               description.i
                             ),
                             column(
                               width = 2,
                               offset = 1,
                               launch_link.i
                             ),
                             column(
                               width = 1,
                               warnings.i
                             )
                           )
                       )
        )
    }
    
    tagList(
      app_boxes,
      tags$script(
        '$(".appBoxesToolTip").tooltip({html: true, delay: { "show": 400, "hide": 1300 }});'
      )
    )
  })
  
  # Log  --------------------------------------------------------------------
  
  observeEvent(appsDF(), {
    updateSelectInput(session, inputId = "logApp", choices = appsDF()$App)
    updateSelectInput(session, inputId = "configApp", choices = appsDF()$App)
  })
  
  output$configAppSelection <- renderText({
    paste0("Configuring App: ", input$configApp)
  })
  
  observeEvent(input$configApp, {
    
    description_file_location <- file.path("/data", "shiny-server", input$configApp, "DESCRIPTION")
    
    config_app_DEFAULT <- data.frame(EnvisionName = input$configApp,
                                     EnvisionDescription = "",
                                     EnvisionTileLocation = "default-tile.png",
                                     EnvisionUsers = "all",
                                     stringsAsFactors = FALSE)
    
    if(file.exists(description_file_location)){
      
      config_app_DESCRIPTION <- as.data.frame(read.dcf(file = description_file_location), stringsAsFactors = FALSE)
      
      for(column.i in colnames(config_app_DEFAULT)){
        
        if(is.null(config_app_DESCRIPTION[[column.i]])){
          config_app_DESCRIPTION[[column.i]] <- config_app_DEFAULT[[column.i]]
        }
      }
      
    } else {
      config_app_DESCRIPTION <- config_app_DEFAULT
    }
    
    
    updateTextInput(session, inputId = "configAppName", value = config_app_DESCRIPTION$EnvisionName)
    updateTextInput(session, inputId = "configAppDescription", value = config_app_DESCRIPTION$EnvisionDescription)
    updateTextInput(session, inputId = "configAppTileLocation", value = config_app_DESCRIPTION$EnvisionTileLocation)
    updateSelectInput(session, inputId = "configAppUsers", selected = gsub(" ", "", unlist(strsplit(config_app_DESCRIPTION$EnvisionUsers, ","))),
                      choices = unique(c(gsub(" ", "", unlist(strsplit(config_app_DESCRIPTION$EnvisionUsers, ","))), rV$homeDirectoryUsers)))
    
  })
  
  observeEvent(input$configAppSave, {
    
    description_file_location <- file.path("/data", "shiny-server", input$configApp, "DESCRIPTION")
    
    if(file.exists(description_file_location)){
      
      DESCRIPTION_file <- read.dcf(file = description_file_location)
      
      DESCRIPTION_message <- "updated" 
      
    } else {
      
      DESCRIPTION_file <- matrix(ncol = 4)
      colnames(DESCRIPTION_file) <- c("EnvisionName", "EnvisionDescription", "EnvisionTileLocation", "EnvisionUsers")
      
      DESCRIPTION_message <- "created" 
    }
    
    DESCRIPTION_file[, 'EnvisionName'] <- input$configAppName
    DESCRIPTION_file[, 'EnvisionDescription'] <- input$configAppDescription
    DESCRIPTION_file[, 'EnvisionTileLocation'] <- input$configAppTileLocation
    DESCRIPTION_file[, 'EnvisionUsers'] <- paste(input$configAppUsers, collapse = ", ")
    
    write.dcf(DESCRIPTION_file, file = description_file_location)
    
    showModal(modalDialog(
      title = "Metworx Envision",
      fluidRow(
        column(
          width = 10,
          h4(paste0("File ", DESCRIPTION_message, " at: ", description_file_location))
        )
      ),
      easyClose = TRUE,
      footer = actionButton(
        `data-dismiss`="modal",
        inputId = "dismissAfterConfig",
        label = "Dismiss"
      )
    ),
    session)
  })
  
  
  observeEvent(input$downloadLogModal, {
    
    showModal(modalDialog(
      title = "Metworx Envision",
      fluidRow(
        column(
          width = 9,
          selectInput(
            inputId = "logFileToDownload",
            label = "Log File",
            choices = rev(appLogs()), 
            selected = "",
            selectize = FALSE,
            size = 10
          )
        ),
        column(
          width = 2,
          conditionalPanel(
            condition = "input.logFileToDownload",
            downloadButton('downloadLog', 'Download')
          )
        )
      ),
      easyClose = TRUE
    ),
    session)
  })
  
  
  appLogs <- reactive({
    
    if(input$liveStream){
      autoInvalidate()
    }
    logs <- list.files(input$logDir)
    
    logs[grepl(input$logApp, logs)]
  })
  
  logContents <- reactive({
    app_logs_time_info <- do.call("rbind",
                                  lapply(strsplit(appLogs(), "-"), function(x){
                                    data.frame(
                                      DATE = x[length(x) - 2],
                                      TIME = x[length(x) - 1],
                                      stringsAsFactors = FALSE
                                    )
                                  }))
    
    sorted_app_logs <- gsub(paste0(input$logDir, "/"), "", appLogs()[order(app_logs_time_info$DATE, app_logs_time_info$TIME, decreasing = TRUE)])
    
    log_contents <- data.frame(stringsAsFactors = FALSE)
    
    new_log_break <- paste(rep("-", 25), collapse = "")
    
    for(log.i in sorted_app_logs){
      
      if(nrow(log_contents) > 200) break
      
      log_lines.i <- data.frame(
        file = paste0("[", log.i, "]"),
        contents = readLines(file.path(input$logDir, log.i)),
        stringsAsFactors = FALSE
      )
      
      log_contents.i <- rbind(
        data.frame(
          file = c("", ""),
          contents = c("", paste0(new_log_break, " Begin Log [", log.i, "] ", new_log_break)),
          stringsAsFactors = FALSE
        ),
        log_lines.i
      )
      
      if(any(grepl("Execution halted", log_contents.i$contents))){
        log_contents.i <- rbind(
          log_contents.i,
          data.frame(
            file = "",
            contents = paste0(new_log_break, " End Log [", log.i, "] ", new_log_break, "</br>"),
            stringsAsFactors = FALSE
          )
        )
      }
      
      log_contents <- rbind(log_contents.i, log_contents)
    }
    
    log_contents$display_lines <- paste(log_contents$file, log_contents$contents, sep = paste(rep("&nbsp;", 10), collapse = ""))
    
    log_contents
  })
  
  output$logContents <- renderUI({
    HTML(paste(logContents()$display_lines, collapse = "</br>"))
  })
  
  output$downloadLog <- downloadHandler(
    
    filename = function() {
      paste(input$logFileToDownload, '.txt', sep='')
    },
    content = function(file) {
      write.csv(data.frame(LOG_CONTENTS = readLines(file.path(input$logDir, input$logFileToDownload))),
                file,
                row.names = FALSE)
    }
  )
  
  output$configureDevUI <- renderUI({
    
    if(rV$isDeveloper){
      
      configureDevUI <- 
        
        tagList(
          fluidRow(
            column(
              width = 3,
              box(
                width = NULL,
                title = "Configure Envision Apps", 
                solidHeader = TRUE,
                status = "info",
                selectInput(
                  inputId = "configApp",
                  label = "Select App to Configure",
                  choices = c("", appsDF()$App)
                )
              )
            ),
            column(
              width = 7,
              box(
                width = NULL,
                title = "Configuration Options", 
                solidHeader = TRUE,
                status = "info",
                fluidRow(
                  column(
                    width = 12,
                    tags$h2(textOutput("configAppSelection"))
                  )
                ),
                br(),
                fluidRow(
                  column(
                    width = 6,
                    textInput(
                      inputId = "configAppName",
                      label = "Envision Name",
                      value = ""
                    ),
                    textInput(
                      inputId = "configAppDescription",
                      label = "Envision Description",
                      value = ""
                    ),
                    textInput(
                      inputId = "configAppTileLocation",
                      label = "Envision Tile Location",
                      value = ""
                    ),
                    selectInput(
                      inputId = "configAppUsers",
                      label = "Envision Users",
                      choices = "",
                      multiple = TRUE
                    )
                  ),
                  column(
                    width = 3,
                    offset = 3,
                    actionButton(
                      class = "btn-lg",
                      inputId = "configAppSave",
                      label = "Save Config",
                      icon = icon("save")
                    )
                  )
                )
              )
            )
          )
        )
      
    } else {
      
      configureDevUI <- 
        
        tagList(
          tags$div(class = "alert alert-warning", role = "alert",
                   tags$span(class = "glyphicon glyphicon-exclamation-sign", `aria-hidden` = "true"),
                   tags$span(class="sr-only", "Message:"),
                   "Only the Envision Developer can view this screen")
        )
    }
    
    configureDevUI
  })
  
  # 
  # output$noLogWarning <- renderUI({
  #   req(input$logApp)
  #   if(input$logFile == "No Logs Found"){
  #     
  #     tags$div(class = "alert alert-warning", role = "alert",
  #              tags$span(class = "glyphicon glyphicon-exclamation-sign", `aria-hidden` = "true"),
  #              tags$span(class="sr-only", "Error:"),
  #              HTML(paste0("No logs found for this app (", input$logApp, ") in ", input$logDir, ".</br></br>",
  #                          "<i>(By default, logs are deleted when an Envision app stops running. To change this, update the settings found in /etc/shiny-server/shiny-server.conf (set preserve_logs true). Click ",
  #                          tags$a(href="http://docs.rstudio.com/shiny-server/#application-error-logs", target = "_blank", HTML("<b>here</b>")),
  #                          " for more info.)</i>")))
  #   }
  # })
}
