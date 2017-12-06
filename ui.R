source("price.R")

my.ui <-navbarPage("NYT Books!",
                   
                   
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
                    titlePanel("Author and Populatiry Bar Plot"),
                    sidebarLayout(
                      sidebarPanel(   "say hello"
                        
                      ),
                      mainPanel(    "say hello"
                        
                        
                      )
                    )
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    )
           
           
           
           
           
)


shinyUI(my.ui)