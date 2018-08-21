dashboardPage(
  title = "Envision",
  # skin = "yellow",
  # title = HTML("<i class='fa fa-bar-chart'></i>Envision"),
  # dashboardHeader(title = tags$img(width = "auto", height = "95%", src = "metworx-logo.png")),
  dashboardHeader(title = HTML("<b>Envision</b>Dashboard")),
  ## Sidebar content
  dashboardSidebar(
    sidebarMenu(
      id = "envisionDashboardSidebar",
      menuItem("Apps",
               tabName = "apps",
               icon = icon("th")),
      menuItem("Logs",
               tabName = "logs",
               icon = icon("database")),
      tags$img(id = "metworx-logo-image", 
               height="auto", 
               width = "200px",
               src = "metworx-logo.png")
      
    )
  ), ## Body content
  dashboardBody(
    tags$head(
      tags$link(
        rel = "shortcut icon",
        href = "favicon.ico"
      ),
      HTML('<meta name="viewport" content="width=device-width, initial-scale=1">')
    ),
    includeCSS(file.path("css", "envision-index.css")),
    includeScript(file.path("js", "envision-index.js")),
    
    tabItems(
      # First tab content
      tabItem(tabName = "apps",
              div(
                class = "row",
                div(
                  class = "col-lg-8 col-lg-offset-2 col-md-10 col-md-offset-1 col-sm-12 col-xs-12",
                  br(),
                  uiOutput('appBoxes')
                )
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
                        width = 3,
                        selectInput(
                          inputId = "logApp",
                          label = "Select App",
                          choices = NULL
                        )
                      ),
                      column(
                        width = 4,
                        uiOutput("EnvisionDashboardLogMessage")
                      ),
                      conditionalPanel(
                        "input.logApp != ''",
                        column(
                          class = "large-screen-items",
                          width = 1
                        ),
                        column(
                          width = 2,
                          # offset = 1,
                          style = "margin-top:12px;",
                          tags$span(
                            style = "font-size:20px;",
                            checkboxInput(
                              "liveStream",
                              "Live Stream",
                              value = TRUE
                            )
                          )
                        ),
                        column(
                          width = 2,
                          actionButton(
                            # class = "btn-lg",
                            style = "margin-top:15px;",
                            inputId = "downloadLogModal",
                            label = "Download Logs"
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

