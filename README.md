<div align="center">
  <h1>R_Stocks</h1>
</div>



<div align="center">
  <a href="https://github.com/JAlcocerT/R_Stocks?tab=GPL-3.0-1-ov-file" style="margin-right: 5px;">
    <img alt="Code License" src="https://img.shields.io/badge/License-GPLv3-blue.svg" />
  </a>
  <a href="https://github.com/JAlcocerT/R_Stocks/actions/workflows/build_shiny.yml" style="margin-right: 5px;">
    <img alt="GH Actions Workflow" src="https://github.com/JAlcocerT/R_Stocks/actions/workflows/build_shiny.yml/badge.svg" />
  </a>
  <a href="https://GitHub.com/JAlcocerT/R_Stocks/graphs/commit-activity" style="margin-right: 5px;">
    <img alt="Mantained" src="https://img.shields.io/badge/Maintained%3F-no-grey.svg" />
  </a>
  <a href="https://cran.r-project.org/web/packages/shiny/index.html">
    <img alt="Python Version" src="https://img.shields.io/badge/r-4.1.2-blue.svg" />
  </a>
</div>

Using public financial data together with in R to create an interactive Shiny App to check how noisy the stock market can be and definitely [not a tool to guide your personal finances](https://github.com/JAlcocerT/R_Stocks#important---no-investment-advice).

* Further Description at: <https://jalcocert.github.io/JAlcocerT/R-Stocks/>

## Repository Structure

* The analysys Rmd file I used - [R_Stocks_Analysis.Rmd](https://github.com/JAlcocerT/R_Stocks/blob/main/R_Stocks_Analysis.Rmd)
* The final interactive dashboard - [R_Stocks_Shiny.Rmd](https://github.com/JAlcocerT/R_Stocks/blob/main/R_Stocks_Shiny.Rmd)
    * Stocks Analysis: yfR
    * Dividend Analysis: yfR, QuantMod, PriceR, *QuandDl (optional)*
    * Portfolio Analysis: yfR, QuantMod, PriceR
* **The R-Stocks App:**
    * [Docker and the R-Stocks Shiny App](https://jalcocert.github.io/JAlcocerT/building-r-shiny-apps-container-image-with-docker/)
    * Versioning of the [Docker Container Images at GHCR](https://github.com/users/JAlcocerT/packages/container/package/r-stocks)

## 🎯 Features and RoadMap

* The R Shiny App:

<details>
  <summary>V1  :heavy_check_mark:</summary>
  &nbsp;

* Visualize historical trends on the specified stocks/index
* Visualize the dividend trends on different stocks, considering the different splits over the time 
* Portfolio Analysis - Check how the valuation and dividend of a given number of stocks initially
* Improve UI 

* V1.1: Selecting the stocks as environment variable in `docker-compose.yml`

</details>

* The R FlexhDashboard: <https://jalcocert.github.io/R_Stocks/>
  * Given SP500 historical data, to **classify months as per 'boom/burst'**


### Powered Thanks To ❤️

This project uses several open source libraries. 

I am listing here the ones that served as major pilars for making the project come alive.
#### Data Sources

<details>
  <summary>Click to expand/close the API's used</summary>
  &nbsp;

* <https://github.com/ropensci/yfR>
* <https://github.com/stevecondylios/priceR>
* <https://github.com/joshuaulrich/quantmod>
* <https://github.com/quandl/quandl-r>

</details>

* Other Data sources:
    * For the Flexdashboard: <https://github.com/datasets/s-and-p-500>
    * <https://finance.yahoo.com/quote/GC=F/> 
    * <https://www.macrotrends.net/1333/historical-gold-prices-100-year-chart>
    * FED <https://fred.stlouisfed.org/series/FEDFUNDS>


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


### Ways to Contribute 📢

* Please feel free to fork the code - try it out for yourself and improve or add others tabs. The data that is queried give many possibilities to create awsome visualizations.

* Support extra evening code sessions:

<div align="center">
  <a href="https://ko-fi.com/Z8Z1QPGUM">
    <img src="https://ko-fi.com/img/githubbutton_sm.svg" alt="ko-fi">
  </a>
</div>

## IMPORTANT! - NO INVESTMENT ADVICE

The repository and its content is for **informational purposes only** on how to create a Shiny dashboard / Flexdashboard in R with publicly available data, you should not construe any such information or other material as legal, tax, investment, financial, or other advice.

**Nothing contained on this repository is a recommendation to buy or sell any securities or any other financial instruments.**

This program is distributed in the hope that it will motivate you to learn R Shiny and contribute to Open Source, but WITHOUT ANY WARRANTY.

## :scroll: License

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License (GPL) version 3.0:

    Freedom to use: You can use the software for any purpose, without any restrictions.
    Freedom to study and modify: You can examine the source code, learn from it, and modify it to suit your needs.
    Freedom to share: You can share the original software or your modified versions with others, so they can benefit from it too.
    Copyleft: When you distribute the software or any derivative works, you must do so under the same GPL-3.0 license. This ensures that the software and its derivatives remain free and open-source.