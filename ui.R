library(shiny)
library(plotly)

shinyUI(fluidPage(
  navbarPage("NYT Books!",
             tabPanel("Price",
                      titlePanel("Price and Popularity Scatter Plot"),
                      sidebarLayout(
                        sidebarPanel(
                          helpText("While our optimal goal is returning a graph no matter how long the time period the user requests,I strongly suggest TA(s) input two same dates (like 2017-06-08 to 2017-06-08) when test. The loading time is approximately 10-15mins. Please wait for more time if the error premature appears. We appreciate your patient. "),
                          dateRangeInput("dates",
                                         label = h3("Date range"),
                                         start="2008-06-02",
                                         end=(Sys.Date()-77)),
                          hr(),
                          fluidRow(column(4, verbatimTextOutput("value")))
                        ),
                        mainPanel(
                          plotlyOutput("yiranPlot")
                        )
                      )
             ),
             
             
             tabPanel("Author and Publisher",
                      # Application title
                      titlePanel("Top 10 Bestsellers"),
                      
                      # Sidebar with a slider input for number of bins 
                      sidebarLayout(
                        sidebarPanel(
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
             tabPanel("Rank",
                      titlePanel("Rank of Books on the Bestseller Lists"),
                      sidebarLayout(
                        sidebarPanel(
                          selectInput("pop.indicator", label = h3("Popularity Indicator"),
                                      choices = list("Rank" = "Rank", "Weeks on List" = "Week")),
                          htmlOutput('selectUI'),
                          htmlOutput('dateUI')
                        ),
                        mainPanel(
                          plotlyOutput('popularity')
                        )
                      )
             )
  )
))