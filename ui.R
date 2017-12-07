library(shiny)
library(plotly)



# Define UI for application that draws a histogram
shinyUI(fluidPage(
  navbarPage("NYT Books!",
             tabPanel("Yiran",
                      titlePanel("Price and Popularity Scatter Plot"),
                      sidebarLayout(
                        sidebarPanel(
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
             
             
             tabPanel("Kim",
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
)










)
))