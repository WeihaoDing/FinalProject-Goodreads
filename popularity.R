# Import essential libraries
library(httr)
library(jsonlite)
library(dplyr)
library(shiny)
library(plotly)

source('./api.key.R')


# Get all bestseller list names using list.names endpoint
list.names.url <- 'https://api.nytimes.com/svc/books/v3/lists/names.json'
list.names.query.params <- list(api_key = book.key)
list.names.response <- GET(list.names.url, query = list.names.query.params)
list.names.body <- content(list.names.response, "text")
list.names.results <- fromJSON(list.names.body)$results
list.names.display <- list.names.results %>% select(display_name)
list.names.encoded <- list.names.results %>% select(list_name_encoded)

popularity.server <- function(input, output){
  
  output$selectUI <- renderUI({ 
    selectInput("list.names.select", label = h3("Select Bestseller List"),
                choices = list(list.names.encoded = list.names.display))
  })
  output$dateUI <- renderUI({
    list.selected <- list.names.results %>% filter(list.names.encoded == input$list.names.select)
    list.start <- list.selected[, 'oldest_published_date']
    list.end <- list.selected[, 'newest_published_date']
    dateRangeInput("list.dates.range", label = h3("Publish Date Range"),
                   min = list.start, max = list.end)
  })
  
  output$popularity <- renderPlotly({
    list.selected <- list.names.results %>% filter(list.names.encoded == input$list.names.select)
    list.start <- list.selected[, 'oldest_published_date']
    list.end <- list.selected[, 'newest_published_date']
    
    # Get each week or month between them
    if(list.names.results[, 'updated'] == "WEEKLY") {
      list.dates <- seq(as.Date(input$list.dates.range[1]), as.Date(input$list.dates.range[2]), by = "week")
    } else if(list.names.results[, 'updated' == "MONTHLY"]) {
      list.dates <- seq(as.Date(input$list.dates.range[1]), as.Date(input$list.dates.range[2]), by = "month")
    }
    
    # Pass that into overview
    
    UserCombinedInfo <- function(time.period) {
      
      OneDateInfo <- function (date) {
        base.url <-"https://api.nytimes.com/svc/books/v3/lists/overview.json"
        query.params <-list("api-key"= book.key, "published_date"=date)
        response <- GET(base.url, query = query.params)
        body <-content (response, "text")
        results <-as.data.frame(fromJSON(body))
        
        UsefulInfo <- by(results,1:nrow(results),function(row){
          each <-as.data.frame(row$results.lists.books)
          return(each)
        })
        all.useful <-do.call(rbind,UsefulInfo)
      }
      combined.df <-lapply(time.period,OneDateInfo)
      combined.df <-as.data.frame(do.call(rbind,combined.df))
      
      return(combined.df)
    }
    
    all.lists <- UserCombinedInfo(list.dates)
    
    all.lists$date <- as.Date(all.lists$created_date)
    
    if(input$pop.indicator == "Rank") {
      p <- plot_ly(all.lists, x = ~date, y = ~rank, color = ~title)
    } else {
      p <- plot_ly(all.lists, x = ~date, y = ~weeks_on_list, color = ~title)
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

popularity.ui <- fluidPage(
  mainPanel(titlePanel("Popularity"),
            sidebarLayout(
              sidebarPanel(
                selectInput("pop.indicator", label = h3("Popularity Indicator"),
                            choices = list("Rank" = "Rank", "Weeks on List" = "Week")),
                htmlOutput('selectUI'),
                htmlOutput('dateUI')
                # !!! Caution might need to use a updateDateRangeInput function
              ),
              mainPanel(
                plotlyOutput('popularity')
              )
            ))
)

shinyApp(ui = popularity.ui, server = popularity.server)