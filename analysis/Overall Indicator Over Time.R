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
  filter(issue != '' & month != '2018-05') %>%
  mutate(day = ymd(day)) %>%
  group_by(day, issue) %>%
  summarize(count = sum(count))

twit_baseline <- read.csv('http://biodiversityengagementindicator.com/csvs/TWITTER-BASELINE.csv') %>%
  filter(month != '2018-05') %>%
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
  filter(month != '2018-05') %>%
  mutate(day = ymd(day)) %>%
  group_by(day, issue) %>%
  summarize(count = sum(count))

news_baseline <- read.csv('http://biodiversityengagementindicator.com/csvs/WEBHOSE-BASELINE.csv') %>%
  filter(month != '2018-05') %>%
  mutate(day = ymd(day)) %>%
  group_by(day) %>%
  summarize(baseline = sum(baseline))

news_all <- merge(news, news_baseline) %>%
  mutate(rate = count/baseline) %>%
  group_by(issue) %>%
  mutate(max=max(rate)) %>%
  ungroup %>%
  mutate(score = (rate/max)*100) %>%
  group_by(day) %>%
  summarize(Newspapers = mean(score))

all <- Reduce(merge, list(twit_all, news_all, trends)) %>%
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

datelabel <- function(d){
  format(d, "%B,\n %Y")
}

brks <- seq(ymd('2017-11-01'), ymd('2018-05-01'), 'months')

all$Platform <- factor(all$Platform, levels=c("Google Trends", "Twitter", "Newspapers", "Overall Score"))

all <- all %>%
  filter(Platform != "Overall Score")

ggplot(all) + geom_line(aes(x=day, y=score), size = 0.75) + 
  scale_y_continuous() + 
  scale_x_date(breaks = brks, labels=datelabel) + 
  theme_bw() + 
  xlab('Date') + ylab('Indicator Score') + 
  facet_grid(Platform~.)

ggsave('D://Documents and Settings/mcooper/GitHub/aichi1/analysis/Overall Indicator Over Time v2.png', height=4, width=8)

weekdays <- all %>%
  mutate(Weekday=weekdays(day)) %>%
  group_by(Platform, Weekday) %>%
  summarize(Score=mean(score))

weekdays$Weekday <- factor(weekdays$Weekday, levels=c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"))

write.csv(weekdays %>% spread(Platform, Score), '../weekday_scores.csv', row.names=F)

ggplot(weekdays) + 
  geom_line(aes(x=Weekday, y=Score, group=Platform, color=Platform), size=1) + 
  ylab("Average Score") + 
  theme(legend.position = c(0.75, 0.85))

ggsave('D://Documents and Settings/mcooper/GitHub/aichi1/analysis/Weekdays.png', height=4, width=8)
