ui <- metrumApp(
  logo_location = file.path(envisionGlobals$shinymetrumGitHub, "inst", "img", "metworxLogo.png"),
  include_footer = FALSE,
  includeCSS(file.path(envisionGlobals$envisionIndexGitHub, "css", "envision-index.css")),
  includeScript(file.path(envisionGlobals$envisionIndexGitHub, "js", "envision-index.js")),
  fluidPage(
    div(id = "envision-app-table",
        div(class = "container",
            br(),
            br(),
            h1(style = "display:inline", "Envision Apps"),
            br(),
            br(),
            uiOutput('appTable')
        )
    ),
    div(class = "container-fluid",
        id = "envision-log-reader",
        style = "visibility:hidden;",
        br(),
        fluidRow(
          column(
            width = 1,
            actionButton(inputId = "showApps", class = "btn-primary btn-lg", label = "Back to Apps", icon = icon("step-backward"))
          ),
          column(
            width = 4,
            uiOutput("logAppName")
          ),
          column(
            width = 2,
            tags$div(
              class = "pull-right",
              textInput(inputId = "logDir", "Log Directory", "/var/log/shiny-server", width = "200px")
            )
          ),
          column(
            width = 3,
            selectInput("logFile", "Log File", choices = NULL, width = "450px")
          ),
          column(
            width = 2,
            span(
              class = "text-center",
              style = "font-size:20px",
              checkboxInput("liveStream", "Live Stream", value = TRUE)
            )
          )
        ),
        fluidRow(
          column(
            width = 12,
            verbatimTextOutput("logContents"),
            uiOutput("noLogWarning")
          )
        )
    )
  )
)
