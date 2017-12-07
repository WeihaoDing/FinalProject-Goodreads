library("jsonlite")
library("httr")
library("tidytext")
library("dplyr")
library("stringr")
library("rvest")
library("wordcloud")
library("reshape2")

source("./api.key.R")

# Get all words in the book review
ReviewWords <- function(book.isbn, book.title) {
  base.url <- 'http://api.nytimes.com/svc/books/v3/reviews.json'
  query.params <- list(isbn = book.isbn, title = book.title,  api_key = kim.key)
  response <- GET(base.url, query = query.params)
  body <- content(response, "text")
  results <- fromJSON(body)
  book.reviews <- flatten(results$results)
  
  url <- book.reviews$url[1]
  page <- read_html(url)
  
  # Extract review text from webpage
  review.content <- page %>% html_nodes('.story-body-text') %>% html_text() 
  
  # Create review text dataframe 
  dfcontent <- data.frame(review.content, stringsAsFactors = FALSE)
  
  # Create tidytext structure of all words in review
  all.words <- dfcontent %>% unnest_tokens(word, review.content)
  
  # Get all word counts
  word.count <- all.words %>% 
    group_by(word) %>% 
    summarize(count = n()) %>% 
    arrange(-count)
  
  # Remove stop words
  content.words <- word.count %>% 
    anti_join(stop_words, by="word")
  
  # Get content word counts -- arrange content.words by descending count
  content.count <- content.words %>%
    arrange(-count)
  
  return(content.count)
}

# Get wordcloud with negative words in review
NegativeCloud <- function(reviewdata) {
  
  # Get negative words in "nrc" Lexicon
  nrc.neg <- get_sentiments("nrc") %>% 
    filter(sentiment == "negative")
  
  # Count the negative words in the review data
  neg.words <- reviewdata %>%
    inner_join(nrc.neg, by ="word") 
  
  # Create the negative word cloud
  ncloud <- wordcloud(neg.words$word, neg.words$count, scale = c(3,.5), min.freq = 1, max.words = Inf, random.order = TRUE, colors = "#C40500")
  
  return(ncloud)
}

# Get wordcloud with positive words in review
PositiveCloud <- function(reviewdata) {
  
  # Get positive words in "nrc" Lexicon
  nrc.pos <- get_sentiments("nrc") %>% 
    filter(sentiment == "positive")
  
  # Count the positive words in the review data
  pos.words <- reviewdata %>%
    inner_join(nrc.pos, by ="word") 
  
  # Create the positive word cloud
  pcloud <- wordcloud(pos.words$word, pos.words$count, scale = c(3,.5), min.freq = 1, max.words = Inf, 
                      random.order = TRUE, colors = "#00BFC4")
  return(pcloud)
}