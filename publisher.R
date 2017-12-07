library(jsonlite)
library(dplyr)
library(httr)

weihao.api.key = 'd5996a954fbf40e788bf0a3a16e5643c'

date <- '2015-01-26'

getPublisherInfo <- function(date) {
  base.url <-"https://api.nytimes.com/svc/books/v3/lists/overview.json"
  query.params <- list("api-key" = yiran.api.key, "published_date" = date)
  response <- GET(base.url, query = query.params)
  body <-content (response, "text")
  results <-as.data.frame(fromJSON(body))
  list <- as.data.frame(results$results.lists.books)
  length <- as.numeric(length(results$results.lists.books))
  allInfo <- list %>% select(publisher, title, weeks_on_list)
  for (i in 1:(length - 1)) {
    i <- as.numeric(i)
    publisher.row <- paste0('publisher.', i)
    title.row <- paste0('title.', i)
    weeks_on_list.row <- paste0('weeks_on_list.', i)
    info <- list %>% select(publisher = publisher.row, 
                            title = title.row, 
                            weeks_on_list = weeks_on_list.row)
    df <- data.frame(info)
    info_total <- rbind(allInfo, df)
  }
  info_total <- info_total %>% 
    distinct() %>%
    group_by(publisher) %>%
    arrange(-weeks_on_list)
  return(info_total)
}




