library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
  
  autoInvalidate <- reactiveTimer(3000, session = session)
  
  observeEvent(autoInvalidate(), {
    
    message(paste0("It's Alive ", Sys.time()))
    
  })

  # Expression that generates a histogram. The expression is
  # wrapped in a call to renderPlot to indicate that:
  #
  #  1) It is "reactive" and therefore should be automatically
  #     re-executed when inputs change
  #  2) Its output type is a plot

  output$distPlot <- renderPlot({
    x    <- faithful[, 2]  # Old Faithful Geyser data
    bins <- seq(min(x), max(x), length.out = input$bins + 1)

    # draw the histogram with the specified number of bins
    hist(x, breaks = bins, col = 'darkgray', border = 'white')
  })

})