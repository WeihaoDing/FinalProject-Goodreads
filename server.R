library(shiny)
library(jsonlite)
library(dplyr)
library(ggplot2)
source("author.R")
source("publisher.R")
source('price.R')

shinyServer(function(input, output) {
    output$yiranPlot <-renderPlotly({
      UserCombinedInfo(input$dates[1],input$dates[2])
    })
    
    output$plot <- renderPlot({
      if (input$category == 'authors') {
        author.table <- author.data(input$date)
        n = nrow(author.table)
        par(mar=c(0,6,2,2)+0.1)
        xx <- barplot(author.table$Weeks,
                main = "NY Times Bestsellers", 
                xlab = "Authors", 
                ylab = "Weeks on NY Times Bestsellers List",
                legend.text = author.table$Authors,
                args.legend = (list(x ='topright', bty='n', inset=c(0.12,0))),
                col = rainbow(n))
        text(x = xx, y = 2, 
             label = author.table$Weeks, 
             pos = 3, 
             cex = 1.25, 
             col = "black")
      } else {
        publisher.table <- getPublisherInfo(input$date)
        n = 10
        par(mar=c(0,6,2,2)+0.1)
        xx <- barplot(publisher.table$weeks_on_list,
                main = "NY Times Bestsellers", 
                xlab = "Publishers", 
                ylab = "Weeks on NY Times Bestsellers List",
                legend.text = publisher.table$publisher,
                args.legend = (list(x = 'topright', bty = 'n', inset = c(0.12,0))),
                col = rainbow(n))
        text(x = xx, y = 2, 
             label = publisher.table$weeks_on_list, 
             pos = 3, 
             cex = 1.25, 
             col = "black")
      }
    })
})