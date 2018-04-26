# !diagnostics off

library(dplyr)
library(ggplot2)

#twitter
twit <- read.csv('https://ci-tweet-csv-dumps.s3.amazonaws.com/TWITTER-BASELINE.csv',
                 na.strings = '') %>%
  filter(!month %in% c('2017-10', '2018-04'))
twit$any[is.na(twit$any)] <- 0
twit$just_species[is.na(twit$just_species)] <- 0

twit$any <- twit$any - twit$just_species

twit <- twit %>% group_by(country) %>%
  summarize(twitter_count = sum(any),
            twitter_total = sum(baseline)) %>%
  mutate(twitter_rate = twitter_count/twitter_total)

#newspapers
news <- read.csv('https://ci-tweet-csv-dumps.s3.amazonaws.com/WEBHOSE-BASELINE.csv',
                 na.strings = '') %>%
  filter(!month %in% c('2017-10', '2018-04'))
news$any[is.na(news$any)] <- 0

news <- news %>% group_by(country) %>%
  summarize(news_count = sum(any),
            news_total = sum(baseline)) %>%
  mutate(news_rate = news_count/news_total)

#trends
trends <- read.csv('https://ci-tweet-csv-dumps.s3.amazonaws.com/TRENDS.csv',
                   na.strings = '') %>%
  filter(!month %in% c('2017-10', '2018-04') & !country == '0') %>%
  group_by(country) %>%
  summarize(trends_mean = mean(rate))


#compare
all <- merge(merge(news, twit), trends) %>%
  arrange(news_rate)

all <- all %>% filter(!(twitter_count==0 | news_count==0 | trends_mean==0))

cor(all$news_rate, all$twitter_rate, method="spearman")
cor(all$news_rate, all$trends_mean, method="spearman")
cor(all$trends_mean, all$twitter_rate, method="spearman")

labelformat <- function(x){
  paste0(signif(exp(x)*100, 2), '%')
}

all$Newspapers <- all$news_rate
all$Twitter <- all$twitter_rate
all$`Google Trends` <- all$trends_mean

library(psych)
pairs.panels(log(all[ , c('Newspapers', 'Twitter', 'Google Trends')]),
             smooth = FALSE, ellipses = FALSE, method="spearman", rug=FALSE, 
             hist.col = '#888888', xaxt = "n", yaxt = "n")

sel <- c()
for (i in 1:10000){
  sel <- c(sel, cor(runif(100), runif(100)))
}


