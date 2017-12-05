library(httr)
library(jsonlite)
library(tidytext)
library(dplyr)
library(stringr)
library(ggplot2)
library(rvest)
library(curl)
source("api.key.R")

UserCombinedInfo <- function(startdate,enddate) {
  
  time.period <-seq(as.Date("2016-03-12"), as.Date("2016-03-14"), by=1)
  
  OneDateInfo <- function (date) {
    base.url <-"https://api.nytimes.com/svc/books/v3/lists/overview.json"
    query.params <-list("api-key"=yiran.api.key, "published_date"=date)
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
  
  combined.df <-unique(combined.df) %>% 
    select(title, weeks_on_list, buy_links)
  
  row.names(combined.df) <-NULL
  
  return(combined.df)
  }

# I'm doing another dataframe about the price, and then jointly with combined.df
# current dataframe I'm working with is combined.df
#price data frame by the way of "by rbind"
 PriceInfo <-by(combined.df,1:nrow(combined.df),function(newrow){
  every <-as.data.frame(newrow$buy_links)
  price.url <-every[3,2]
  page <-read_html(GET(price.url,user_agent("myagnet")))
  price1 <- page %>% html_nodes('#pdp-cur-price') %>% html_text() 
  if (length(price1)==1) {
    price2 <-as.numeric(sub('\\$','',as.character(price1)))
    return(price2)
  } else if (length(price1)==0) {
    price2 <- page %>% html_nodes('#pdp-cur-price-BuyNew') %>% html_text() 
    price2 <-as.numeric(sub('\\$','',as.character(price2)))
    return(price2)
  } else {
    price2 <-NA
    reutrn(price2)
  }
  })
 
all.price <-do.call(rbind,PriceInfo) #it shows all price for only 312, but there's 315. 


#test a single row. good 
arow <-combined.df[1,]
every <-as.data.frame(arow$buy_links)
price.url<-every[3,2]
page <- read_html(price.url)
price1 <- page %>% html_nodes('#pdp-cur-price') %>% html_text()
if (length(price1)==1) {
  price2 <-as.numeric(sub('\\$','',as.character(price1)))
  print(price2)
} else if (length(price1)==0) {
  price2 <- page %>% html_nodes('#pdp-cur-price-BuyNew') %>% html_text() 
  price2 <-as.numeric(sub('\\$','',as.character(price2)))
  print(price2)
} else {
  price2 <-NA
  print(price2)
}




