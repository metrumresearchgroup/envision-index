ui <- metrumApp(
  logo_location = "https://metrumrg-soft.s3.amazonaws.com/shinyapps/shinymetrum/metworxLogo.png",
  include_footer = FALSE,
  includeCSS("https://raw.githubusercontent.com/metrumresearchgroup/envision-index/master/www/css/envision-index.cs"),
  includeScript("https://raw.githubusercontent.com/metrumresearchgroup/envision-index/master/www/js/envision-index.js"),
  fluidPage(
    div(class = "container",
        id = "envision-app-table",
        h2("Envision Applications"),
        uiOutput('appTable')
    ),
    div(class = "container-fluid",
        id = "envision-log-reader",
        style = "visibility:hidden;",
        fluidRow(
          column(
            width = 1,
            actionButton(inputId = "showApps", class = "btn-primary", label = "Back to Apps")
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
            verbatimTextOutput("logContents")
          )
        )
    )
  )
)
