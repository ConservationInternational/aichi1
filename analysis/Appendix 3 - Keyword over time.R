library(lubridate)
library(dplyr)
library(ggplot2)
library(tidyr)
library(pracma)

keyword <- 'biodiversity'

#For the overall google trends requests, it looks like the IP on the server is blocked.
#Will have to locally run scripts in aichi1/collect-trends/trends-daily.py in order to get up-to-date trends CSV

trends <- read.csv('C://Git/aichi1/DAILYTRENDS-Stitch.csv',
                   stringsAsFactors=F) %>%
  filter(keyword==keyword) %>%
  mutate(day = ymd(date)) %>%
  group_by(day) %>%
  summarize(`Google Trends` = mean(score))

twit <- read.csv('http://biodiversityengagementindicator.com/csvs/TWITTER-DETAIL.csv') %>%
  mutate(day = ymd(day)) %>%
  filter(issue==keyword) %>%
  group_by(day, issue) %>%
  summarize(count = sum(count))

twit_baseline <- read.csv('http://biodiversityengagementindicator.com/csvs/TWITTER-BASELINE.csv') %>%
  mutate(day = ymd(day)) %>%
  group_by(day) %>%
  summarize(baseline = sum(baseline))

twit_all <- merge(twit, twit_baseline) %>%
  mutate(rate = count/baseline) %>%
  group_by(issue) %>%
  mutate(max=max(rate)) %>%
  ungroup %>%
  mutate(score = (rate/max)*100) %>%
  group_by(day) %>%
  summarize(Twitter = mean(score))

news <- read.csv('http://biodiversityengagementindicator.com/csvs/WEBHOSE-DETAIL.csv') %>%
  mutate(day = ymd(day)) %>%
  filter(issue == keyword) %>%
  group_by(day, issue) %>%
  summarize(count = sum(count))

news_baseline <- read.csv('http://biodiversityengagementindicator.com/csvs/WEBHOSE-BASELINE.csv') %>%
  mutate(day = ymd(day)) %>%
  group_by(day) %>%
  summarize(baseline = sum(baseline))

news_all <- merge(news, news_baseline) %>%
  mutate(rate = count/baseline) %>%
  group_by(issue) %>%
  mutate(max=max(rate, na.rm=T)) %>%
  ungroup %>%
  mutate(score = (rate/max)*100) %>%
  group_by(day) %>%
  summarize(Newspapers = mean(score, na.rm=T))

all <- Reduce(merge, list(twit_all, news_all, trends)) %>%
  mutate(`Overall Score` = (Twitter + Newspapers + `Google Trends`)/3) %>%
  gather(Platform, score, -day) %>%
  na.omit

#####################################################################
#Visualize which days fo the week are highest on which platforms
####################################################################
# tmp <- all %>% 
#   mutate(weekday = weekdays(day)) %>%
#   group_by(weekday, Platform) %>%
#   summarize(score = mean(score))
# 
# tmp$weekday <- factor(tmp$weekday, levels=c("Monday", "Tuesday", "Wednesday", "Thursday",
#                                             "Friday", "Saturday", "Sunday"))
# 
# ggplot(tmp) + geom_point(aes(x=weekday, y=log(score), color=Platform))

datelabel <- function(d){
  format(d, "%B,\n %Y")
}

brks <- seq(ymd('2017-11-01'), ymd('2018-10-31'), 'months')

all$Platform <- factor(all$Platform, levels=c("Google Trends", "Twitter", "Newspapers", "Overall Score"))

all <- all %>%
  filter(Platform != "Overall Score")

ggplot(all) + geom_line(aes(x=day, y=score), size = 0.75) + 
  scale_y_continuous() + 
  scale_x_date(breaks = brks, labels=datelabel) + 
  theme_bw() + 
  xlab('Date') + ylab('Indicator Score') + 
  facet_grid(Platform~.)

ggsave(paste0('C://Git/aichi1/analysis/Appendix 3 - ', keyword, '.png'), height=4, width=8)
