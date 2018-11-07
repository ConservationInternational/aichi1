library(lubridate)
library(dplyr)
library(ggplot2)
library(tidyr)
library(pracma)

#For the overall google trends requests, it looks like the IP on the server is blocked.
#Will have to locally run scripts in aichi1/collect-trends/trends-daily.py in order to get up-to-date trends CSV

############################################
#Overall Indicator
############################################

trends <- read.csv('http://biodiversityengagementindicator.com/csvs/DAILYTRENDS.csv',
                   stringsAsFactors=F) 
twit <- read.csv('http://biodiversityengagementindicator.com/csvs/TWITTER-DETAIL.csv')
twit_baseline <- read.csv('http://biodiversityengagementindicator.com/csvs/TWITTER-BASELINE.csv')
news <- read.csv('http://biodiversityengagementindicator.com/csvs/WEBHOSE-DETAIL.csv')
news_baseline <- read.csv('http://biodiversityengagementindicator.com/csvs/WEBHOSE-BASELINE.csv')

news_overall <- news %>%
  mutate(day = ymd(day)) %>%
  group_by(day, issue) %>%
  summarize(count = sum(count))

news_baseline_overall <- news_baseline %>%
  mutate(day = ymd(day)) %>%
  group_by(day) %>%
  summarize(baseline = sum(baseline))

trends_overall <- trends %>%
  mutate(day = ymd(date)) %>%
  group_by(day) %>%
  summarize(`Google Trends` = mean(score))

twit_overall <- twit %>%
  mutate(day = ymd(day)) %>%
  group_by(day, issue) %>%
  summarize(count = sum(count))

twit_baseline_overall <- twit_baseline %>%
  mutate(day = ymd(day)) %>%
  group_by(day) %>%
  summarize(baseline = sum(baseline))

twit_all_overall <- merge(twit_overall, twit_baseline_overall) %>%
  mutate(rate = count/baseline) %>%
  group_by(issue) %>%
  mutate(max=max(rate)) %>%
  ungroup %>%
  mutate(score = (rate/max)*100) %>%
  group_by(day) %>%
  summarize(Twitter = mean(score))

news_all_overall <- merge(news_overall, news_baseline_overall) %>%
  mutate(rate = count/baseline) %>%
  group_by(issue) %>%
  mutate(max=max(rate, na.rm=T)) %>%
  ungroup %>%
  mutate(score = (rate/max)*100) %>%
  group_by(day) %>%
  summarize(Newspapers = mean(score, na.rm=T))

all_overall <- Reduce(merge, list(twit_all_overall, news_all_overall, trends_overall)) %>%
  mutate(`Overall Score` = (Twitter + Newspapers + `Google Trends`)/3) %>%
  gather(Platform, score, -day) %>%
  na.omit

datelabel <- function(d){
  format(d, "%b\n%Y")
}

brks <- seq(ymd('2017-11-01'), ymd('2018-11-01'), 'months')

all_overall$Platform <- factor(all_overall$Platform, levels=c("Google Trends", "Twitter", "Newspapers", "Overall Score"))

all_overall <- all_overall %>%
  filter(Platform != "Overall Score")

overall <- ggplot(all_overall) + geom_line(aes(x=day, y=score), size = 0.75) + 
  scale_y_continuous() + 
  scale_x_date(breaks = brks, labels=datelabel) + 
  theme_bw() + 
  xlab('Date') + ylab('Indicator Score') + 
  facet_grid(Platform~.) + 
  ggtitle("Overall Indicator Over Time, by Platform")

weekdays <- all %>%
  mutate(Weekday=weekdays(day)) %>%
  group_by(Platform, Weekday) %>%
  summarize(Score=mean(score, na.rm=T))

weekdays$Weekday <- factor(weekdays$Weekday, levels=c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"))

write.csv(weekdays %>% spread(Platform, Score), 'C://Git/aichi1/analysis/Appendix 2.csv', row.names=F)

ggplot(weekdays) + 
  geom_line(aes(x=Weekday, y=Score, group=Platform, color=Platform), size=1) + 
  ylab("Average Score") + 
  theme(legend.position = c(0.85, 0.85)) + 
  theme_bw()

########################################
#Indicator for Biodiversity
#########################################

kw <- 'biodiversity'

trends_bio <- trends %>%
  filter(keyword==kw) %>%
  mutate(day = ymd(date)) %>%
  group_by(day) %>%
  summarize(`Google Trends` = mean(score))

twit_bio <- twit %>%
  mutate(day = ymd(day)) %>%
  filter(issue==kw) %>%
  group_by(day, issue) %>%
  summarize(count = sum(count))

twit_baseline_bio <- twit_baseline %>%
  mutate(day = ymd(day)) %>%
  group_by(day) %>%
  summarize(baseline = sum(baseline))

twit_all_bio <- merge(twit_bio, twit_baseline_bio) %>%
  mutate(rate = count/baseline) %>%
  group_by(issue) %>%
  mutate(max=max(rate)) %>%
  ungroup %>%
  mutate(score = (rate/max)*100) %>%
  group_by(day) %>%
  summarize(Twitter = mean(score))

news_bio <- news %>%
  mutate(day = ymd(day)) %>%
  filter(issue == kw) %>%
  group_by(day, issue) %>%
  summarize(count = sum(count))

news_baseline_bio <- news_baseline %>%
  mutate(day = ymd(day)) %>%
  group_by(day) %>%
  summarize(baseline = sum(baseline))

news_all_bio <- merge(news_bio, news_baseline_bio) %>%
  mutate(rate = count/baseline) %>%
  group_by(issue) %>%
  mutate(max=max(rate, na.rm=T)) %>%
  ungroup %>%
  mutate(score = (rate/max)*100) %>%
  group_by(day) %>%
  summarize(Newspapers = mean(score, na.rm=T))

all_bio <- Reduce(merge, list(twit_all_bio, news_all_bio, trends_bio)) %>%
  mutate(`Overall Score` = (Twitter + Newspapers + `Google Trends`)/3) %>%
  gather(Platform, score, -day) %>%
  na.omit

datelabel <- function(d){
  format(d, "%B,\n %Y")
}

brks <- seq(ymd('2017-11-01'), ymd('2018-11-01'), 'months')

all_bio$Platform <- factor(all_bio$Platform, levels=c("Google Trends", "Twitter", "Newspapers", "Overall Score"))

all_bio <- all_bio %>%
  filter(Platform != "Overall Score")

bio <- ggplot(all_bio) + geom_line(aes(x=day, y=score), size = 0.75) + 
  scale_y_continuous() + 
  scale_x_date(breaks = brks, labels=datelabel) + 
  theme_bw() + 
  xlab('Date') + ylab('Indicator Score') + 
  geom_vline(xintercept = ymd("2018-05-22"), linetype=2) + 
  facet_grid(Platform~.) + 
  ggtitle('Indicator for "Biodiversity" Over Time, by Platform')

########################################
#Indicator for Climate Change
#########################################

kw <- 'climate change'

trends_cc <- trends %>%
  filter(keyword==kw) %>%
  mutate(day = ymd(date)) %>%
  group_by(day) %>%
  summarize(`Google Trends` = mean(score))

twit_cc <- twit %>%
  mutate(day = ymd(day)) %>%
  filter(issue==kw) %>%
  group_by(day, issue) %>%
  summarize(count = sum(count))

twit_baseline_cc <- twit_baseline %>%
  mutate(day = ymd(day)) %>%
  group_by(day) %>%
  summarize(baseline = sum(baseline))

twit_all_cc <- merge(twit_cc, twit_baseline_cc) %>%
  mutate(rate = count/baseline) %>%
  group_by(issue) %>%
  mutate(max=max(rate)) %>%
  ungroup %>%
  mutate(score = (rate/max)*100) %>%
  group_by(day) %>%
  summarize(Twitter = mean(score))

news_cc <- news %>%
  mutate(day = ymd(day)) %>%
  filter(issue == kw) %>%
  group_by(day, issue) %>%
  summarize(count = sum(count))

news_baseline_cc <- news_baseline %>%
  mutate(day = ymd(day)) %>%
  group_by(day) %>%
  summarize(baseline = sum(baseline))

news_all_cc <- merge(news_cc, news_baseline_cc) %>%
  mutate(rate = count/baseline) %>%
  group_by(issue) %>%
  mutate(max=max(rate, na.rm=T)) %>%
  ungroup %>%
  mutate(score = (rate/max)*100) %>%
  group_by(day) %>%
  summarize(Newspapers = mean(score, na.rm=T))

all_cc <- Reduce(merge, list(twit_all_cc, news_all_cc, trends_cc)) %>%
  mutate(`Overall Score` = (Twitter + Newspapers + `Google Trends`)/3) %>%
  gather(Platform, score, -day) %>%
  na.omit

datelabel <- function(d){
  format(d, "%B,\n %Y")
}

brks <- seq(ymd('2017-11-01'), ymd('2018-11-01'), 'months')

all_cc$Platform <- factor(all_cc$Platform, levels=c("Google Trends", "Twitter", "Newspapers", "Overall Score"))

all_cc <- all_cc %>%
  filter(Platform != "Overall Score")

cc <- ggplot(all_cc) + geom_line(aes(x=day, y=score), size = 0.75) + 
  scale_y_continuous() + 
  scale_x_date(breaks = brks, labels=datelabel) + 
  theme_bw() + 
  xlab('Date') + ylab('Indicator Score') + 
  geom_vline(xintercept = ymd("2018-10-08"), linetype=2) + 
  facet_grid(Platform~.) + 
  ggtitle('Indicator for "Climate Change" Over Time, by Platform')

####################################
#Combine
###################################
plot_grid(overall, bio, cc, labels="AUTO", nrow=3)

ggsave('C://Git/aichi1/analysis/Figure 4 - Indicator Over Time.png', height=12, width=9)
