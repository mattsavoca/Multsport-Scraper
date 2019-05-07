## Scrapy-Scout
**Scrapy-Scout** is a series of python scripts that scrape the last 40 years (1979-2018) of player selections in the four major US sports leagues.

The scripts utilize the scrapy package, and scrape *ProFootballReference.com, Basketball-reference.com, Hockey-reference.com*, and *Baseball-reference.com*. They export csvs with relavent player, team, and career statistical metrics.

The included R scripts load, process, and allow the user to perform a cross-sport analysis, by normalizing state of the art player evaluation metrics in each of the four sports:
      
      *For MLB players: `WAR`
      
      *For NHL players: `Point-Share`
      
      *For NFL players: `Approximate Value`
      
      *For NBA players: `Value over Replacement Player`
      

![image](https://github.com/mattsavoca/scout-scraper/blob/master/charts/pos_value_facetspos.png)
