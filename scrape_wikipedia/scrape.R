f <- read.csv('species.csv', header=F, stringsAsFactors=F)

library(rvest)
library(dplyr)
library(RCurl)
library(pageviews)

for (i in which(f$V1=='Stenoglottis inandensis'):length(f$V1)){
  tryCatch({
  t <- gsub(' ', '_', f$V1[i])
  
  url <- paste0("http://en.wikipedia.org/wiki/", t)
  
  if (url.exists(url)){
    out <- read_html(url) %>%
      html_text %>%
      nchar
    
    views <- article_pageviews(project='en.wikipedia', article = t)
    
    write.csv(data.frame(species=f$V1[i], size=out, views=views$views), paste0('AllSpecies/', t, '.csv'), row.names=F)
  }

  cat(paste0(round(i/nrow(f)*100, 4), '%'), Sys.time(), f$V1[i], '\n')

  }, error=function(e){cat(f$V1[i], '\n', file='errors.txt', append=T)})
}
