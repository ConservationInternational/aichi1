library(dplyr)
library(tidyr)

trends <- read.csv('C://Git/aichi1/DAILYTRENDS.csv', stringsAsFactors = F)

predictFirst <- function(df, kw){
  df <- df %>% 
    filter(keyword == kw)
  
  first <- df %>%
    filter(range=="First") %>%
    select(First=score, date)
  
  second <- df %>%
    filter(range=="Second") %>%
    select(Second=score, date)
  
  comb <- merge(first, second)
  
  mod <- lm(Second ~ First, data=comb)
  
  first$Second <- first$First*coef(mod)['First'] + coef(mod)['(Intercept)']

  first <- first %>%
    filter(!(date %in% second$date)) %>%
    select(date, Second)
  
  final <- bind_rows(first, second) %>%
    select(date, score=Second) %>%
    mutate(keyword = kw)
    
  final
}

newdf <- data.frame()
for (kw in unique(trends$keyword)){
  res <- predictFirst(trends, kw)
  
  newdf <- bind_rows(res, newdf)

}

write.csv(newdf, 'C://Git/aichi1/DAILYTRENDS-Stitch.csv', row.names=F)