f_divs_agg <- function(test_ticker,from_date,to_date) {
 
  
  divs <- getDividends(test_ticker[1], 
                       from = from_date,
                       to = to_date, 
                       src = "yahoo", 
                       auto.assign = TRUE, 
                       auto.update = TRUE, 
                       verbose = FALSE)
  
  
  divs <- data.frame(date=index(divs), coredata(divs))
  colnames(divs) <- c('date','div')
  
  
  divs$ticker <- rep(test_ticker[1],nrow(divs))
  
  
  for(i in 2:length(test_ticker)) {
    
    aux <- getDividends(test_ticker[i], 
                        from = from_date,
                        to = to_date, 
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
  
  
  ### GROUP BY <YEAR> & ticker
  
  # #For quarterly growth
  # divs_agg <- setNames( aggregate(div ~ (date) + ticker, data = divs, FUN = sum, na.rm = TRUE),
  #                       c("Year_div","ticker","div"))
  
  
  #For yearly growth
  divs_agg <- setNames( aggregate(div ~ year(date) + ticker, data = divs, FUN = sum, na.rm = TRUE),
                        c("Year_div","ticker","div"))
  
 
  
  return(divs_agg)

}




f_growth_df <- function(divs_agg,n) {
  
  
   growth_df <- data.frame( #empty dataframe
    year_growth = integer(),
    Ticker = character(),
    Growth_hist = double())
  
  
  
  growth_hist=c()
  #n=1 #years/quarters of growth comparison
  
  c=0
  
  unique(divs_agg$ticker)
  
  for ( j in 1:length(unique(divs_agg$ticker)) ) {
    
    divs_agg_ticker <- filter(divs_agg,ticker %in% unique(divs_agg$ticker)[j])
    
    
    growth_hist=c()
    for(i in 2:nrow(divs_agg_ticker)) {
      
      
      growth_hist[i-n] = ( (divs_agg_ticker$div[i]/divs_agg_ticker$div[i-n])^(1/n) -1)*100
      
    }
    
    
    
    growth_df <-  rbind(growth_df,
                        data.frame(year_growth=divs_agg_ticker$Year_div[- (1:n)], growth_hist) %>% mutate(Ticker = unique(divs_agg$ticker)[j]) 
    )
    
  }
  
  
  
  
  return(growth_df)
  
}










f_growth_portfolio_fcst <- function(divs_agg,percentile) {




df_growth_portfolio_fcst <- Reduce(function (...) { merge(..., all = FALSE) },   # Inner join
                                   list(divs_agg %>% group_by( ticker ) %>% 
                                          mutate( growth = ( div/lag(div) -1)*100 ) %>% group_by( ticker ) %>% filter(row_number()>1)  %>% 
                                          group_by(ticker) %>%  
                                          dplyr::summarise(enframe(quantile(growth, percentile), "quantile", "Growth")),
                                        my_portfolio,
                                        divs_agg %>% 
                                          group_by(ticker) %>% slice(n())  
                                   )
)


df_growth_portfolio_fcst$Current_div <- df_growth_portfolio_fcst$Amount * df_growth_portfolio_fcst$div
df_growth_portfolio_fcst$Expected_div <- df_growth_portfolio_fcst$Current_div  * (1 + df_growth_portfolio_fcst$Growth/100)


return(df_growth_portfolio_fcst)

}
