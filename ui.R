library(shiny)
library(plotly)

shinyUI(fluidPage(
  navbarPage("NYT Books!",
             tabPanel("Introduction",
                      sidebarLayout(
                        sidebarPanel(
                          helpText("Our Final Project draws on data from the New York Times Books APi to analyze price, publishers, authors, reviews and ranking information. You can gain insight on the bestselling books by using the analysis. Contributers:  Kimberly Cabamalan, Yiran Jia, Weihao Ding, Josh Ma, Yogasai Gazula.")
                      ),
                      mainPanel(
                        plotlyOutput('popularity')
                      )
                      )
             ),
             tabPanel("Rank",
                      titlePanel("Rank of Books on the Bestseller Lists"),
                      sidebarLayout(
                        sidebarPanel(
                          helpText("Choose whether to see how different books compare with Rank or Weeks on the NYT Bestsellers List."),
                          selectInput("pop.indicator", label = h3("Popularity Indicator"),
                                      choices = list("Rank" = "Rank", "Weeks on List" = "Week")),
                          htmlOutput('selectUI'),
                          htmlOutput('dateUI')
                        ),
                        mainPanel(
                          plotlyOutput('popularity')
                        )
                      )
             ),
             
             tabPanel("Author and Publisher",
                      # Application title
                      titlePanel("Top 10 Bestsellers"),
                      
                      # Sidebar with a slider input for number of bins 
                      sidebarLayout(
                        sidebarPanel(
                          helpText("Choose a NYT Bestsellers List date below, and choose whether you want to see the bestselling authors or publishers for that date. This will display how long (weeks) their books were on the NYT Bestsellers List."),
                          selectInput('category', "Choose to see authors or publishers:", 
                                      choices = list("Authors" = "authors",
                                                     "Publishers" = "publishers")), 
                          dateInput('date',
                                    label = 'Choose a NYT Times BestSellers List Date:',
                                    value = Sys.Date()
                          )
                        ),
                        
                        # Show a plot of the generated distribution
                        mainPanel(
                          plotOutput('plot')
                        )
                      )
             ),
             tabPanel("Reviews",
                      # Application title
                      titlePanel("Positive/Negative Words in Review"),
                      
                      # Sidebar with a slider input for number of bins
                      sidebarLayout(
                        sidebarPanel(
                          helpText("Enter the title and ISBN # of a book to recieve wordclouds of the most frequently occurring negative words and positive words in the NYT review of that book."),
                          textInput("title", label = h3("Title"), value = "The Book Thief"),
                          textInput("isbn", label = h3("ISBN"), value = "978-0375842207"),
                          hr(),
                          fluidRow(column(3, verbatimTextOutput("value")))
                        ),
                        
                        # Show a plot of the generated distribution
                        mainPanel(
                          fluidRow(
                            splitLayout(plotOutput("negplot"), plotOutput("posplot"))
                          )
                        )
                      )
             ),
             tabPanel("Price",
                      titlePanel("Price and Popularity Scatter Plot"),
                      sidebarLayout(
                        sidebarPanel(
                          helpText("While our optimal goal is returning a graph no matter how long the time period the user requests, I strongly suggest TA(s) input two same dates (like 2017-06-08 to 2017-06-08) when test. The loading time is approximately 10-15mins. Please wait for more time if the error premature appears. We appreciate your patience. "),
                          dateRangeInput("dates",
                                         label = h3("Date range"),
                                         start="2017-09-20",
                                         end="2017-09-20"),
                          hr(),
                          fluidRow(column(4, verbatimTextOutput("value")))
                        ),
                        mainPanel(
                          plotlyOutput("yiranPlot")
                        )
                      )
             )
  )
))