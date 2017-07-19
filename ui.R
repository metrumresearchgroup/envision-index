ui <- 
  
  fluidPage(
    
    includeCSS(file.path(envisionGlobals$envisionIndexGitHub, "css", "envision-index.css")),
    includeScript(file.path(envisionGlobals$envisionIndexGitHub, "js", "envision-index.js")),
    
    tags$nav(
      class = "navbar navbar-default navbar-fixed-top",
      tags$div(
        class = "container-fluid",
        tags$img(
          class = "navbar-brand",
          id = "metrum-logo",
          alt = "Metrum Research Group",
          src = file.path(envisionGlobals$envisionIndexGitHub, "img", "metworxLogo.png")
        )
      )
    ),
    div(id = "envision-app-table",
        div(
          class = "container",
          h1("Envision Apps"),
          br(),
          uiOutput('appTable')
        )
    ),
    div(class = "container-fluid",
        id = "envision-log-reader",
        style = "visibility:hidden; padding-top:20px;",
        fluidRow(
          column(
            width = 1,
            actionButton(inputId = "showApps",
                         class = "btn-link btn-lg",
                         label = "Back to Apps",
                         icon = icon("step-backward"))
          )
        ),
        fluidRow(
          column(
            width = 2,
            offset = 2,
            uiOutput("logAppName")
          ),
          column(
            width = 2,
            textInput(inputId = "logDir", "Log Directory", value = "/var/log/shiny-server", width = "250px")
          ),
          column(
            width = 3,
            selectInput("logFile", "Log File", choices = NULL,  width = "450px")
          ),
          column(
            width = 1,
            uiOutput('logAppHelp')
          ),
          column(
            width = 2,
            span(
              style = "font-size:20px",
              checkboxInput("liveStream", "Live Stream", value = TRUE)
            )
          )
        ),
        fluidRow(
          column(
            width = 10,
            offset = 1,
            verbatimTextOutput("logContents"),
            uiOutput("noLogWarning")
          )
        )
    )
    
  )
