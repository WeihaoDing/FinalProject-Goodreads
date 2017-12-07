library(jsonlite)
library(dplyr)
library(httr)
source("api.key.R")

getPublisherInfo <- function(date) {
  base.url <-"https://api.nytimes.com/svc/books/v3/lists/overview.json"
  query.params <- list("api-key" = key, "published_date" = date)
  response <- GET(base.url, query = query.params)
  body <-content (response, "text")
  results <-as.data.frame(fromJSON(body))
  list <- as.data.frame(results$results.lists.books)
  
  
  length <- as.numeric(length(results$results.lists.books))
  publisher.info <- list %>% select(publisher, title, weeks_on_list)
  for (i in 1:6) {
    publisher.row <- paste0('publisher.', i)
    title.row <- paste0('title.', i)
    weeks_on_list.row <- paste0('weeks_on_list.', i)
    info <- list %>% select(publisher = publisher.row, 
                            title = title.row, 
                            weeks_on_list = weeks_on_list.row)
    df <- data.frame(info)
    publisher_info <- rbind(publisher.info, df)
  }
  publisher_info <- publisher_info %>% 
    distinct() %>%
    group_by(publisher) %>%
    arrange(-weeks_on_list)
  return(publisher_info)
}