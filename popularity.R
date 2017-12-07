# Import essential libraries
library(httr)
library(jsonlite)
library(dplyr)
library(shiny)
library(plotly)
library(tidyr)

source('api.key.R')

# Get the name of all lists
list.names.url <- 'https://api.nytimes.com/svc/books/v3/lists/names.json'
list.names.query.params <- list(api_key = book.key)
list.names.response <- GET(list.names.url, query = list.names.query.params)
list.names.body <- content(list.names.response, "text")
list.names.results <- fromJSON(list.names.body)$results
list.names.display <- list.names.results$display_name

popularity.ui <- fluidPage({
  sidebarLayout(
    sidebarPanel(
      selectInput("pop.indicator", label = h3("Popularity Indicator"),
                  choices = list("Rank" = "Rank", "Weeks on List" = "Week")),
      htmlOutput('selectUI'),
      htmlOutput('dateUI')
    ),
    mainPanel(
      plotlyOutput('popularity')
    )
  )
})

# All updates kept in the server 
popularity.server <- function(input, output){
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
        query.params <-list("api-key"= book.key, "published_date"=date)
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
}

shinyApp(ui = popularity.ui, server = popularity.server)
