# R_Stocks

Using public financial data together with Shiny in R to create an interactive Shiny App to check how noisy the stock market can be and definitely [not a tool to guide your personal finances](https://github.com/JAlcocerT/R_Stocks#important---no-investment-advice).

Deployed at <https://r_stocks.fossengineer.com>
Further Description at: <https://fossengineer.com/project-shiny-R-Stocks/>

* The analysys Rmd file I used - [R_Stocks_Analysis.Rmd](https://github.com/JAlcocerT/R_Stocks/blob/main/R_Stocks_Analysis.Rmd)
* The final interactive dashboard - [R_Stocks_Shiny.Rmd](https://github.com/JAlcocerT/R_Stocks/blob/main/R_Stocks_Shiny.Rmd)
    * Stocks Analysis: yfR
    * Dividend Analysis: yfR, QuantMod, PriceR, *QuandDl (optional)*
    * Portfolio Analysis: yfR, QuantMod, PriceR
* The R-Stocks App: <https://r_stocks.fossengineer.com/>
    * [Docker and the R-Stocks Shiny App](https://fossengineer.com/building-r-shiny-apps-container-image-with-docker/)
    * Versioning of the Docker Images: <https://hub.docker.com/repository/docker/fossengineer/r_stocks>

## Goals and RoadMap

* Visualize historical trends on the specified stocks/index :heavy_check_mark:
* Visualize the dividend trends on different stocks, considering the different splits over the time :heavy_check_mark:
* Portfolio Analysis - Check how the valuation and dividend of a given number of stocks initially :heavy_check_mark:
* Improve UI :heavy_check_mark:

* Add Re-Investment capability - :construction_worker:

### Powered Thanks To:

This project uses several open source libraries. I am listing here the ones that served as major pilars for making the code come alive:
#### Data Sources

* <https://github.com/ropensci/yfR>
    * [Discovering the yfR package](https://fossengineer.com/r-yfR-package-guide/)
* <https://github.com/stevecondylios/priceR>
    * [Querying currency pairs with PriceR](https://fossengineer.com/r-priceR-package-guide/)
* <https://github.com/joshuaulrich/quantmod>
    * [My guide for QuantMod Package](https://fossengineer.com/r-Quantmod-package-guide/)
* <https://github.com/quandl/quandl-r>
    * [Using the quandl R Package](https://fossengineer.com/r-quandl-package-guide/)

* <https://finance.yahoo.com/quote/GC=F/> 
* <https://www.macrotrends.net/1333/historical-gold-prices-100-year-chart>

#### Visualizations

* <https://github.com/plotly/plotly.R>
* <https://github.com/rstudio/shiny>
* <https://bootswatch.com/>
* <https://github.com/rstudio/bslib>
* <https://r-graph-gallery.com/38-rcolorbrewers-palettes.html>

### Ways to Contribute

* Please feel free to fork the code - try it out for yourself and improve or add others tabs. The data that is queried give many possibilities to create awsome visualizations.

* Support extra evening code sessions:

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/FossEngineer)

## IMPORTANT! - NO INVESTMENT ADVICE

The Shiny App and its Content is for **informational purposes only** on how to create a Shiny dashboard with publicly available data, you should not construe any such information or other material as legal, tax, investment, financial, or other advice. Nothing contained on this repository is a recommendation to buy or sell any securities or any other financial instruments.

## :scroll: License

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License (GPL) version 3.0:

    Freedom to use: You can use the software for any purpose, without any restrictions.
    Freedom to study and modify: You can examine the source code, learn from it, and modify it to suit your needs.
    Freedom to share: You can share the original software or your modified versions with others, so they can benefit from it too.
    Copyleft: When you distribute the software or any derivative works, you must do so under the same GPL-3.0 license. This ensures that the software and its derivatives remain free and open-source.

<<<<<<< HEAD
    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY.
=======
    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY.
>>>>>>> ff93b1dbebe5e4d483f1be571a04d5b8ff8d7ddf
