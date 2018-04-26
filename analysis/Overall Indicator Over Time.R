library(lubridate)
library(dplyr)
library(ggplot2)
library(tidyr)

trends <- read.csv('http://biodiversityengagementindicator.com/csvs/DAILYTRENDS.csv',
                   stringsAsFactors=F) %>%
  mutate(day = ymd(date)) %>%
  group_by(day) %>%
  summarize(`Google Trends` = mean(score))

twit <- read.csv('http://biodiversityengagementindicator.com/csvs/TWITTER-DETAIL.csv') %>%
  mutate(day = ymd(day)) %>%
  group_by(day) %>%
  summarize(count = sum(count))

news <- read.csv('http://biodiversityengagementindicator.com/csvs/WEBHOSE-DETAIL.csv') %>%
  mutate(day = ymd(day)) %>%
  group_by(day) %>%
  summarize(count = sum(count))

twit_baseline <- read.csv('http://biodiversityengagementindicator.com/csvs/TWITTER-BASELINE.csv') %>%
  mutate(day = ymd(day)) %>%
  group_by(day) %>%
  summarize(baseline = sum(baseline))

news_baseline <- read.csv('http://biodiversityengagementindicator.com/csvs/WEBHOSE-BASELINE.csv') %>%
  mutate(day = ymd(day)) %>%
  group_by(day) %>%
  summarize(baseline = sum(baseline))

twitm <- merge(twit, twit_baseline) %>%
  mutate(twitrate = count/baseline) %>%
  mutate(Twitter = (twitrate/0.01)*100) %>%
  select(day, Twitter)

newsm <- merge(news, news_baseline) %>%
  mutate(newsrate = count/baseline) %>%
  mutate(Newspapers = (newsrate/0.25)*100) %>%
  select(day, Newspapers)

all <- Reduce(merge, list(twitm, newsm, trends)) %>%
  mutate(`Overall Score` = (Twitter + Newspapers + `Google Trends`)/3) %>%
  gather(Platform, score, -day)

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

all$lscore <- log(all$score)

labelformat <- function(x){
  paste0(signif(exp(x), 2))
}

datelabel <- function(d){
  format(d, "%B,\n %Y")
}

brks <- seq(ymd('2017-11-01'), ymd('2018-05-01'), 'months')

all$Platform <- factor(all$Platform, levels=c("Google Trends", "Twitter", "Newspapers", "Overall Score"))

ggplot(all) + geom_line(aes(x=day, y=lscore, color=Platform), size = 0.75) + 
  scale_y_continuous(labels=labelformat) + 
  scale_x_date(breaks = brks, labels=datelabel) + 
  theme_bw() + 
  scale_color_manual(values=c(Twitter="#1A5EAB", Newspapers="#5b5c62", `Google Trends`='#e6673e', `Overall Score`="#357d57")) +
  xlab('Date') + ylab('Indicator Score (Log Scale)')

ggsave('D://Documents and Settings/mcooper/GitHub/aichi1/analysis/Overall Indicator Over Time.png', height=4, width=8)

#ggplot(all %>% filter(Platform=="Newspapers" & month(day)==1)) + geom_line(aes(x=day, y=score))




