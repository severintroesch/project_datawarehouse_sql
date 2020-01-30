###
### Shinyapp CAS InfEng, Module BD/DWH 
### Finn & Severin
###
# This is the server logic for a Shiny web application. http://shiny.rstudio.com

### load packages
library(shiny)
library(RMySQL)
library(tidyverse)
library(forecast)
library(Rtsne)
library(cluster)


set.seed(666) #for reproducibility


### get dataset(from mysql webhost) ---- ####

## mysql connection options
options(mysql = list(
  "host" = "remotemysql.com",
  "port" = 3306,
  "user" = "zVQqkOrZWw",
  "password" = "f2eD7uSkyj"
))

## select database name (given from webhost)
database <- "zVQqkOrZWw"


## define SQL query execution function
ex_query <- function(dbname, query) {
  
          # Connect to the database
          db <- dbConnect(MySQL(), 
                          dbname = dbname, 
                          host = options()$mysql$host, 
                          port = options()$mysql$port, 
                          user = options()$mysql$user, 
                          password = options()$mysql$password)
          
          # Submit the query and disconnect
          data <- dbGetQuery(db, query)
          dbDisconnect(db)
          data
          
          }

## retrieve and clean data frames for three analyses ----
# analysis 1:
q_f1 = paste("SELECT f.Gewinn_nach_Discount AS gewinn, d.month, d.cw, d.weekday", 
             "FROM facts f",
             "JOIN date d",
             "ON f.date_id = d.id")

df_f1<- ex_query(database,q_f1)


# analysis 2:
q_f2 = paste("SELECT f.Gewinn_nach_Discount AS gewinn, c.last_name, c.first_name, c.state_province, c.job_title, p.product_name, p.category, d.month", 
             "FROM facts f",
             "JOIN customer c",
             "ON f.customer_id = c.id",
             "JOIN product p",
             "ON f.product_id = p.id",
             "JOIN date d",
             "ON f.date_id = d.id",
             "ORDER BY f.Gewinn_nach_Discount DESC")

df_f2 <- ex_query(database,q_f2)


# analysis 3:
q_f3 = paste("SELECT *", 
             "FROM facts f",
             "JOIN customer c",
             "ON f.customer_id = c.id",
             "JOIN product p",
             "ON f.product_id = p.id",
             "JOIN date d",
             "ON f.date_id = d.id",
             "ORDER BY f.Gewinn_nach_Discount DESC")

df_f3 <- ex_query(database,q_f3)

#get rid of all id variables
df_f3_f <- df_f3[,colnames(df_f3)!="id"] %>% 
  # and of the uninteresting stuff
  select(-c(11:19)) %>% #unselect (broadly) the variables that have not to do with purchasing-bahaviour (customer specs)
  # and factorize
  mutate_if(is.character, as.factor)





### code server function -------------------------------------------------------- ####
shinyServer(function(input, output) {

  ### Analysis 1: ------------------------------------------ ####
  output$plot1 <- renderPlot({
    
    # tconstruct df
    tsdat <- df_f1 %>% 
      group_by(cw) %>% # means by calendar week
      summarise(mean_gewinn = mean(gewinn, na.rm = T)) %>% 
      full_join(tibble(cw = c(1:25))) %>% #explicit missing values
      arrange(cw)
    
    # tconstruct time series
    ts_f1 <- ts(tsdat$mean_gewinn)
    
    # forecast-plot
    forecast(ts_f1, 
             h = as.numeric(input$y1), #Number of periods for forecasting - based on ui
             robust = T) %>% #robust to missing values and outliers
      autoplot() + #plotting
      geom_point(aes(x = tsdat$cw, y = tsdat$mean_gewinn))+
      labs(x = "Calendar week",
           y = "Mean profit (USD)",
           title = "Robust ETS forecast of mean profit by workweek")
      #theme_bw()


  })
  
  
  ### Analysis 2: ------------------------------------------ ####
  
  # table of top 5
  output$table1 <- renderTable({
    
    # select component based on ui
    xf2 = input$fact_f2 
    
    # ugly processing of dataframe for table:
    
    # step 1
    df_f2_fil = df_f2 %>% 
      group_by(!!as.name(xf2)) %>% 
      mutate(median = median(gewinn)) %>% 
      ungroup() %>% 
      mutate(rank = dense_rank(-median)) %>% 
      filter(rank < 6) %>% arrange(rank)
    
    # step 2: define and show top-5 table
    df_f2_fil %>% group_by(!!as.name(xf2)) %>% 
      summarise(profit_median_usd = median(gewinn)) %>% 
      arrange(desc(profit_median_usd)) %>% slice(1:5)
    
  })
  
  # plot of top-5
  output$plot2 <- renderPlot({
    
    # select component based on ui
    xf2 = input$fact_f2 
    
    # ugly processing of dataframe for plot
    df_f2_fil = df_f2 %>% 
      group_by(!!as.name(xf2)) %>% 
      mutate(median = median(gewinn)) %>% 
      ungroup() %>% 
      mutate(rank = dense_rank(-median)) %>% 
      filter(rank < 6) %>% arrange(rank)
    
    # draw plot
    ggplot(df_f2_fil, aes(y = log(gewinn),
                          x = reorder(!!as.name(xf2), -gewinn, FUN = "median")))+#reorder(!!as.name(xf2), -gewinn, FUN = median)))+
      geom_boxplot()+
      labs(x = paste("Top levels for",xf2),
           y = "Logarithm of profit (USD)")
    
  })
  
  
  ### Analysis 3: ------------------------------------------ ####
  
  # build t-sne data
  randomVals <- eventReactive(input$reiterate, {
    ## t-SNE: only neighbors are modeled, distances between clusters not meaningful
    
    # build pairwise dissimilarity matrix for tsne
    dist_tsne <- daisy(df_f3_f)
    
    # execute tsne - as this is random, it will yield a slightly different result on each reiteration
    resTSNE <- Rtsne(dist_tsne, 
                     perplexity = 10, # perplexity ~ # neighbors, normal: 5 - 50, should be < # observations
                     max_iter = 2000)
    d_tsne = as.data.frame(resTSNE$Y)
    names(d_tsne) = c("tsne1","tsne2")
    
    # plotting variables
    d_tsne <- d_tsne %>% mutate(customer_name = df_f3$last_name,
                                job_title = df_f3$job_title,
                                state = df_f3$state_province)
    
    d_tsne
  })
  
  # plot t-sne
  output$plot3 <- renderPlot({
    
    
    # plot
    ggplot(data=randomVals(),
           aes(x=tsne1, y=tsne2,
               label=customer_name, color = !!as.name(input$tsne_col))) +
      geom_text(size=3, vjust = -1.2) +
      geom_point()+
      ggtitle("2D t-SNE visualization of coustomer similarities")
      #theme_bw()
    
  })
  

})
