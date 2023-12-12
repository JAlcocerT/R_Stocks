######################

library("yfR") #historical stock valuation -> Instead of BatchGetSymbols
library("priceR") #inflation / currency exchange ===> adjust_for_inflation
library("quantmod") #dividends (getDividends), metals price

library("dplyr")
library("tidyr") #drop_na
library("lubridate") #year

library('plotly')

library("shiny")
library("shinythemes")
library("shinyWidgets")
library("bslib")


library("DT")

library("viridis")


################################################



test_ticker <- c('KO','PG','JNJ','TROW','PEP','MCD','PFE','SPY','XOM')
my_index <- c('^GSPC','^DJI','^DAX','^VIX')



initial_date="2005-01-01" #year(initial_date)

#ending_date="2023-01-14"
ending_date="2022-12-31"



##### tabpanel -> Stock Analysis #####
df_historical <- yf_get(tickers = test_ticker,          ### yfr ###
                        #last_date= Sys.Date()-1,
                        first_date= initial_date,
                        last_date= ending_date,
                        thresh_bad_data = 0.2,
                        freq_data="monthly") %>% select(ticker, price_close, ref_date)


df_historical$ref_date_year = year(df_historical$ref_date)

##### tabpanel -> Dividend Analysis #####

divs <- getDividends(test_ticker[1],                   ### QuandMod ###
                     from = initial_date,
                     to = ending_date,
                     src = "yahoo",
                     auto.assign = TRUE,
                     auto.update = TRUE,
                     verbose = FALSE)


divs <- data.frame(date=index(divs), coredata(divs))
colnames(divs) <- c('date','div')


### Divs Evolution ###

divs$ticker <- rep(test_ticker[1],nrow(divs))


for(i in 2:length(test_ticker)) {

  aux <- getDividends(test_ticker[i],
                      from = initial_date,
                      to = ending_date,
                      src = "yahoo",
                      auto.assign = TRUE,
                      auto.update = TRUE,
                      verbose = FALSE)


  aux <- data.frame(date=index(aux), coredata(aux))
  colnames(aux) <- c('date','div')

  aux$ticker <- rep(test_ticker[i],nrow(aux))

  #append
  divs <- rbind(divs, aux)

}


### GROUP BY YEAR & ticker

divs_agg <- setNames( aggregate(div ~ year(date) + ticker, data = divs, FUN = sum, na.rm = TRUE),
                      c("Year_div","ticker","div"))


### Historical yield evolution

# historical splits
hist_splits <- quantmod::getSplits(test_ticker[1])
hist_splits <- data.frame(date=index(hist_splits), coredata(hist_splits))
colnames(hist_splits) <- c('ref_date','split')
hist_splits$ticker <- rep(test_ticker[1],nrow(hist_splits))

hist_splits =  hist_splits %>% arrange(desc(ref_date))
hist_splits =  transform(
  hist_splits,
  split_c = cumprod(c(na.omit(split)))
)

for(i in 2:length(test_ticker)) {

  aux <- quantmod::getSplits(test_ticker[i])
  aux <- data.frame(date=index(aux), coredata(aux))

  colnames(aux) <- c('ref_date','split')
  aux$ticker <- rep(test_ticker[i],nrow(aux))


  aux =  aux %>% arrange(desc(ref_date))
  aux =  transform(
    aux,
    split_c = cumprod(c(na.omit(split)))
  )

  #append
  hist_splits <- rbind(hist_splits, aux)
}

hist_splits$ym <- format(as.Date(hist_splits$ref_date), "%Y-%m")

colnames(divs) <- c('ref_date','div','ticker')
divs$ym <- format(as.Date(divs$ref_date), "%Y-%m")
df_historical$ym <- format(as.Date(df_historical$ref_date), "%Y-%m")

#join the DF's
df_hist_yield = left_join(df_historical, divs, by=c('ym','ticker'))
df_hist_yield = left_join(df_hist_yield, hist_splits, by=c('ym','ticker'))


for(i in 1:length(test_ticker)) {

  df_hist_yield[df_hist_yield$ticker== test_ticker[i],] =  fill(df_hist_yield[df_hist_yield$ticker== test_ticker[i],] , div, .direction = 'down')

  df_hist_yield[df_hist_yield$ticker== test_ticker[i],] =  fill(df_hist_yield[df_hist_yield$ticker== test_ticker[i],] , split_c, .direction = 'up')

}


df_hist_yield$div_yield <- 4*100*df_hist_yield$div/df_hist_yield$price_close
df_hist_yield$split_c = df_hist_yield$split_c %>% replace_na(1)
df_hist_yield$yield_corrected <- df_hist_yield$div_yield/df_hist_yield$split_c ### end historical yield evolution






##### tabpanel -> Portfolio Analysis #####




#inflation & money input (priceR)

Year <- (year(initial_date)-1):(year(ending_date)-1)
nominal_prices <- rep(1,length(Year))

df_inflation <- data.frame(Year, nominal_prices)
df_inflation$in_202x_dollars_factor <- adjust_for_inflation(nominal_prices, Year, "US", to_date = (year(ending_date)-2)) ###PriceR###


df_inflation <- mutate(df_inflation,
                       yearly_inflation = 100*( lag(in_202x_dollars_factor)/in_202x_dollars_factor -1)
)%>% drop_na()

df_inflation[nrow(df_inflation) + 1,] <- c(2023, 1,0.95,1)



df_inflation <- mutate(df_inflation, inflation_level = ( lag(in_202x_dollars_factor)/in_202x_dollars_factor -1)*100 )



##### tabpanel -> Indexes #####


# fetch data
df_index <- yf_get(tickers = my_index,
                   first_date = initial_date,
                   last_date = ending_date,
                   freq_data = "weekly") %>%
  select('ticker','ref_date','price_close')

colnames(df_index) <- c('index','ref_date','price_index')






###############

custom_theme <- bs_theme(

  bootswatch = 'flatly' #cerulean'

)



min_year = year(initial_date)
max_year = year(ending_date)


#library(RColorBrewer)
#colors <- brewer.pal(10, "Set3")  # Change "10" to the number of groups in your data

light_dark <- '#F5F5F5'
hex_bg_lot <- '#dddddd'


################################################

ui <- fluidPage(
  # All your styles will go here
  #tags$style(HTML(".js-irs-0 .irs-single, .js-irs-0 .irs-bar-edge, .js-irs-0 .irs-bar {background: purple}")),
  

 
  #theme = bs_theme(),  #To try themes on the go
  theme = custom_theme,

  
  tags$head(
    tags$style(HTML("
      .tab-content {
        background-color: #FFFFFF;
      }
    "))
  ),
  
 
  titlePanel(h1("R Stocks", align = "center", style = "color: #000000; background-color: #FFFFFF; font-size: 50px;")),
 
  
  div(style = "background-color: #CCCCFF", #to all tabsetPanel
  tabsetPanel(  
    
    
    tabPanel("Portfolio Analysis",
             sidebarLayout(
               sidebarPanel(width = 3,
                            
                            sliderInput("years_portf",
                                        label = h3("Years investing"),
                                        min = min_year, max = max_year-1, value = c(min_year, 2020)),
                            sliderInput("year_yoc",
                                        "YoC looking from the year (TODAY*)",
                                        min = min_year, max = max_year-1, value = 2021,width = "90%"),
                            sliderInput("money_in_portf",
                                        "Monetary input - Monthly (value of 2021)",
                                        min = 100, max = 5000, value = 1000,width = "90%"),
                            selectInput(
                              'selected_tickers_portf',
                              'Tickers',
                              test_ticker,
                              selected = c('KO','PG','JNJ'),
                              multiple = TRUE,
                              selectize = TRUE,
                              width = NULL,
                              size = NULL
                            ),
                            checkboxInput("yearly_dca", "Yearly DCA instead of Full Period", FALSE),
                            
                            
                            
               ),
               
               mainPanel(
                 fluidRow(
                   column(12,
                          h1('Cash Flow Analysis - No Dividend Re-investment', align = "center"),
                          br(),
                          br(),
                          plotlyOutput("YoC"),
                          br(),
                          plotlyOutput('Div_CF'),
                          br(),
                          plotlyOutput('Stocks_bought'),
                          br(),
                          plotlyOutput('YoC_hist'),
                          br(),
                          plotlyOutput('CF_hist'),
                          br(),
                          DTOutput('DCA_DF'),
                          #DTOutput('DCA_DF_v2'),
                          #DTOutput('DCA_DF_v3'),
                          plotlyOutput('DCA_Portfolio'),
                          ##add capital gain over years
                   )
                 )
               ) #end main panel (currencies)
             ) #end sidebarLayout (currencies)
             
    ), #end tab panel end (Portfolio Analysis)
    #consider a TAB for dividend RE-INVEsTING
    
    #START OF THE STOCK ANALYSIS TABPANEL
    tabPanel("Stocks Analysis",
             
             tags$head(tags$style(HTML('
  .main-header .logo {
    font-family: "Georgia", Times, "Times New Roman", serif;
    font-weight: bold;
    font-size: 24px;
    color: #000000; /* Change this to your preferred color */
  }
'))),
           
             
             sidebarLayout(
               sidebarPanel(width = 3,
                           
                            setSliderColor(c("#CCCCFF","#CCCCFF","#CCCCFF","#CCCCFF","#CCCCFF","#CCCCFF","#CCCCFF"),
                                           c(1, 2,3, 4,5,6,7)),
                            sliderInput("years_stocks",
                                        label = h3("Years"),
                                        min = min_year, max = max_year, value = c(min_year, 2020)),
                            selectInput(
                              'selected_tickers',
                              'Tickers',
                              test_ticker,
                              selected = c('PG','JNJ'),
                              multiple = TRUE,
                              selectize = TRUE,
                              width = NULL,
                              size = NULL
                            ),
               ),
               
               mainPanel(
                 fluidRow(
                   column(12,
                         
                          h1('yfR', align = "center"),
                          br(),
                          plotlyOutput("Stocks_evolution"),
                          br(),
                         
                   )
                 )
               ) #end main panel (stock analysis)
             ) #end sidebarLayout (stock analysis)
             
    ), #tab panel end stock analysis###
   
    tabPanel("Dividends Analysis",
             sidebarLayout(
               sidebarPanel(width = 3,
                           
                           
                            sliderInput("years_divs",
                                        label = h3("Years"),
                                        min = min_year, max = max_year, value = c(min_year, 2022)),
                            selectInput(
                              'selected_tickers_div',
                              'Tickers',
                              test_ticker,
                              selected = c('PG','JNJ'),
                              multiple = TRUE,
                              selectize = TRUE,
                              width = NULL,
                              size = NULL
                            ),
                            sliderInput("n_years",
                                        "Check n-y Dividend Growth",
                                        min = 1, max = 10, value = 2,width = "90%"),
               ),
               
               mainPanel(
                 fluidRow(
                   column(12,
                          h1('QuantMod', align = "center"),
                          br(),
                          plotlyOutput("Dividend_evolution"),
                          br(),
                          plotlyOutput("Dividend_n_growth"),
                          br(),
                          plotlyOutput("Dividend_n_growth_distrib"),
                          br(),
                          h1('QuantMod & yfR', align = "center"),
                          br(),
                          plotlyOutput("Hist_yield_evolution"),
                          br(),
                          plotlyOutput("Hist_yield_box"),
                          br(),
                          br(),
                         
                   )
                 )
               ) #end main panel (dividend analysis)
             )
    ), #dividend analysis tab panel end ###
    
    tabPanel("Indexes",
             sidebarLayout(
               sidebarPanel(width = 3,
                           
                            sliderInput("years_indexes",
                                        label = h3("Years"),
                                        min = min_year, max = max_year, value = c(min_year, 2022)),
                            selectInput(
                              'selected_indexes',
                              'Select Indexes',
                              my_index,
                              selected = c('^GSPC'),
                              multiple = TRUE,
                              selectize = TRUE,
                              width = NULL,
                              size = NULL
                            ),
               ),
               
               mainPanel(
                 fluidRow(
                   column(12,
                          h1('Indexes', align = "center"),
                          plotlyOutput("Index_Evolution"),
                   )
                 )
               ) #end main panel (indexes)
             ) #end sidebarLayout (indexes)
    ), #tab panel end (indexes)
   
  ) #end tabsetPanel
) #end div tabsetPanel
) #ui: fluidpage




server <- function(input, output, session){
 
 
 
 
  #bs_themer() #To try themes on the go
 
 
  ##### tabpanel -> Stock Analysis #####
  ### Dataframes ###
 
  df_historical_interactive <- reactive ({
   
    return(          
      filter(df_historical[df_historical$ticker %in% input$selected_tickers ,],
             year(ref_date) >= input$years_stocks[1] &
               year(ref_date) <= input$years_stocks[2])
    )
  })
 
 
  ### GRAPHS ###
  output$Stocks_evolution <-renderPlotly({
    # plot_ly(df_historical_interactive(), type = 'scatter', mode = 'lines')%>%
    #   add_trace(x = ~ref_date, y = ~price_close, name = ~ticker) %>%
    #   layout(title = '<b>Stocks Price Evolution<b>', xaxis = list(title = 'Date'),
    #          yaxis = list(title = 'Price ($)'), legend = list(title=list(text='<b> Tickers </b>')))
    
    # plot_ly(df_historical_interactive(), type = 'scatter', mode = 'lines') %>%
    #   add_trace(x = ~ref_date, y = ~price_close, name = ~ticker) %>%
    #   layout(
    #     title = '<b>Stocks Price Evolution<b>', 
    #     xaxis = list(title = 'Date'),
    #     yaxis = list(title = 'Price ($)'), 
    #     legend = list(title=list(text='<b> Tickers </b>')),
    #     plot_bgcolor = '#084218' #'rgba(240, 240, 240, 0.8)'  # Change this to your preferred color
    #   )
    
    # plot_ly(df_historical_interactive(), type = 'scatter', mode = 'lines') %>%
    #   add_trace(x = ~ref_date, y = ~price_close, name = ~ticker) %>%
    #   layout(
    #     title = '<b>Stocks Price Evolution<b>',
    #     xaxis = list(title = 'Date', gridcolor = 'rgba(255, 255, 255, 0.8)'),  # Change grid color here
    #     yaxis = list(title = 'Price ($)', gridcolor = 'rgba(255, 255, 255, 0.8)'),  # And here
    #     legend = list(title=list(text='<b> Tickers </b>')),
    #     plot_bgcolor = '#717D7E' #'#2E2E33'  # 'rgba(240, 240, 240, 0.8)'  # Change this to your preferred color
    #   )
    # 
    # 
    
    
    # plot_ly(df_historical_interactive(), type = 'scatter', mode = 'lines') %>%
    #   add_trace(x = ~ref_date, y = ~price_close, name = ~ticker, color = ~ticker, colors = colors) %>%
    #   layout(
    #     title = '<b>Stocks Price Evolution<b>', 
    #     xaxis = list(title = 'Date', gridcolor = 'rgba(255, 255, 255, 0.8)'),  # Change grid color here
    #     yaxis = list(title = 'Price ($)', gridcolor = 'rgba(255, 255, 255, 0.8)'),  # And here
    #     legend = list(
    #       title = list(text = '<b> Tickers </b>'),
    #       bgcolor = light_dark, #'rgba(255, 255, 255, 0.8)',  # Change the background color of the legend here
    #       font = list(color = 'black')  # Change the font color of the legend here
    #     ),
    #     plot_bgcolor = '#717D7E' #light_dark  # Change this to your preferred color
    #   )
    # 
    
    
    #library(viridis)
    
    #Create a color palette
    colors <- viridis(n = length(unique(df_historical_interactive()$ticker)))

    plot_ly(df_historical_interactive(), type = 'scatter', mode = 'lines') %>%
      add_trace(x = ~ref_date, y = ~price_close, name = ~ticker, color = ~ticker, colors = colors) %>%
      layout(
        title = '<b>Stocks Price Evolution<b>',
        xaxis = list(title = 'Date', gridcolor = 'rgba(255, 255, 255, 0.8)'),  # Change grid color here
        yaxis = list(title = 'Price ($)', gridcolor = 'rgba(255, 255, 255, 0.8)'),  # And here
        legend = list(
          title = list(text = '<b> Tickers </b>'),
          bgcolor = light_dark, #'rgba(255, 255, 255, 0.8)',  # Change the background color of the legend here
          font = list(color = 'black')  # Change the font color of the legend here
        ),
        plot_bgcolor =  hex_bg_lot #'#717D7E' #light_dark  # Change this to your preferred color
      )

    
  })
 
 
 
 
  ##### tabpanel -> Dividend Analysis #####                                    
  ### Dataframes ###
 
  divs_agg_interactive <- reactive ({
   
   
    return(          
      filter(divs_agg[divs_agg$ticker %in% input$selected_tickers_div ,] ,
             Year_div >= input$years_divs[1] &
               Year_div <= input$years_divs[2])
    )
   
  })
 
 
 
  growth_df_interactive  <- reactive ({
   
    divs_agg = divs_agg_interactive()
   
    growth_df <- data.frame( #empty dataframe
      year_growth = integer(),
      Ticker = character(),
      Growth_hist = double())
    growth_hist=c()
    #n=1 #dividend growth of year Z vs Z-n (anualized)
    n=input$n_years
   
    unique(divs_agg$ticker)
   
    for ( j in 1:length(unique(divs_agg$ticker)) ) {
     
      divs_agg_ticker <- filter(divs_agg,ticker %in% unique(divs_agg$ticker)[j])
     
     
      growth_hist=c()
      for(i in (n+1):nrow(divs_agg_ticker)) {
       
       
        growth_hist[i-n] = ( (divs_agg_ticker$div[i]/divs_agg_ticker$div[i-n])^(1/n) -1)*100
       
      }
     
     
     
      growth_df <-  rbind(growth_df,
                          data.frame(year_growth=divs_agg_ticker$Year_div[- (1:n)], growth_hist) %>% mutate(Ticker = unique(divs_agg$ticker)[j])
      )
     
    }
   
    return(growth_df)
   
  })
 
 
  df_hist_yield_interactive <- reactive ({
    return(          
      filter(df_hist_yield[df_hist_yield$ticker %in% input$selected_tickers_div ,] ,
             year(ref_date.x) >= input$years_divs[1] &
               year(ref_date.x) <= input$years_divs[2])
    )
  })
 
 
  quandl_df_interactive  <- reactive ({
   
    df1_quandl =  df1_quandl[df1_quandl$ticker %in% input$selected_tickers_div ,]
   
    return(
      df1_quandl  %>% filter( year(df1_quandl$calendardate) >= input$years_divs[1] &
                                year(df1_quandl$calendardate) <= input$years_divs[2])
    )
  })
 
  ### GRAPHS ###
 
 
  output$Dividend_evolution <-renderPlotly({
   
    # 
    # plot_ly(
    #   data = divs_agg_interactive(),
    #   x = ~Year_div,
    #   y = ~div,
    #   type = "bar",
    #   name = ~ticker,
    #   color=~ticker
    # )  %>%
    #   layout(title = '<b>Dividend Evolution<b>', xaxis = list(title = 'Date'),
    #          yaxis = list(title = 'Dividend ($)'), legend = list(title=list(text='<b> Tickers </b>')))
    
    #library(viridis)
    
    # Create a color palette
    colors <- viridis(n = length(unique(divs_agg_interactive()$ticker)))
    
    plot_ly(
      data = divs_agg_interactive(),
      x = ~Year_div,
      y = ~div,
      type = "bar",
      name = ~ticker,
      color = ~ticker,
      colors = colors
    )  %>%
      layout(
        title = '<b>Dividend Evolution<b>', 
        xaxis = list(title = 'Date', gridcolor = 'rgba(255, 255, 255, 0.8)'),  # Change grid color here
        yaxis = list(title = 'Dividend ($)', gridcolor = 'rgba(255, 255, 255, 0.8)'),  # And here
        legend = list(
          title = list(text = '<b> Tickers </b>'),
          bgcolor = light_dark, #'rgba(255, 255, 255, 0.8)',  # Change the background color of the legend here
          font = list(color = 'black')  # Change the font color of the legend here
        ),
        plot_bgcolor = hex_bg_lot  #'#717D7E' #light_dark  # Change this to your preferred color
      )
    
   
   
  })
 
 
  output$Dividend_n_growth <-renderPlotly({
   
  
   
    # plot_ly(growth_df_interactive(), type = 'scatter', mode = 'lines')%>%
    #   add_trace(x = ~year_growth, y = ~growth_hist, name = ~Ticker) %>%
    #   layout(title =sprintf("<b>Dividend Growth Evolution %s-y<b>", input$n_years), xaxis = list(title = 'Date'),
    #          yaxis = list(title = '% Growth Rate'), legend = list(title=list(text='<b> Tickers </b>')))
   
   
    #library(viridis)
    
    # Create a color palette
    colors <- viridis(n = length(unique(growth_df_interactive()$Ticker)))
    
    plot_ly(growth_df_interactive(), type = 'scatter', mode = 'lines') %>%
      add_trace(x = ~year_growth, y = ~growth_hist, name = ~Ticker, color = ~Ticker, colors = colors) %>%
      layout(
        title = sprintf("<b>Dividend Growth Evolution %s-y<b>", input$n_years), 
        xaxis = list(title = 'Date', gridcolor = 'rgba(255, 255, 255, 0.8)'),  # Change grid color here
        yaxis = list(title = '% Growth Rate', gridcolor = 'rgba(255, 255, 255, 0.8)'),  # And here
        legend = list(
          title = list(text = '<b> Tickers </b>'),
          bgcolor = light_dark, #'rgba(255, 255, 255, 0.8)',  # Change the background color of the legend here
          font = list(color = 'black')  # Change the font color of the legend here
        ),
        plot_bgcolor = hex_bg_lot #'#717D7E' #light_dark  # Change this to your preferred color
      )
    
    
  })
 
 
  output$Dividend_n_growth_distrib <-renderPlotly({
   
   
   
    # plot_ly(growth_df_interactive(), y=~growth_hist, type = 'box', name = ~Ticker) %>%
    #   layout(title =sprintf("<b>Dividend Growth %s-y Distribution<b>", input$n_years), xaxis = list(title = '<b> Tickers </b>'),
    #          yaxis = list(title = '% Growth Rate'), legend = list(title=list(text='<b> Tickers </b>')))
   
    #library(viridis)
    
    # Create a color palette
    colors <- viridis(n = length(unique(growth_df_interactive()$Ticker)))
    
    plot_ly(growth_df_interactive(), y = ~growth_hist, type = 'box', name = ~Ticker, color = ~Ticker, colors = colors) %>%
      layout(
        title = sprintf("<b>Dividend Growth %s-y Distribution<b>", input$n_years), 
        xaxis = list(title = '<b> Tickers </b>', gridcolor = 'rgba(255, 255, 255, 0.8)'),  # Change grid color here
        yaxis = list(title = '% Growth Rate', gridcolor = 'rgba(255, 255, 255, 0.8)'),  # And here
        legend = list(
          title = list(text = '<b> Tickers </b>'),
          bgcolor = light_dark, #'rgba(255, 255, 255, 0.8)',  # Change the background color of the legend here
          font = list(color = 'black')  # Change the font color of the legend here
        ),
        plot_bgcolor = hex_bg_lot #'#717D7E' #light_dark  # Change this to your preferred color
      )
    
  })
 
 
  output$Hist_yield_evolution <-renderPlotly({
   
    # plot_ly(df_hist_yield_interactive(), type = 'scatter', mode = 'lines') %>%
    #   add_trace(x = ~ym, y = ~yield_corrected, name = ~ticker)  %>%
    #   layout(title = paste('<b>Historical Yield Evolution<b> - Period ',input$years_divs[1], ' to ',input$years_divs[2],sep=""), xaxis = list(title = 'Date'),
    #          yaxis = list(title = '% Yield'), legend = list(title=list(text='<b> Tickers </b>')))
    
    #library(viridis)
    
    # Create a color palette
    colors <- viridis(n = length(unique(df_hist_yield_interactive()$ticker)))
    
    plot_ly(df_hist_yield_interactive(), type = 'scatter', mode = 'lines') %>%
      add_trace(x = ~ym, y = ~yield_corrected, name = ~ticker, color = ~ticker, colors = colors)  %>%
      layout(
        title = paste('<b>Historical Yield Evolution<b> - Period ',input$years_divs[1], ' to ',input$years_divs[2],sep=""), 
        xaxis = list(title = 'Date', gridcolor = 'rgba(255, 255, 255, 0.8)'),  # Change grid color here
        yaxis = list(title = '% Yield', gridcolor = 'rgba(255, 255, 255, 0.8)'),  # And here
        legend = list(
          title = list(text = '<b> Tickers </b>'),
          bgcolor = light_dark, #'rgba(255, 255, 255, 0.8)',  # Change the background color of the legend here
          font = list(color = 'black')  # Change the font color of the legend here
        ),
        plot_bgcolor = hex_bg_lot # '#717D7E' #light_dark  # Change this to your preferred color
      )
    
    
    
  })
 
  output$Hist_yield_box <-renderPlotly({
   
    # plot_ly(
    #   data = df_hist_yield_interactive(),
    #   y = ~yield_corrected,
    #   type = 'box',
    #   name = ~ticker,
    #   color=~ticker
    # )  %>%
    #   layout(title = paste('<b>Historical Yield Distribution<b> - Period ',input$years_divs[1], ' to ',input$years_divs[2],sep=""), xaxis = list(title = 'Tickers'),
    #          yaxis = list(title = '% Growth Rate'), legend = list(title=list(text='<b> Tickers </b>')))
    
    
    #library(viridis)
    
    # Create a color palette
    colors <- viridis(n = length(unique(df_hist_yield_interactive()$ticker)))
    
    plot_ly(
      data = df_hist_yield_interactive(),
      y = ~yield_corrected,
      type = 'box',
      name = ~ticker,
      color = ~ticker,
      colors = colors
    )  %>%
      layout(
        title = paste('<b>Historical Yield Distribution<b> - Period ',input$years_divs[1], ' to ',input$years_divs[2],sep=""), 
        xaxis = list(title = 'Tickers', gridcolor = 'rgba(255, 255, 255, 0.8)'),  # Change grid color here
        yaxis = list(title = '% Growth Rate', gridcolor = 'rgba(255, 255, 255, 0.8)'),  # And here
        legend = list(
          title = list(text = '<b> Tickers </b>'),
          bgcolor = light_dark, #'rgba(255, 255, 255, 0.8)',  # Change the background color of the legend here
          font = list(color = 'black')  # Change the font color of the legend here
        ),
        plot_bgcolor = hex_bg_lot #'#717D7E' #light_dark  # Change this to your preferred color
      )
    
    
    
  })
 
 
 
 
  ##### tabpanel -> Portfolio Analysis #####
  ### Dataframes ###
 
  hist_price_infl_filtered_interactive <- reactive ({
   
    # df_inflation$money_input_infl <-input$money_in_portf/df_inflation$in_2020_dollars_factor
    #   df_inflation$money_input_infl_year <-  length(unique(input$selected_tickers_portf))*input$money_in_portf/df_inflation$in_2020_dollars_factor
   
   
   
    df_inflation$money_input_infl <-input$money_in_portf/length(unique(input$selected_tickers_portf))/df_inflation$in_202x_dollars_factor
    df_inflation$money_input_infl_year <- input$money_in_portf/df_inflation$in_202x_dollars_factor
   
   
    df_historical$Year <- as.integer(format(as.Date(df_historical$ref_date), "%Y"))
   
    hist_price_infl <- left_join(df_historical, df_inflation, by=c('Year'))
    hist_price_infl$Stocks <- hist_price_infl$money_input_infl/hist_price_infl$price_close          #no round down !!!!!!!!
   
    hist_price_infl_filtered = hist_price_infl[hist_price_infl$Year>= input$years_portf[1] &
                                                 hist_price_infl$Year<= input$years_portf[2]  
                                               & hist_price_infl$ticker %in% input$selected_tickers_portf ,]      
    return(hist_price_infl_filtered)
   
  })
 
 
  DCA_df_interactive <- reactive ({
   
    DCA_df <- setNames(
      aggregate(hist_price_infl_filtered_interactive()$Stocks,            
                by=list(Category=hist_price_infl_filtered_interactive()$ticker),
                FUN=sum),  # setNames function
      c("ticker", "Stocks"))
   
   
    DCA_df$DCA <- (sum(hist_price_infl_filtered_interactive()$money_input_infl)/length(unique(input$selected_tickers_portf)))/DCA_df$Stocks
   
   
    return(DCA_df)
   
  })
 
 
  DCA_df_divs_interactive  <- reactive ({
   
   
    DCA_df_divs <- left_join(DCA_df_interactive(), divs_agg[divs_agg$Year_div== input$year_yoc,]%>% group_by(ticker), by=c('ticker'='ticker')) #join to latest values
   
    #DCA_df_divs <- left_join(DCA_df_divs, hist_price_infl_filtered %>% group_by(ticker) %>% top_n(1, ym), by=c('ticker'='ticker'))#join to latest values
   
   
    DCA_df_divs$invested <- DCA_df_divs$Stocks*DCA_df_divs$DCA
    DCA_df_divs$div_cash_flow <- DCA_df_divs$Stocks*DCA_df_divs$div
    DCA_df_divs$YoC_Ticker <- ((DCA_df_divs$div_cash_flow)/(DCA_df_divs$invested)+1)*100-100
   
   
    return(
      DCA_df_divs
    )
  })
 
 
 
 
  dfz_interactive <-reactive({
   
   
    historical_yield <- list()
    historical_CF <- list()
   
   
    #for ( j in input$years_portf[1]:input$years_portf[2] ) {
    for ( j in input$years_portf[1]:input$year_yoc ) {
     
     
      DCA_df_divs <- left_join(DCA_df_interactive(), divs_agg %>% group_by(ticker) %>% filter( Year_div == j)  , by=c('ticker'='ticker'))
     
      DCA_df_divs$div_cash_flow <- DCA_df_divs$Stocks*DCA_df_divs$div
     
     
      historical_yield <- append(
        historical_yield,
        (sum(DCA_df_divs$div_cash_flow)/sum(hist_price_infl_filtered_interactive()[hist_price_infl_filtered_interactive()$Year <= j ,]$money_input_infl)+1)*100-100
      )
     
     
      historical_CF <- append(
        historical_CF,
        sum(DCA_df_divs$div_cash_flow)
      )
     
     
    }
   
    historical_yield =unlist(historical_yield)
   
    historical_CF =unlist(historical_CF)
   
    # yearz =  input$years_portf[1]:input$years_portf[2]
    yearz =  input$years_portf[1]:input$year_yoc
   
    dfz = data.frame(historical_yield,historical_CF,yearz)
    return(dfz)
   
  })
 
 
  DCA_Portfolio_DF <-reactive({
   
   
    aux <-   filter(df_historical[df_historical$ticker %in% input$selected_tickers_portf ,],
                    year(ref_date) >= input$years_portf[1] &
                      year(ref_date) <= input$years_portf[2]
    )
   
   
    if(input$yearly_dca == TRUE){
      DCA_Portfolio_DF <-  left_join(
        aux %>%
          dplyr::rename(Historical_Price = price_close),
        aux[,c("ticker","price_close","ref_date_year")] %>%
          group_by(ticker, ref_date_year) %>%
          summarise_at(.vars = c("price_close"), .funs = mean) %>%
          dplyr::rename(DCA = price_close),
        by=c('ticker'='ticker', 'ref_date_year'='ref_date_year')
      )
    }else{
      DCA_Portfolio_DF <-  left_join(
        aux %>%
          dplyr::rename(Historical_Price = price_close),
        aux[,c("ticker","price_close","ref_date_year")] %>%
          group_by(ticker) %>%
          summarise_at(.vars = c("price_close"), .funs = mean) %>%
          dplyr::rename(DCA = price_close),
        by=c('ticker'='ticker')
      )
    }
   
   
    DCA_Portfolio_DF$ticker_dca <- paste('DCA',DCA_Portfolio_DF$ticker)
   
    return(DCA_Portfolio_DF)
   
  })
 
 
  ### TABLES ###
 
  output$DCA_DF = renderDT(DCA_df_divs_interactive()
  )
 
 
 
 
 
 
  ### GRAPHS ###
 
 
  output$YoC <-renderPlotly({
   
    # plot_ly( DCA_df_divs_interactive(), type = 'bar') %>%
    #   add_trace(x = ~ticker, y = ~YoC_Ticker, name = 'Portfolio YoC') %>%  
    #   layout(title = paste("<b>YoC TODAY* per ticker<b> with last buy on ",input$years_portf[2]),
    #          xaxis = list(title = 'Tickers'),
    #          yaxis = list(title = 'YoC (%)'), legend = list(title=list(text='<b> Tickers </b>')))
   
    # layout(title = paste("YoC TODAY* per ticker with last buy on ",input$years_portf[2]))  %>%
   
   
   
   colors <- viridis(n = length(unique(DCA_df_divs_interactive()$ticker)))
  
  plot_ly(DCA_df_divs_interactive(), type = 'bar') %>%
    add_trace(x = ~ticker, y = ~YoC_Ticker, name = 'Portfolio YoC', color = ~ticker, colors = colors) %>%  
    layout(
      title = paste("<b>YoC TODAY* per ticker<b> with last buy on ",input$years_portf[2]), 
      xaxis = list(title = 'Tickers', gridcolor = 'rgba(255, 255, 255, 0.8)'),  # Change grid color here
      yaxis = list(title = 'YoC (%)', gridcolor = 'rgba(255, 255, 255, 0.8)'),  # And here
      legend = list(
        title = list(text = '<b> Tickers </b>'),
        bgcolor = light_dark, #'rgba(255, 255, 255, 0.8)',  # Change the background color of the legend here
        font = list(color = 'black')  # Change the font color of the legend here
      ),
      plot_bgcolor = hex_bg_lot #'#717D7E' #light_dark  # Change this to your preferred color
    )
    
    
  })
 
 
  output$Stocks_bought <- renderPlotly({
   
   
    # plot_ly(hist_price_infl_filtered_interactive(), type = 'bar')%>%
    #   add_trace(x = ~ym, y = ~Stocks, name = ~ticker)  %>%  
    #   layout(title = "<b>Stocks Bought Over Time<b>",
    #          xaxis = list(title = 'Date'),
    #          yaxis = list(title = 'Stocks Bought'), legend = list(title=list(text='<b> Tickers </b>')))
   
    #library(viridis)
    
    # Create a color palette
    colors <- viridis(n = length(unique(hist_price_infl_filtered_interactive()$ticker)))
    
    plot_ly(hist_price_infl_filtered_interactive(), type = 'bar') %>%
      add_trace(x = ~ym, y = ~Stocks, name = ~ticker, color = ~ticker, colors = colors)  %>%  
      layout(
        title = "<b>Stocks Bought Over Time<b>", 
        xaxis = list(title = 'Date', gridcolor = 'rgba(255, 255, 255, 0.8)'),  # Change grid color here
        yaxis = list(title = 'Stocks Bought', gridcolor = 'rgba(255, 255, 255, 0.8)'),  # And here
        legend = list(
          title = list(text = '<b> Tickers </b>'),
          bgcolor = light_dark, #'rgba(255, 255, 255, 0.8)',  # Change the background color of the legend here
          font = list(color = 'black')  # Change the font color of the legend here
        ),
        plot_bgcolor = hex_bg_lot #'#717D7E' #light_dark  # Change this to your preferred color
      )
    
    
    
  })
 
  output$Div_CF <-renderPlotly({
   
    # plot_ly(DCA_df_divs_interactive(), labels = ~ticker, values = ~div_cash_flow, type = 'pie')%>%
    #   layout(title = '<b>Dividend Cash Flow split TODAY*</b>',
    #          xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
    #          yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE)
    #   )
    
    
    #library(viridis)
    
    # Create a color palette
    colors <- viridis(n = length(unique(DCA_df_divs_interactive()$ticker)))
    
    plot_ly(DCA_df_divs_interactive(), labels = ~ticker, values = ~div_cash_flow, type = 'pie', marker = list(colors = colors)) %>%
      layout(
        title = '<b>Dividend Cash Flow split TODAY*</b>',
        xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
        yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
        legend = list(
          bgcolor = light_dark, #'rgba(255, 255, 255, 0.8)',  # Change the background color of the legend here
          font = list(color = 'black')  # Change the font color of the legend here
        ),
        plot_bgcolor = hex_bg_lot #'#717D7E' #light_dark  # Change this to your preferred color
      )
    
    
    
  })
 
 
 
  output$YoC_hist <- renderPlotly({
   
    ay <- list(
      tickfont = list(color = "red"),
      overlaying = "y",
      side = "right",
      title = "<b>$</b> invested")

    plot_ly() %>%
      add_trace(data= dfz_interactive(), x = ~yearz, y = ~historical_yield, name = "<b>Portfolio Historical Yield</b>", type = "bar") %>%
      add_trace(data= aggregate(money_input_infl ~ Year, data = hist_price_infl_filtered_interactive(), FUN = sum), name="Monetary Input", x = ~Year, y = ~money_input_infl, yaxis = "y2", mode = "lines+markers", type = "scatter")  %>%
      layout(
        title = "<b>Historical YoC of the Portfolio vs Monetary input<b>", yaxis2 = ay,
        xaxis = list(title="Year"),
        yaxis = list(title="YoC (%)")
      )%>%
      layout(plot_bgcolor= hex_bg_lot,
             xaxis = list(
               zerolinecolor = '#ffff',
               zerolinewidth = 2,
               gridcolor = 'ffff'),
             yaxis = list(
               zerolinecolor = '#ffff',
               zerolinewidth = 2,
               gridcolor = 'ffff')
      )
    
    
    #library(viridis)
    
    # Create a color palette
    # colors <- viridis(n = length(unique(dfz_interactive()$yearz)))
    # 
    # ay <- list(
    #   tickfont = list(color = "red"),
    #   overlaying = "y",
    #   side = "right",
    #   title = "<b>$</b> invested"
    # )
    # 
    # plot_ly() %>%
    #   add_trace(data= dfz_interactive(), x = ~yearz, y = ~historical_yield, name = "<b>Portfolio Historical Yield</b>", type = "bar", marker = list(color = colors)) %>%
    #   add_trace(data= aggregate(money_input_infl ~ Year, data = hist_price_infl_filtered_interactive(), FUN = sum), name="Monetary Input", x = ~Year, y = ~money_input_infl, yaxis = "y2", mode = "lines+markers", type = "scatter", line = list(color = 'black'))  %>%
    #   layout(
    #     title = "<b>Historical YoC of the Portfolio vs Monetary input<b>", 
    #     yaxis2 = ay,
    #     xaxis = list(title="Year", gridcolor = 'rgba(255, 255, 255, 0.8)'),  # Change grid color here
    #     yaxis = list(title="YoC (%)", gridcolor = 'rgba(255, 255, 255, 0.8)'),  # And here
    #     legend = list(
    #       bgcolor = light_dark, #'rgba(255, 255, 255, 0.8)',  # Change the background color of the legend here
    #       font = list(color = 'black')  # Change the font color of the legend here
    #     ),
    #     plot_bgcolor = '#717D7E' #light_dark  # Change this to your preferred color
    #   )
    
   
  })
 
 
 
  output$CF_hist <- renderPlotly({
   

    plot_ly() %>%
      add_trace(data= dfz_interactive(), x = ~yearz, y = ~historical_CF, name = "Portfolio CF", type = "bar") %>%
      add_trace(data= dfz_interactive() %>% mutate(cum_div = cumsum(historical_CF))
                , name="Cumulative Dividend", x = ~yearz, y = ~cum_div, mode = "lines+markers", type = "scatter") %>%
      add_trace(data= aggregate(money_input_infl ~ Year, data = hist_price_infl_filtered_interactive(), FUN = sum), name="Monetary Input", x = ~Year, y = ~money_input_infl, mode = "lines+markers", type = "scatter") %>%
      add_trace(data= aggregate(money_input_infl ~ Year, data = hist_price_infl_filtered_interactive(), FUN = sum)  %>% mutate(cum_money_input = cumsum(money_input_infl)), name="Cumulative Monetary Input", x = ~Year, y = ~cum_money_input, mode = "lines+markers", type = "scatter") %>%
      layout(
        title = "<b>Historical CF vs Monetary Input<b>",
        xaxis = list(title="Year"),
        yaxis = list(title="Historical Cash Flow ($)"),
    plot_bgcolor =  hex_bg_lot #'#717D7E' #light_dark
       )
    
    #library(viridis)
    
    # Create a color palette
    # colors <- viridis(n = length(unique(dfz_interactive()$yearz)))
    # 
    # plot_ly() %>%
    #   add_trace(data= dfz_interactive(), x = ~yearz, y = ~historical_CF, name = "Portfolio CF", type = "bar", marker = list(color = colors)) %>%
    #   add_trace(data= dfz_interactive() %>% mutate(cum_div = cumsum(historical_CF)), name="Cumulative Dividend", x = ~yearz, y = ~cum_div, mode = "lines+markers", type = "scatter", line = list(color = 'black')) %>%
    #   add_trace(data= aggregate(money_input_infl ~ Year, data = hist_price_infl_filtered_interactive(), FUN = sum), name="Monetary Input", x = ~Year, y = ~money_input_infl, mode = "lines+markers", type = "scatter", line = list(color = 'red')) %>%
    #   add_trace(data= aggregate(money_input_infl ~ Year, data = hist_price_infl_filtered_interactive(), FUN = sum)  %>% mutate(cum_money_input = cumsum(money_input_infl)), name="Cumulative Monetary Input", x = ~Year, y = ~cum_money_input, mode = "lines+markers", type = "scatter", line = list(color = 'blue')) %>%
    #   layout(
    #     title = "<b>Historical CF vs Monetary Input<b>", 
    #     xaxis = list(title="Year", gridcolor = 'rgba(255, 255, 255, 0.8)'),  # Change grid color here
    #     yaxis = list(title="Historical Cash Flow ($)", gridcolor = 'rgba(255, 255, 255, 0.8)'),  # And here
    #     legend = list(
    #       bgcolor = light_dark, #'rgba(255, 255, 255, 0.8)',  # Change the background color of the legend here
    #       font = list(color = 'black')  # Change the font color of the legend here
    #     ),
    #     plot_bgcolor = '#717D7E' #light_dark  # Change this to your preferred color
    #   )
    # 
   
   
   
  })
 
 
  output$DCA_Portfolio <- renderPlotly({
   
   
    if(input$yearly_dca == TRUE){
     
      # plot_ly( DCA_Portfolio_DF()  ) %>%
      #   add_trace(x = ~ref_date, y = ~Historical_Price, type = 'scatter', mode = "lines", name = ~ticker)%>%
      #   add_trace(x = ~ref_date, y = ~DCA, type = 'scatter', mode = "lines", name = ~ticker_dca)%>%
      #   layout(title = '<b> DCA (Yearly) <b>', xaxis = list(title = 'Date'),
      #          yaxis = list(title = 'Price ($)'), legend = list(title=list(text='<b> Ticker </b>')))
      
      #library(viridis)
      
      # Create a color palette
      colors <- viridis(n = length(unique(DCA_Portfolio_DF()$ticker)))
      
      plot_ly(DCA_Portfolio_DF()) %>%
        add_trace(x = ~ref_date, y = ~Historical_Price, type = 'scatter', mode = "lines", name = ~ticker, line = list(color = colors[1])) %>%
        add_trace(x = ~ref_date, y = ~DCA, type = 'scatter', mode = "lines", name = ~ticker_dca, line = list(color = colors[2])) %>%
        layout(
          title = '<b> DCA (Yearly) <b>', 
          xaxis = list(title = 'Date', gridcolor = 'rgba(255, 255, 255, 0.8)'),  # Change grid color here
          yaxis = list(title = 'Price ($)', gridcolor = 'rgba(255, 255, 255, 0.8)'),  # And here
          legend = list(
            title = list(text = '<b> Ticker </b>'),
            bgcolor = light_dark, #'rgba(255, 255, 255, 0.8)',  # Change the background color of the legend here
            font = list(color = 'black')  # Change the font color of the legend here
          ),
          plot_bgcolor = hex_bg_lot  # '#717D7E' #light_dark  # Change this to your preferred color
        )
      
      
      
    }else{
     
      plot_ly( DCA_Portfolio_DF()  ) %>%
        add_trace(x = ~ref_date, y = ~Historical_Price, type = 'scatter', mode = "lines", name = ~ticker)%>%
        add_trace(x = ~ref_date, y = ~DCA, type = 'scatter', mode = "lines", name = ~ticker_dca)%>%
        layout(title = '<b> DCA (Full Period)<b>', xaxis = list(title = 'Date'),
               yaxis = list(title = 'Price ($)'), legend = list(title=list(text='<b> Ticker </b>')),
               plot_bgcolor = hex_bg_lot  # Change this to your preferred color
                )
      
      #library(viridis)
      
      # Create a color palette
      # colors <- viridis(n = length(unique(DCA_Portfolio_DF()$ticker)))
      # 
      # plot_ly(DCA_Portfolio_DF()) %>%
      #   add_trace(x = ~ref_date, y = ~Historical_Price, type = 'scatter', mode = "lines", name = ~ticker, line = list(color = colors[1])) %>%
      #   add_trace(x = ~ref_date, y = ~DCA, type = 'scatter', mode = "lines", name = ~ticker_dca, line = list(color = colors[2])) %>%
      #   layout(
      #     title = '<b> DCA (Full Period)<b>', 
      #     xaxis = list(title = 'Date', gridcolor = 'rgba(255, 255, 255, 0.8)'),  # Change grid color here
      #     yaxis = list(title = 'Price ($)', gridcolor = 'rgba(255, 255, 255, 0.8)'),  # And here
      #     legend = list(
      #       title = list(text = '<b> Ticker </b>'),
      #       bgcolor = light_dark, #'rgba(255, 255, 255, 0.8)',  # Change the background color of the legend here
      #       font = list(color = 'black')  # Change the font color of the legend here
      #     ),
      #     plot_bgcolor = '#717D7E' #light_dark  # Change this to your preferred color
      #   )
      # 
      
      
    }
   
  })
 
  ##### tabpanel -> Indexes #####
  ### Dataframes ###            
 
  df_indexinteractive <- reactive ({
    return(          
      filter(df_index[df_index$index %in% input$selected_indexes ,],
             year(ref_date) >= input$years_indexes[1] &
               year(ref_date) <= input$years_indexes[2])
    )
  })
 
 
 
  ### GRAPHS ###
 
  output$Index_Evolution <-renderPlotly({
   
   
    # plot_ly(df_indexinteractive(), type = 'scatter', mode = 'lines') %>%
    #   add_trace(x = ~ref_date, y = ~price_index, name = ~index) %>%
    #   layout(title = '<b>Index Price Evolution <b>',
    #          xaxis = list(title = 'Date'),
    #          yaxis = list(title = 'Price ($)'),
    #          legend = list(title=list(text='<b> Index </b>')))
    
    #library(viridis)
    
    # Create a color palette
    colors <- viridis(n = length(unique(df_indexinteractive()$index)))
    
    plot_ly(df_indexinteractive(), type = 'scatter', mode = 'lines') %>%
      add_trace(x = ~ref_date, y = ~price_index, name = ~index, color = ~index, colors = colors) %>%
      layout(
        title = '<b>Index Price Evolution <b>', 
        xaxis = list(title = 'Date', gridcolor = 'rgba(255, 255, 255, 0.8)'),  # Change grid color here
        yaxis = list(title = 'Price ($)', gridcolor = 'rgba(255, 255, 255, 0.8)'),  # And here
        legend = list(
          title = list(text = '<b> Index </b>'),
          bgcolor = light_dark, #'rgba(255, 255, 255, 0.8)',  # Change the background color of the legend here
          font = list(color = 'black')  # Change the font color of the legend here
        ),
        plot_bgcolor = hex_bg_lot #'#717D7E' #light_dark  # Change this to your preferred color
      )
    
   
   
  })          
} #server


shinyApp(ui, server)