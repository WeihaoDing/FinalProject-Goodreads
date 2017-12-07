library(httr)
library(jsonlite)
library(tidytext)
library(dplyr)
library(stringr)
library(ggplot2)
library(rvest)
library(curl)
library(plotly)
library(shiny)
source("api.key.R")

# Create a function so that the user can get a graph of price and popularity if they input two dates. Please notice that NYT only has Book Reviews generated after the date 2008-06-02, or it will return nothing. 

#You do not have to specify the exact date the list was published. The service will search forward (into the future) for the closest publication date to the date you specify.

#It is ok to run the graph for a long time period. For example, from 2008-06-02 to 2017-02-14. However, that would take a really long time, and the NYT API rate limit, which is 1000 calls/dates, might exceed until you contact NYT API team. 

# It would take about 10-15min to generate a graph for one input date. While the optimal goal of my function is returning a graph no matter how long the time period the user requests,I suggest TAs input two same dates (2017-06-08 to 2017-06-08) on Shiny web when you test my code, so that it will take much less time. Please be patient, there will be a graph generated after 15min or so on Shiny web page. Thanks! 
UserCombinedInfo <- function(startdate,enddate) {
  # set the time period. The startdate and enddate are the user's inputs
  time.period <-seq(as.Date(startdate), as.Date(enddate), by=1)
  # create a data frame with the information NYT Book API "List/Overview" returns to me. 
  OneDateInfo <- function (date) {
    base.url <-"https://api.nytimes.com/svc/books/v3/lists/overview.json"
    query.params <-list("api-key"=key, "published_date"=date)
    response <- GET(base.url, query = query.params)
    body <-content (response, "text")
    results <-as.data.frame(fromJSON(body))
    
    UsefulInfo <- by(results,1:nrow(results),function(row){
      each <-as.data.frame(row$results.lists.books)
      return(each)
    })
    all.useful <-do.call(rbind,UsefulInfo)
  }
  #Combined every date's info into one data frame.  
  combined.df.all <-lapply(time.period,OneDateInfo)
  combined.df.all <-as.data.frame(do.call(rbind,combined.df.all)) %>% 
    # Requesting price of each book will take a LONG time. Normally there will be 210 rows in the origin data frame #(42lists*5). I filter the data frame so that only the books whose weeks_on_list are over than 10 will show up in the new data frame. Therefore we are requesting the price information from the new data frame. 
    filter(weeks_on_list!=0) %>% 
    filter(weeks_on_list > 10)
  
  combined.df <-unique(combined.df.all) %>% 
    select(title, weeks_on_list, buy_links,publisher) 
  
  row.names(combined.df) <-NULL
  #Since the NYT's price column is always 0, I decided to request price through the Barnes&Noble Online Bookshop URL, which is given by NYT. 
  PriceInfo <-by(combined.df,1:nrow(combined.df),function(newrow){
    every <-as.data.frame(newrow$buy_links)
    price.url <-every[3,2]
    page <-read_html(GET(price.url,user_agent("myagnet")))
    price1 <- page %>% html_nodes('#pdp-cur-price') %>% html_text() 
    if (length(price1)==1) {
      price2 <-as.numeric(sub('\\$','',as.character(price1)))
    } else if (length(price1)==0) {
      price2 <- page %>% html_nodes('#pdp-cur-price-BuyNew') %>% html_text() 
      price2 <-as.numeric(sub('\\$','',as.character(price2)))
    } 
    if (length(price2)==0) {
      price2=NA
    }
    return(price2)
  })
  #Combined all price for all the book in my dataframe. Now the data frame has "Book Title","Price","# of weeks the book has been on the Bestseller List", and "Publisher". 
  all.price <-do.call(rbind,as.list(PriceInfo))
  combined.df <-combined.df %>% select(-buy_links)
  combined.df[,"price"]=as.vector(all.price)
  combined.df <-combined.df %>% filter(price!="NA")
  # Generate a plot with all four column's information by Plotly. 
  f1 <- list(
    family = "Arial, sans-serif",
    size = 18,
    color = "#FBBBB9"
  )
  f2 <- list(
    family = "Old Standard TT, serif",
    size = 14,
    color = "black"
  )
  a <- list(
    title = "Price",
    titlefont = f1,
    showticklabels = TRUE,
    tickfont = f2,
    exponentformat = "E"
  )
  b <- list(
    title = "Popularity",
    titlefont = f1,
    showticklabels = TRUE,
    tickfont = f2,
    exponentformat = "E"
  )
  yiranpriceplot <- plot_ly(
    combined.df, x = ~price, y = ~weeks_on_list,type="scatter",mode = 'markers',marker=list(opacity =0.5,color= "#43C6DB"),
    text = ~paste(paste("Book Title:", title), 
                  paste("Publisher:", publisher),
                  paste("Popularity:",weeks_on_list),
                  paste("Price: $", price),
                  sep="<br />")) %>% 
    layout(xaxis = a, yaxis = b)
  return(yiranpriceplot)
}