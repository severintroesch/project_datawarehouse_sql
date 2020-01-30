###
### Shinyapp CAS InfEng, Module BD/DWH 
### Finn & Severin

### https://severintroesch.shinyapps.io/shinyapp_dwh/

###
# This is the user-interface definition of a Shiny web application. http://shiny.rstudio.com


library(shiny)
library(shinythemes)

shinyUI(navbarPage(title = "Analysis of business profits (Frontend DB / DWH final exercise)", 
                   theme = shinytheme("superhero"),
                   
                   ## zero'th tab: description
                   tabPanel("Description", 
                            
                            p("This is the frontend of the final exercise of the DB/DWH-module in the CAS Information Engineering (ZHAW)."),
                            p("The presented analyses are based on a web-hosted MySQL / Pentaho backend and provide information about the 
                              profits of a fictitious business."),
                            hr(),
                            em("Finn Stein & Severin Troesch, November 2019")
                            
                            ),
                   
                   ## first tab: analysis 1 ----------------------------------------- ####
                   tabPanel("Analysis 1: Forecasting", 
                            
                            # Sidebar with a slider input for number of bins
                            sidebarLayout(
                              sidebarPanel(
                                "In this analysis, the profit (weekly mean) of the business is forecasted (blue) – based on a robust (i.e. outlier and 
                                missing value insensitive) time series analysis of the observed profits (black dots).",
                                hr(),
                                radioButtons(inputId = "y1", 
                                             label = "Choose number of weeks for forecasting", 
                                             choices = list("5","10","20"))

                              ),
                              
                              # Show a plot of the generated distribution
                              mainPanel(
                                plotOutput("plot1")
                                )
                              )
                            ),
                   
                   ## second tab: analysis 2 ----------------------------------------- ####
                   tabPanel("Analysis 2: Top five", 
                            
                            # Sidebar with a slider input for number of bins
                            sidebarLayout(
                              sidebarPanel(
                                "In this analysis, the top-levels (ordered by median of profit) for a chosen factor are shown as table and plot.",
                                hr(),
                                radioButtons(inputId = "fact_f2", 
                                             label = "Choose factor to show top-5 for:", 
                                             choices = list("state_province", "month", "job_title"))
                                
                              ),
                              
                              # Show table and plot of top five in component
                              mainPanel(
                                tableOutput("table1"),
                                hr(),
                                p(em("Plot uses logarithm of profit for better visual comparability of levels.")),
                                plotOutput("plot2")
                              )
                            )
                   ),
                   
                   ## third tab: analysis 3 ----------------------------------------- ####
                   tabPanel("Analysis 3: Clustering of customers", 
                            
                            # Sidebar with a slider input for number of bins
                            sidebarLayout(
                              sidebarPanel(
                                p("This analysis provides a 2D-visualisation of the dataset containing all information on purchasing behavior of the costumers. The dimensionality reduction is done via “t-SNE” (t-distributed stochastic neighbor embedding)."),
                                p("The t-SNE shows clusters (if present) of similar customers. These similar clusters could then be targeted with similar ads or offers"),
                                hr(),
                                radioButtons(inputId = "tsne_col", 
                                             label = "Choose factor for color-coding of plot:", 
                                             choices = list("job_title","state")),
                                hr(),
                                p(em("The t-SNE analysis has a random component to it. Therefore, reiteration of the analysis 
                                  might show a (slightly) different 2D picture. Multiple iterations might thus provide better insight:")),
                                actionButton("reiterate", "Start / Reiterate analysis",
                                             style="color: #fff; background-color: #337ab7; border-color: #2e6da4")
                                
                              ),
                              
                              # Show a plot of the generated distribution
                              mainPanel(
                                plotOutput("plot3")
                                )
                              )
                            )
                   )
        )

