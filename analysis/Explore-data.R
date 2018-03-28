library(lubridate)
library(dplyr)
library(ggplot2)

topic <- 'climate change'
country <- 'us'

trends <- read.csv('https://ci-tweet-csv-dumps.s3.amazonaws.com/TRENDS.csv') 

twit <- read.csv('https://ci-tweet-csv-dumps.s3.amazonaws.com/TWITTER-DETAIL.csv') %>%
  filter(issue == topic & country %in% c('US', 'GB', 'FR', 'CA', 'BR', 'ES', 'IN', 'MX', 'IT', 'AU', 'DE', 'CO')) %>%
  mutate(day = ymd(day)) %>%
  filter(day > ymd('2017-10-31')) %>%
  group_by(day, country) %>%
  summarize(count = sum(count))
# news <- read.csv('https://ci-tweet-csv-dumps.s3.amazonaws.com/WEBHOSE-DETAIL.csv') %>%
#   filter(issue == topic & country == country) %>%
#   mutate(day = ymd(day)) %>%
#   filter(day > ymd('2017-10-31')) %>%
#   group_by(day) %>%
#   summarize(count = sum(count))

twit_baseline <- read.csv('https://ci-tweet-csv-dumps.s3.amazonaws.com/TWITTER-BASELINE.csv') %>%
  mutate(day = ymd(day)) %>%
  filter(day > ymd('2017-10-31') & country %in% c('US', 'GB', 'FR', 'CA', 'BR', 'ES', 'IN', 'MX', 'IT', 'AU', 'DE', 'CO')) %>%
  group_by(day, country) %>%
  summarize(baseline = sum(baseline))
# news_baseline <- read.csv('https://ci-tweet-csv-dumps.s3.amazonaws.com/WEBHOSE-BASELINE.csv') %>%
#   mutate(day = ymd(day)) %>%
#   filter(day > ymd('2017-10-31') & country == country) %>%
#   group_by(day) %>%
#   summarize(baseline = sum(baseline))

twitm <- merge(twit, twit_baseline) %>%
  mutate(twitrate = count/baseline) %>%
  select(day, country, twitrate)

# newsm <- merge(news, news_baseline) %>%
#   mutate(newsrate = count/baseline) %>%
#   select(day, newsrate)
# 
# 
#m <- merge(twitm %>% filter(country=='US'), twitm %>% filter(country=='GB'), by='day')
# 
# 
# library(forecast)
# 
# auto.arima(twitm$rate)
# 
# 
# all <- bind_rows(twitm, newsm)

ggplot(twitm) + geom_line(aes(x=day, y=twitrate, color=country))

library(tidyr)
twitspread <- twitm %>% spread(country, twitrate)

twitspread[is.na(twitspread)] <- 0

cor(twitspread %>% select(-day))

