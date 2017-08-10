dashboardPage(
  title = "Envision",
  # title = HTML("<i class='fa fa-bar-chart'></i>Envision"),
  # dashboardHeader(title = tags$img(width = "auto", height = "95%", src = "metworx-logo.png")),
  dashboardHeader(title = HTML("<b>Envision</b>Dashboard")),
  ## Sidebar content
  dashboardSidebar(
    sidebarMenu(
      id = "envision-dashboard-sidebar",
      menuItem("Apps",
               tabName = "apps",
               icon = icon("th")),
      menuItem("Logs",
               tabName = "logs",
               icon = icon("database")),
      tags$img(id = "metworx-logo-image", 
               height="auto", 
               width = "150px",
               src = "metworx-logo.png")
      
    )
  ), ## Body content
  dashboardBody(
    tags$head(
      tags$link(
        rel = "shortcut icon",
        href = "favicon.ico"
      )
    ),
    includeCSS(file.path("css", "envision-index.css")),
    includeScript(file.path("js", "envision-index.js")),
    
    tabItems(
      # First tab content
      tabItem(tabName = "apps",
              div(
                class = "container",
                br(),
                # textOutput('clientUrl'),
                uiOutput('appBoxes')
              )
      ),
      tabItem(tabName = "logs",
              fluidRow(
                column(
                  width = 12,
                  box(
                    width = NULL,
                    title = "Log View Options", 
                    solidHeader = TRUE,
                    status = "primary",
                    fluidRow(
                      column(
                        width = 2,
                        textInput(
                          inputId = "logDir",
                          "Log Directory",
                          value = "/var/log/shiny-server",
                          width = "250px"
                        )
                      ),
                      column(
                        width = 2,
                        selectInput(
                          inputId = "logApp",
                          label = "Select App",
                          choices = NULL
                        )
                      ),
                      conditionalPanel(
                        "input.logApp != ''",
                        column(
                          width = 2,
                          offset = 4,
                          span(
                            style = "font-size:20px",
                            checkboxInput(
                              "liveStream",
                              "Live Stream",
                              value = TRUE
                            )
                          )
                        ),
                        column(
                          width = 1,
                          actionButton(
                            inputId = "downloadLogModal",
                            label = "Download",
                            icon = icon("download")
                          )
                        )
                      )
                    ),
                    conditionalPanel(
                      "input.logApp != ''",
                      fluidRow(
                        column(
                          width = 12,
                          uiOutput("logContents")
                        )
                      )
                    )
                  )
                  
                )
              )
      ),
      tabItem(tabName = "configure",
              uiOutput('configureDevUI')
      )
    )
  )
)

