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
  
  time.period <-seq(as.Date("2016-03-12"), as.Date("2016-03-12"), by=1)
  
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
  combined.df.all <-lapply(time.period,OneDateInfo)
  combined.df.all <-as.data.frame(do.call(rbind,combined.df.all)) %>% filter(weeks_on_list!=0)
  
  combined.df <-unique(combined.df.all) %>% 
    select(title, weeks_on_list, buy_links,publisher) 
  
  row.names(combined.df) <-NULL
  
  return(combined.df)
  }

# I'm doing another dataframe about the price, and then jointly with combined.df
# current dataframe I'm working with is combined.df
#price data frame by the way of "by rbind"
 PriceInfo <-by(combined.df,1:nrow(combined.df),function(newrow){
  every <-as.data.frame(arow$buy_links)
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
  print(price2)
  })
 
all.price <-do.call(rbind,PriceInfo) #it shows all price for only 312, but there's 315. 
new.combined.df <-combined.df %>% select(-buy_links)
new.combined.df[,"price"]=all.price
g <-ggplot(data = new.combined.df) +
  geom_point(mapping = aes(x = price, y = weeks_on_list, color = publisher))+
  scale_fill_discrete(name = "Publisher")+
  labs(y = "Popularity",x="Price of Book",title = "Relationship between Price and Popularity")+
  theme(plot.title = element_text(hjust = 0.5),
        axis.title.y=element_text(margin = margin(t = 30, r = 18, b = 30, l = 18)))
g


#test a single row. good 
arow <-combined.df[1,]
every <-as.data.frame(arow$buy_links)
price.url<-every[3,2]
page <- read_html(GET(price.url,user_agent("myagnet")))
price1 <- page %>% html_nodes('#pdp-cur-price') %>% html_text()
if (length(price1)==1) {
  price2 <-as.numeric(sub('\\$','',as.character(price1)))
  
} else {
  price2=NA
}
 print(price2)


 all.price <-data_frame(1:105)

 
 #try to use for loop. 
 
 isbn <-combined.df.all$primary_isbn13
 
 length(isbn)
 
for (i in isbn) {
  price.url <- paste0("http://www.anrdoezrs.net/click-7990613-11819508?url=http%3A%2F%2Fwww.barnesandnoble.com%2Fw%2F%3Fean%3D", i)
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
  print(price2)
}
  
  
  
  
  
  
  
