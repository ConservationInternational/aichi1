f <- read.csv('species.csv', header=F)

library(rvest)
library(dplyr)
library(RCurl)
library(pageviews)

n <- 0
for (i in f$V1){
  tryCatch({
  t <- gsub(' ', '_', i)
  
  url <- paste0("http://en.wikipedia.org/wiki/", t)
  
  if (url.exists(url)){
    out <- read_html(url) %>%
      html_text %>%
      nchar
    
    views <- article_pageviews(project='en.wikipedia', article = t)
    
    write.csv(data.frame(species=i, size=out, views=views$views), paste0('AllSpecies/', t, '.csv'), row.names=F)
  }

  n <- n + 1
  
  cat(paste0(round(n/nrow(f)*100, 4), '%'), i, '\n')

  }, error=function(e){})
}
