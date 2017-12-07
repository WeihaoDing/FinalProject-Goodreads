source("price.R")
my.server <-function(input, output) {
  
  output$yiranPlot <-renderPlotly({
    UserCombinedInfo(input$dates[1],input$dates[2])
  })
}

shinyServer(my.server)