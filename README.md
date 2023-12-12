# R_Stocks

Using public financial data together with in R to create an interactive Shiny App to check how noisy the stock market can be and definitely [not a tool to guide your personal finances](https://github.com/JAlcocerT/R_Stocks#important---no-investment-advice).

* Further Description at: <https://fossengineer.com/project-shiny-R-Stocks/>

## Repisotory Structure

* The analysys Rmd file I used - [R_Stocks_Analysis.Rmd](https://github.com/JAlcocerT/R_Stocks/blob/main/R_Stocks_Analysis.Rmd)
* The final interactive dashboard - [R_Stocks_Shiny.Rmd](https://github.com/JAlcocerT/R_Stocks/blob/main/R_Stocks_Shiny.Rmd)
    * Stocks Analysis: yfR
    * Dividend Analysis: yfR, QuantMod, PriceR, *QuandDl (optional)*
    * Portfolio Analysis: yfR, QuantMod, PriceR
* **The R-Stocks App:**
    * [Docker and the R-Stocks Shiny App](https://fossengineer.com/building-r-shiny-apps-container-image-with-docker/)
    * Versioning of the Docker Images: <https://hub.docker.com/repository/docker/fossengineer/r_stocks>

## 🎯 Features and RoadMap

* The R Shiny App:

<details>
  <summary>V1  :heavy_check_mark:</summary>
  &nbsp;

* Visualize historical trends on the specified stocks/index
* Visualize the dividend trends on different stocks, considering the different splits over the time 
* Portfolio Analysis - Check how the valuation and dividend of a given number of stocks initially
* Improve UI 

* V1.1: Selecting the stocks as environment variable in docker-compose.yml

</details>

<details>
  <summary>:construction_worker:</summary>
  &nbsp;

* Add Re-Investment capability
* To try the Shinylive package

</details>

* The R FlexhDashboard: <https://jalcocert.github.io/R_Stocks/>

<details>
  <summary>V1  :heavy_check_mark:</summary>
  &nbsp;

* Given SP500 historical data, to classify months as per 'boom/burst'

</details>


### Powered Thanks To ❤️

This project uses several open source libraries. 

I am listing here the ones that served as major pilars for making the project come alive.
#### Data Sources

<details>
  <summary>Click to expand/close the API's used</summary>
  &nbsp;

* <https://github.com/ropensci/yfR>
    * [Discovering the yfR package](https://fossengineer.com/r-yfR-package-guide/)
* <https://github.com/stevecondylios/priceR>
    * [Querying currency pairs with PriceR](https://fossengineer.com/r-priceR-package-guide/)
* <https://github.com/joshuaulrich/quantmod>
    * [My guide for QuantMod Package](https://fossengineer.com/r-Quantmod-package-guide/)
* <https://github.com/quandl/quandl-r>
    * [Using the quandl R Package](https://fossengineer.com/r-quandl-package-guide/)

</details>

* Other Data sources:
    * For the Flexdashboard: <https://github.com/datasets/s-and-p-500>
    * <https://finance.yahoo.com/quote/GC=F/> 
    * <https://www.macrotrends.net/1333/historical-gold-prices-100-year-chart>


#### Visualizations

I need to mention the importance of additional **open source tools** that made the visualizations look better.

<details>
  <summary>Click to expand/close the visualizations tools</summary>
  &nbsp;

* <https://github.com/plotly/plotly.R>
* <https://github.com/rstudio/shiny>
* <https://bootswatch.com/>
* <https://github.com/rstudio/bslib>
* <https://r-graph-gallery.com/38-rcolorbrewers-palettes.html>

</details>


### :loudspeaker: Ways to Contribute

* Please feel free to fork the code - try it out for yourself and improve or add others tabs. The data that is queried give many possibilities to create awsome visualizations.

* Support extra evening code sessions:

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/FossEngineer)

## IMPORTANT! - NO INVESTMENT ADVICE

The repository and its content is for **informational purposes only** on how to create a Shiny dashboard / Flexdashboard in R with publicly available data, you should not construe any such information or other material as legal, tax, investment, financial, or other advice. Nothing contained on this repository is a recommendation to buy or sell any securities or any other financial instruments.

This program is distributed in the hope that it will motivate you to learn R Shiny and contribute to Open Source, but WITHOUT ANY WARRANTY.

## :scroll: License

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License (GPL) version 3.0:

    Freedom to use: You can use the software for any purpose, without any restrictions.
    Freedom to study and modify: You can examine the source code, learn from it, and modify it to suit your needs.
    Freedom to share: You can share the original software or your modified versions with others, so they can benefit from it too.
    Copyleft: When you distribute the software or any derivative works, you must do so under the same GPL-3.0 license. This ensures that the software and its derivatives remain free and open-source.