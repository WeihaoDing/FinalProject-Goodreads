library(jsonlite)
library(dplyr)
library(httr)
source("api.key.R")

author.data <- function(date){
  base.url <-"https://api.nytimes.com/svc/books/v3/lists/overview.json"
  query.params <-list("api-key" = key, "published_date" = date)
  response <- GET(base.url, query = query.params)
  body <-content (response, "text")
  results <-as.data.frame(fromJSON(body))
  
  list <- as.data.frame(results$results.lists.books)
  length <- as.numeric(length(results$results.lists.books))
  info_total <- list %>% select(author, title, weeks_on_list)
  for (i in 1:(length - 1)) {
    i <- as.numeric(i)
    author.row <- paste0('author.', i)
    title.row <- paste0('title.', i)
    weeks_on_list.row <- paste0('weeks_on_list.', i)
    info <- list %>% select(author = author.row, 
                            title = title.row, 
                            weeks_on_list = weeks_on_list.row)
    df <- data.frame(info)
    info_total <- rbind(info_total, df)
  }
  info_total <- info_total %>% 
    distinct() %>%
    group_by(author) %>%
    arrange(-weeks_on_list)
  final <- info_total[1:10,]
  colnames(final) <- c("Authors", "Books", "Weeks")
  #View(final)
  return(final)
}

retrieve.data <- function(date) {
  key <- "2f6f47e7312b49239cd7617099bee3fe"
  base.url <-"https://api.nytimes.com/svc/books/v3/lists/overview.json"
  query.params <-list("api-key" = key, "published_date" = date)
  response <- GET(base.url, query = query.params)
  body <-content (response, "text")
  results <-as.data.frame(fromJSON(body))
  return(results)
}

create.data.frame <- function(results) {
  list <- as.data.frame(results$results.lists.books)
  length <- as.numeric(length(results$results.lists.books))
  info_total <- list %>% select(author, title, weeks_on_list)
  for (i in 1:(length - 1)) {
    i <- as.numeric(i)
    author.row <- paste0('author.', i)
    title.row <- paste0('title.', i)
    weeks_on_list.row <- paste0('weeks_on_list.', i)
    info <- list %>% select(author = author.row, 
                            title = title.row, 
                            weeks_on_list = weeks_on_list.row)
    df <- data.frame(info)
    info_total <- rbind(info_total, df)
  }
  info_total <- info_total %>% 
    distinct() %>%
    group_by(author) %>%
    arrange(-weeks_on_list)
  return(info_total)
}