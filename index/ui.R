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
    
    # tags$nav(
    #   class = "navbar navbar-default navbar-fixed-top",
    #   tags$div(
    #     class = "container-fluid",
    #     tags$img(
    #       class = "navbar-brand",
    #       id = "metrum-logo",
    #       alt = "Metrum Research Group",
    #       src = "metworx-logo.png")
    #   )
    # ),
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
                  width = 2,
                  box(
                    width = NULL,
                    title = "Log View Options", 
                    solidHeader = TRUE,
                    status = "primary",
                    textInput(
                      inputId = "logDir",
                      "Log Directory",
                      value = "/var/log/shiny-server",
                      width = "250px"
                    ),
                    selectInput(
                      inputId = "logApp",
                      label = "Select App",
                      choices = NULL
                    )
                  )
                ),
                conditionalPanel(
                  "input.logApp != ''",
                  column(
                    width = 10,
                    box(
                      width = NULL,
                      title = "Log", 
                      solidHeader = TRUE,
                      status = "primary",
                      fluidRow(
                        column(
                          width = 2,
                          offset = 7,
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
                          width = 3,
                          actionButton(
                            class = "pull-right",
                            inputId = "downloadLogModal",
                            label = "Download",
                            icon = icon("download")
                          )
                        )
                      ),
                      uiOutput("logContents")
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
