library(httr)
library(shiny)
library(jsonlite)
library(dplyr)
library(ggplot2)
library(plotly)
library(tidyr)
source("author.R")
source("publisher.R")
source('price.R')
source("review.R")
source("api.key.R")

list.names.url <- 'https://api.nytimes.com/svc/books/v3/lists/names.json'
list.names.query.params <- list(api_key = key)
list.names.response <- GET(list.names.url, query = list.names.query.params)
list.names.body <- content(list.names.response, "text")
list.names.results <- fromJSON(list.names.body)$results
list.names.display <- list.names.results$display_name

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
  output$negplot <- renderPlot({
    reviewdata <- ReviewWords(input$isbn, input$title)
    negative.cloud <- NegativeCloud(reviewdata)
  })
  
  output$posplot <- renderPlot({
    reviewdata <- ReviewWords(input$isbn, input$title)
    positive.cloud <- PositiveCloud(reviewdata)
  })
  
  output$selectUI <- renderUI({
    selectInput("list.select", label = h3("Select A Bestseller List"),
                choices = list.names.display, selected = 1)
  })
  
  output$dateUI <- renderUI({
    list.selected <- list.names.results[list.names.results$display_name == input$list.select, ]
    first.date <- list.selected[['oldest_published_date']]
    last.date <- list.selected[['newest_published_date']]
    dateRangeInput("list.range", label = h3("Select Publish Date Range"),
                   start = '2017-01-01', end = '2017-02-01',
                   min = first.date, max = last.date, separator = " ")
  })
  
  output$popularity <- renderPlotly({
    list.selected <- list.names.results[list.names.results$display_name == input$list.select, ]
    date.from <- strsplit(toString(input$list.range), split = " ")[[1]][1]
    date.to <- strsplit(toString(input$list.range), split = " ")[[1]][2]
    list.dates <- seq(as.Date(date.from), as.Date(date.to), by = 'week')
    
    UserCombinedInfo <- function(time.period) {
      
      one_date <- function(date){
        base.url <- 'https://api.nytimes.com/svc/books/v3/lists/overview.json'
        query.params <-list("api-key"= key, "published_date"=date)
        response <- GET(base.url, query = query.params)
        body <-content (response, "text")
        results <- as.data.frame(fromJSON(body)$results) %>% 
          filter(lists.list_name_encoded == list.selected$list_name_encoded)}
      
      combined.df <- lapply(time.period, one_date)
      combined.df <- as.data.frame(do.call(rbind,combined.df)) %>% unique()
      combined.df <- unnest(combined.df, lists.books)
      
      return(combined.df)
    }
    
    all.lists <- UserCombinedInfo(list.dates)
    
    all.lists$date <- as.Date(all.lists$created_date)
    
    if(input$pop.indicator == "Rank") {
      p <- plot_ly(all.lists, x = ~date, y = ~rank, color = ~title) %>% 
        layout(yaxis = list(title = "Rank"), xaxis = list(title = "Date"))
    } else {
      p <- plot_ly(all.lists, x = ~date, y = ~weeks_on_list, color = ~title) %>% 
        layout(yaxis = list(title = "Weeks on List"), xaxis = list(title = "Date"))
    }
    
    p <- p %>% 
      add_lines() %>% 
      layout(legend = list(font = list(
        family = "sans-serif",
        size = 12,
        color = "#000"),
        bgcolor = "#E2E2E2",
        bordercolor = "#FFFFFF",
        borderwidth = 2)) %>% 
      layout(autosize = F, width = 1000, height = 500, margin = list(
        l = 50,
        r = 50,
        b = 100,
        t = 100,
        pad = 4
      ))
    
    return(p)
    
  })
})