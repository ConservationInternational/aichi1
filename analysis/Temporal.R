library(lubridate)
library(dplyr)
library(ggplot2)

twit <- read.csv('https://ci-tweet-csv-dumps.s3.amazonaws.com/TWITTER-BASELINE.csv',
                 na.strings = '') %>%
  filter(!month %in% c('2017-10', '2018-04'))
twit$any[is.na(twit$any)] <- 0
twit$just_species[is.na(twit$just_species)] <- 0
twit$any <- twit$any - twit$just_species

news <- read.csv('https://ci-tweet-csv-dumps.s3.amazonaws.com/WEBHOSE-BASELINE.csv',
                 na.strings = '') %>%
  filter(!month %in% c('2017-10', '2018-4'))

trends <- read.csv('https://ci-tweet-csv-dumps.s3.amazonaws.com/TRENDS.csv',
                 na.strings = '') %>%
  filter(!month %in% c('2017-10', '2018-4'))

twit <- twit %>%
  group_by(day) %>%
  summarize(twit_count = sum(any),
            twit_total = sum(baseline)) %>%
  mutate(twit_rate = twit_count/twit_total) %>%
  mutate(day = ymd(day))

news <- news %>%
  group_by(day) %>%
  summarize(news_count = sum(any),
            news_total = sum(baseline)) %>%
  mutate(news_rate = news_count/news_total) %>%
  mutate(day = ymd(day))

all <- merge(twit, news, all=F)
all$weekends <- weekdays(all$day) == "Sunday"

#Check out daily differences
ggplot(all, aes(x=day, twit_rate)) + 
  geom_vline(xintercept = all$day[all$weekends]) +
  geom_line()

ggplot(all, aes(x=day, news_rate)) + 
  geom_vline(xintercept = all$day[all$weekends]) +
  geom_line()
#news has a weekend effect, much more on weekdays


#Maybe look at weekly stuff
all$weeks <- ((all$day - min(all$day))/eweeks(1)) %>% ceiling

allweek <- all %>% filter(weeks != 22) %>%
  group_by(weeks) %>%
  summarize(news_count = sum(news_count),
            twit_count = sum(twit_count),
            news_total = sum(news_total),
            twit_total = sum(twit_total)) %>%
  mutate(news_rate = news_count/news_total,
         twit_rate = twit_count/twit_total)
            
ggplot(allweek) + geom_line(aes(x=weeks, y=news_rate))
