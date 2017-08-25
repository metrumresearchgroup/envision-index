function(input, output, session) {
  
  rV <- reactiveValues()
  
  observeEvent(session, {
    
    ##  This entire block runs whenenver the page is refreshed
    message(
      paste0(
        "\n# *********************** EnvisionDashboard Page Load ********************** #"
      )
    )
    
    rV$clientURL <- paste0(session$clientData$url_protocol, "//", session$clientData$url_hostname)
    
    passwdDF <- read.delim('/etc/passwd', sep = ":", header = FALSE, stringsAsFactors = FALSE)
    
    EnvisionUsersDF <- passwdDF[passwdDF$V3 > 999 & passwdDF$V3 < 2000 & !(passwdDF$V1 %in% c("ubuntu", "piranajs", "sas")), ]
    
    rV$envisionUsers <- sort(unique(EnvisionUsersDF$V1))
    
    rV$envisionDeveloper <- EnvisionUsersDF$V1[which.min(EnvisionUsersDF$V3)]
    
    rV$isDeveloper <- EnvisionUser == rV$envisionDeveloper
    
    message(
      paste0(
        "USER:  ", paste(EnvisionUser, sep = "", collapse = ", "), "\n",
        "DEVELOPER: ", paste(rV$envisionDeveloper, sep = "", collapse = ", "), "\n",
        "ENVISION USERS: ", paste(rV$envisionUsers, sep = "", collapse = ", ")
      )
    )
    
  })
  
  
  # output$envisionDeveloper <- renderUI({
  #   HTML(
  #     paste("User: ", EnvisionUser, "</br>",
  #           "Developer: ", rV$envisionDeveloper, "</br>",
  #           "Is Developer: ", rV$isDeveloper)
  #   )
  # })
  
  autoInvalidate <- reactiveTimer(1000, session = session)
  
  # App Table ---------------------------------------------------------------
  appsDF <- reactive({
    
    input$dismissAfterConfig
    session$sendCustomMessage(type = "envisionIndexJS", "$('#no-description-message').empty();");
    
    shiny_server_directories <- list.dirs(EnvisionAppsLocation, recursive = FALSE, full.names = FALSE)
    not_apps <- c("index", ".git")
    apps <- shiny_server_directories[!(shiny_server_directories %in% not_apps)]
    
    apps_df <- data.frame(App = apps,
                          AppDir = file.path(EnvisionAppsLocation, apps),
                          MTime = NA,
                          HasDescription = NA,
                          EnvisionName = NA,
                          EnvisionDescription = "",
                          EnvisionTileLocation = "",
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
        
        DESCRIPTION_df.i <- as.data.frame(read.dcf(file = DESCRIPTION_location.i, keep.white = EnvisionFields), stringsAsFactors = FALSE)
        
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
        grepl(EnvisionUser, apps_df$EnvisionUsers[i])
      )
      
    }
    
    message(
      paste0(
        "ENVISION APPS: ", paste(apps_df$App, sep = "", collapse = ", "), "\n",
        "ENVISION APPS FOR THIS USER: ", paste(apps_df$App[apps_df$ShowThisUser], sep = "", collapse = ", ")
      )
    )
    
    apps_df[apps_df$ShowThisUser, ]
  })
  
  output$appBoxes <- renderUI({
    
    # Clear out old temp tiles
    tiles_to_keep <- paste("www/", c("metworx-logo.png", "default-tile.png", "favicon.ico"), sep = "")
    old_tiles <- list.files("www", full.names = TRUE)
    old_tiles <- old_tiles[!(old_tiles %in% tiles_to_keep)]
    lapply(old_tiles, file.remove)
    
    app_boxes <- tagList()
    
    for(i in 1:nrow(appsDF())){
      
      app_df.i <- appsDF()[i, ]
      
      ## Tile
      tile_file.i <- "default-tile.png"
      alt_text.i = "Tile Not Found"
      tile_alpha.i <- .75
      tile_padding.i <- "10px 25px 10px 25px;"
      
      if(app_df.i$EnvisionTileLocation != ""){
        
        # Create a name that will be unique to each session
        temp_img_name.i <- paste0(app_df.i$App,
                                  "-temp-tile-",
                                  as.character(round(as.numeric(Sys.time()), 0)),
                                  ".",
                                  tools::file_ext(app_df.i$EnvisionTileLocation))
        
        tile_copy_try.i <- try(
          file.copy(
            from = app_df.i$EnvisionTileLocation,
            to = paste0("www/", temp_img_name.i)
          )
        )
        
        if(class(tile_copy_try.i) == "try-error"){
          
          message(
            paste0(
              "\n",
              paste0("TILE COPY FAIL FOR APP: ", app_df.i$App,"\n", 
                     "FAIL COPY PATH: ", app_df.i$EnvisionTileLocation)
            )
          )
        }
        
        tile_file.i <- temp_img_name.i
        alt_text.i <- paste0(alt_text.i, " At: ", app_df.i$EnvisionTileLocation)
        tile_alpha.i <- 1
        tile_padding.i <- "0px"
      }
      
      tile.i <- 
        tags$a(
          href = file.path(rV$clientURL, "envision", app_df.i$App, ""),
          target = "_blank",
          tags$img(alt = alt_text.i, 
                   # height = "170px",
                   width = "100%",
                   style = paste0("opacity:", tile_alpha.i,";", "padding:", tile_padding.i, ";"),
                   class = "envision-index-tile-img", # center-block",# img-responsive",
                   src = tile_file.i)
        )
      
      ## Name
      name.i <- tags$a(
        href = file.path(rV$clientURL, "envision", app_df.i$App, ""),
        target = "_blank",
        style = "font-size:23px;font-weight:bold;",
        HTML(paste0(app_df.i$EnvisionName, "&nbsp;&nbsp;", icon("new-window", lib = "glyphicon")))
      )
      
      ## Description
      description.i <- tags$span(
        style = "font-size:18px",
        app_df.i$EnvisionDescription
      )
      
      ## Launch button
      launch_link.i <- tags$a(
        class = "btn btn-primary btn-lg btn-block pull-right",
        target = "_blank",
        href = file.path(rV$clientURL, "envision", app_df.i$App, ""),
        icon("new-window", lib = "glyphicon"),
        "Launch"
      )
      
      
      ## Developer warnings
      show_warnings <- (!app_df.i$HasDescription & rV$isDeveloper)
      
      if(show_warnings){
        warnings.i <-
          tags$button(
            type="button",
            class="btn btn-link appBoxesToolTip",
            id=paste0(app_df.i$App, "-toolTip"),
            `data-toggle`="tooltip",
            `data-placement`="right",
            title = tagList(
              tags$span(style='font-weight:bold; font-size:16px;', "Envision Warning"),
              tags$br(),
              tags$br(),
              "No description file found at:",
              tags$br(),
              paste0(app_df.i$AppDir, "/DESCRIPTION"), 
              tags$br(),
              tags$br(), 
              tagList("This file can be created via the ", tags$b(icon("gears"), "Configure"), " tab."),
              tags$br(), 
              tags$br(),
              "For more info, click ", 
              # tags$b(
              tags$a(
                href='https://github.com/metrumresearchgroup/envision-index/#description-file-in-envision-apps',
                target='_blank',
                "here."
                # )
              )
            ),
            
            tags$span(class = 'badge alert-info', icon("exclamation"))
          )
        
      } else {
        warnings.i <- tags$div()
      }
      
      
      app_boxes <- 
        tagAppendChild(app_boxes,
                       box(width = NULL, 
                           # status = "primary",
                           # solidHeader = TRUE,
                           title = "", # tagList(name.i, warnings.i),
                           # collapsible = TRUE,
                           fluidRow(
                             column(
                               width = 3,
                               tile.i
                               # fluidRow(
                               #   column(
                               #     offset = 1,
                               #     width = 10,
                               #     tile.i
                               #   )
                               # )
                             ),
                             tags$div(
                               class = "col-lg-8 col-md-9 col-sm-9 col-xs-12",
                               tags$div(class = "small-screen-items", tags$br()),
                               tagList(name.i, warnings.i),
                               tags$div(class = "large-screen-items", tags$br()),
                               description.i
                             )# ,
                             # column(
                             #   width = 3,
                             #   style = "padding-top:25px;",
                             #   launch_link.i
                             # )
                             
                           )
                       )
        )
    }
    
    tagList(
      app_boxes,
      tags$script(
        '
         $(".appBoxesToolTip").tooltip({html: true, delay: { "show": 400, "hide": 1500 }});
         $("#appBoxes .box-header").remove();
        '
      )
    )
  })
  
  # Log  --------------------------------------------------------------------
  
  observeEvent(appsDF(), {
    if(rV$isDeveloper){
      lastApp <- c("EnvisionDashboard" = "index")
    } else {
      lastApp <- NULL
    }
    updateSelectInput(session, inputId = "logApp", choices = c("", appsDF()$App, lastApp))
  })
  
  output$EnvisionDashboardLogMessage <- renderUI({
    if(input$logApp == "index"){
      tags$div(
        style = "margin-top:5px",
        class = "bg-info text-info alert",
        # tags$button(
        #   `aria-hidden`="true",
        #   class="close",
        #   `data-dismiss`="alert",
        #   type="button",
        #   "x"
        # ),
        tags$div("Only the Envision ",
                 tags$div(class = "badge alert-info", "Developer"),
                 HTML("can view logs for <b>Envision</b>Dashboard."))
      )
    } else {
      tags$div()
    }
  })
  
  output$configAppSelection <- renderText({
    paste0("Configuring App: ", input$configApp)
  })
  
  observeEvent(input$updateConfig, {
    
    description_file_location <- file.path("/data", "shiny-server", input$configApp, "DESCRIPTION")
    
    config_app_DEFAULT <- data.frame(EnvisionName = input$configApp,
                                     EnvisionDescription = "",
                                     EnvisionTileLocation = "",
                                     EnvisionUsers = "all",
                                     stringsAsFactors = FALSE)
    
    if(file.exists(description_file_location)){
      
      config_app_DESCRIPTION <- as.data.frame(read.dcf(file = description_file_location, keep.white = EnvisionFields), stringsAsFactors = FALSE)
      
      for(column.i in colnames(config_app_DEFAULT)){
        
        if(is.null(config_app_DESCRIPTION[[column.i]])){
          config_app_DESCRIPTION[[column.i]] <- config_app_DEFAULT[[column.i]]
        }
      }
      
    } else {
      
      config_app_DESCRIPTION <- config_app_DEFAULT
      
      session$sendCustomMessage(type = "envisionIndexJS", "$('#no-description-message').html('<i>No DESCRIPTION file found for this app. Form generated using defaults.</i>');");
    }
    
    app_users <- unlist(strsplit(config_app_DESCRIPTION$EnvisionUsers, " "))
    
    updateTextInput(session, inputId = "configAppName", value = config_app_DESCRIPTION$EnvisionName)
    
    updateTextInput(session, inputId = "configAppDescription", value = config_app_DESCRIPTION$EnvisionDescription)
    
    updateTextInput(session, inputId = "configAppTileLocation", value = config_app_DESCRIPTION$EnvisionTileLocation)
    
    updateSelectInput(session,
                      inputId = "configAppUsers",
                      selected = app_users,
                      choices = unique(c("all", app_users, rV$envisionUsers)))
    
  })
  
  observeEvent(input$configAppSave, {
    
    description_file_location <- file.path("/data", "shiny-server", input$configApp, "DESCRIPTION")
    
    if(file.exists(description_file_location)){
      
      DESCRIPTION_file <- as.data.frame(read.dcf(file = description_file_location, keep.white = EnvisionFields), stringsAsFactors = FALSE)
      
      DESCRIPTION_message <- "updated." 
      
    } else {
      
      DESCRIPTION_file <- data.frame(EnvisionName = NA,
                                     EnvisionDescription = NA,
                                     EnvisionTileLocation = NA,
                                     EnvisionUsers = NA,
                                     stringsAsFactors = FALSE)
      
      DESCRIPTION_message <- "created." 
    }
    
    DESCRIPTION_file$EnvisionName <- input$configAppName
    DESCRIPTION_file$EnvisionDescription <- input$configAppDescription
    DESCRIPTION_file$EnvisionTileLocation <- input$configAppTileLocation
    DESCRIPTION_file$EnvisionUsers <- paste(input$configAppUsers, collapse = " ")
    
    message(
      paste0(
        "\n",
        "SAVING DESCRIPTION FOR APP:  ", input$configApp, "\n",
        "ENVISION NAME: ",  DESCRIPTION_file$EnvisionName, "\n",
        "ENVISION DESCRIPTION: ",  DESCRIPTION_file$EnvisionDescription, "\n",
        "ENVISION TILE LOCATION: ",  DESCRIPTION_file$EnvisionTileLocation, "\n",
        "ENVISION USERS: ",  DESCRIPTION_file$EnvisionUsers
      )
    )
    
    write.dcf(DESCRIPTION_file, file = description_file_location, keep.white = EnvisionFields)
    
    showModal(modalDialog(
      title = "Metworx Envision",
      fluidRow(
        column(
          width = 10,
          tags$div(style = 'font-size:14px;',
                   tags$span(class = 'badge alert-success', icon("check")),
                   "  File", tags$i(description_file_location),
                   " successfully ",
                   DESCRIPTION_message)
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
      title = "Select Log to Download",
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
    logs <- list.files(EnvisionAppsLogDirectory)
    
    if(rV$isDeveloper){
      system(paste0("sudo chown shiny:shiny ", EnvisionAppsLogDirectory, "/*"))
    }
    
    logs[grepl(input$logApp, logs)]
  })
  
  logContents <- reactive({
    
    if(length(appLogs()) == 0) {
      return(
        data.frame(display_lines = paste0("No logs found for app ", tags$i(input$logApp), 
                                          ". Launch this app from the&nbsp;", tags$b(icon("th"), "Apps"), "&nbsp;tab to initiate a log."),
                   stringsAsFactors = FALSE)
      )
    }
    
    app_logs_time_info <- do.call("rbind",
                                  lapply(strsplit(appLogs(), "-"), function(x){
                                    data.frame(
                                      DATE = x[length(x) - 2],
                                      TIME = x[length(x) - 1],
                                      stringsAsFactors = FALSE
                                    )
                                  }))
    
    sorted_app_logs <- gsub(paste0(EnvisionAppsLogDirectory, "/"), "", appLogs()[order(app_logs_time_info$DATE, app_logs_time_info$TIME, decreasing = TRUE)])
    
    log_contents <- data.frame(stringsAsFactors = FALSE)
    
    new_log_break <- paste(rep("-", 75), collapse = "")
    
    for(log.i in sorted_app_logs){
      
      if(nrow(log_contents) > 200) break
      
      log_lines.i <- data.frame(
        file = paste0("[", log.i, "]"),
        contents = readLines(file.path(EnvisionAppsLogDirectory, log.i)),
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
      writeLines(readLines(file.path(EnvisionAppsLogDirectory, input$logFileToDownload)),
                 file)
    }
  )
  
  # Configure ---------------------------------------------------------------
  observe({
    if(rV$isDeveloper){
      insertUI(
        selector = "#envision-dashboard-sidebar",
        where = "beforeBegin",
        menuItem(tagList("Configure",
                         tags$div(class = "pull-right badge alert-info", "Developer")
        ),
        tabName = "configure",
        icon = icon("gears"))
      )
      
    }
  })
  
  output$configureDevUI <- renderUI({
    
    if(rV$isDeveloper){
      
      softwareInfo <- tagList(
        sessionInfo()$R.version$version.string,
        tags$br(),
        tags$br(),
        paste0("Shiny version ", sessionInfo()$otherPkgs$shiny$Version),
        tags$br(),
        tags$br(),
        paste0("Shiny-server version ", system("cat /opt/shiny-server/GIT_VERSION", intern = TRUE)),
        tags$br(),
        tags$br(),
        tags$br(),
        tags$i("For info on overriding default packages, click ",
               tags$a(
                 href = "https://metworx-help.zendesk.com/hc/en-us/articles/115001650486-Use-a-custom-R-library-for-a-shiny-application-including-overriding-system-packages",
                 target = "_blank", 
                 "here"
               ),
               "."
        )
      )
      
      configureDevUI <- 
        
        tagList(
          fluidRow(
            column(
              width = 12,
              tags$div(
                class = "bg-info text-info alert",
                tags$button(
                  `aria-hidden`="true",
                  class="close",
                  `data-dismiss`="alert",
                  type="button",
                  "x"
                ),
                tags$div("Only the Envision ",
                         tags$div(class = "badge alert-info", "Developer"),
                         "can view this tab.")
              )
            )
          ),
          fluidRow(
            column(
              width = 5,
              box(
                width = NULL,
                title = "Configure Apps", 
                solidHeader = TRUE,
                status = "info",
                collapsible = TRUE,
                fluidRow(
                  column(
                    width = 5,
                    selectInput(
                      inputId = "configApp",
                      label = "Select App",
                      choices = c("", appsDF()$App),
                      width = "100%"
                    )
                  ),
                  column(
                    width = 3,
                    div(
                      class = "config-app-options",
                      style = "display:none;",
                      actionButton(
                        style = "margin-top:25px",
                        inputId = "restartApp",
                        label = "Restart",
                        icon = icon("refresh")
                      )
                    )
                  )
                ),
                tags$div(
                  id = "no-description-message"
                ),
                fluidRow(
                  column(
                    width = 12,
                    div(
                      class = "config-app-options",
                      style = "display:none;",
                      br(),
                      textInput(
                        inputId = "configAppName",
                        label = "Name*",
                        value = "",
                        width = "100%"
                      ),
                      br(),
                      textAreaInput(
                        inputId = "configAppDescription",
                        label = "Description",
                        value = "",
                        width = "100%",
                        height = "80px"
                      ),
                      br(),
                      textInput(
                        inputId = "configAppTileLocation",
                        label = "Tile Location On Disk",
                        value = "",
                        width = "100%"
                      ),
                      fileInput(inputId = 'envisionTileInput',
                                label = 'Upload New Tile Image',
                                accept = c('image/*'),
                                width = "100%"),
                      selectInput(
                        inputId = "configAppUsers",
                        label = "Envision Users",
                        choices = "",
                        multiple = TRUE,
                        width = "100%"
                      ),
                      conditionalPanel(
                        "input.configAppName != ''",
                        # column(
                        # width = 4,
                        # br(),
                        actionButton(
                          style = "margin-top:8px",
                          class = "btn-lg pull-right",
                          inputId = "configAppSave",
                          label = "Save Config",
                          icon = icon("save")
                        )
                        #  )
                      )
                    )
                  )
                )
              )
            ),
            column(
              width = 5,
              offset = 1,
              box(
                width = NULL,
                title = "Envision Info", 
                # solidHeader = TRUE,
                status = "info",
                collapsible = TRUE,
                tagList(
                  fluidRow(
                    column(width = 4, tags$b("Envision Developer:")),
                    column(width = 8, rV$envisionDeveloper)
                  ),
                  tags$hr(),
                  fluidRow(
                    column(width = 4, tags$b("Envision Users:")),
                    column(width = 8, lapply(sort(rV$envisionUsers), function(x){tagList(x, tags$br())}))
                  ), 
                  tags$hr(),
                  fluidRow(
                    column(width = 4, tags$b("Software:")),
                    column(width = 8, softwareInfo)
                  )
                )
              )
            )
          )
        )
      
      
    } else {
      
      configureDevUI <- 
        
        tagList(
          tags$div(
            class = "alert alert-warning",
            role = "alert",
            tags$span(class = "glyphicon glyphicon-exclamation-sign", `aria-hidden` = "true"),
            tags$span(class="sr-only", "Message:"),
            "Only the Envision Developer can view this screen")
        )
    }
    
    configureDevUI
  })
  
  observeEvent(input$restartApp, {
    system(paste0("touch ", EnvisionAppsLocation, "/", input$configApp, "/restart.txt"))
    
    showModal(
      modalDialog(
        title = "Metworx Envision",
        tags$div(style = 'font-size:14px;',
                 tags$span(class = 'badge alert-success', icon("refresh")),
                 paste0("Application ", input$configApp, " successfully restarted.") 
        )
      )
    )
    
  })
  
  # observeEvent(input$uploadImageModal, {
  #   showModal(
  #     modalDialog(
  #       title = "Select Image",
  #       fileInput(width = "100%",
  #                 inputId = 'envisionTileInput',
  #                 label = 'Upload Image',
  #                 accept = c('image/*'))
  #     )
  #   )
  # })
  
  
  observeEvent(input$envisionTileInput, {
    req(input$envisionTileInput)
    
    UploadedImageLoc <- file.path(EnvisionAppsLocation, input$configApp, input$envisionTileInput$name)
    
    file.copy(input$envisionTileInput$datapath,
              UploadedImageLoc,
              overwrite = TRUE)
    
    updateTextInput(session, inputId = "configAppTileLocation", value = UploadedImageLoc)
  })
  
  
  observeEvent(input$configAppName, {
    if(input$configAppName == ""){
      session$sendCustomMessage(type = "envisionIndexJS",
                                "$('#configAppName').removeClass('parsley-success').addClass('parsley-error')")
    } else {
      session$sendCustomMessage(type = "envisionIndexJS",
                                "$('#configAppName').removeClass('parsley-error').addClass('parsley-success')")
    }
    
  })
  
  observeEvent(input$configApp, {
    session$sendCustomMessage(type = "envisionIndexJS", "$('#no-description-message').empty();");
    if(input$configApp == '') return(NULL)
    session$sendCustomMessage(type = "envisionIndexJS",
                              "$('.config-app-options').fadeOut(801, function(){Shiny.onInputChange('updateConfig', Date());}); $('.config-app-options').fadeIn(801);")
    
  })
}
