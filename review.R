library("jsonlite")
library("httr")
library("tidytext")
library("dplyr")
library("stringr")
library("rvest")
library("wordcloud")
library("reshape2")

source("./api.key.R")
# test example: reviewdata <- ReviewWords("978-0375842207", "The Book Thief")

# Get all words in the book review
ReviewWords <- function(book.isbn, book.title) {
  base.url <- 'http://api.nytimes.com/svc/books/v3/reviews.json'
  query.params <- list(isbn = book.isbn, title = book.title,  api_key = key)
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

reviewdata <- ReviewWords(book.isbn, book.title)

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

negative.cloud <- NegativeCloud(reviewdata)

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

positive.cloud <- PositiveCloud(reviewdata)

# content.sent <- bind_rows(pos.words, neg.words)
# 
# cloud <- content.sent %>% 
#   count(word, sentiment, sort =TRUE) %>%
#   acast(word ~ sentiment, value.var = "n", fill = 0) %>%
#   comparison.cloud(scale = c(1.2,.5), random.order=TRUE, colors = c("#F8766D", "#00BFC4"),
#                    title.size = 2, max.words = Inf)

#this source: http://tidytextmining.com/tidytext.html 
#provided helpful information for working with tidytext data and
#for text mining in R



