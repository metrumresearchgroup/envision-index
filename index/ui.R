dashboardPage(
  dashboardHeader(title = "Envision Dashboard"),
  ## Sidebar content
  dashboardSidebar(
    sidebarMenu(
      menuItem("Apps",
               tabName = "apps",
               icon = icon("th")),
      menuItem("Logs",
               tabName = "logs",
               icon = icon("database")),
      menuItem("Configure",
               tabName = "configure",
               icon = icon("gears"),
               badgeLabel = "Developer",
               badgeColor = "blue")# ,
      # tags$div(
      #   class = "container",
      #   uiOutput('envisionDeveloper')
      # )
      
    )
  ), ## Body content
  dashboardBody(
    
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
                textOutput('clientUrl'),
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
                          offset = 8,
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
                            class = "pull-right",
                            inputId = "downloadLogModal",
                            label = "Download Logs",
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
