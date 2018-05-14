# !diagnostics off

library(dplyr)
library(ggplot2)

trends <- read.csv('http://biodiversityengagementindicator.com/csvs/COUNTRYTRENDS.csv',
                   stringsAsFactors=F, na.strings = '') %>%
  group_by(country) %>%
  summarize(`Google Trends` = mean(score))

twit <- read.csv('http://biodiversityengagementindicator.com/csvs/TWITTER-DETAIL.csv', na.strings = '') %>%
  group_by(country, issue) %>%
  summarize(count = sum(count))

twit_baseline <- read.csv('http://biodiversityengagementindicator.com/csvs/TWITTER-BASELINE.csv', na.strings = '') %>%
  group_by(country) %>%
  summarize(baseline = sum(baseline))

twit_all <- merge(twit, twit_baseline) %>%
  mutate(rate = count/baseline) %>%
  group_by(issue) %>%
  mutate(max=max(rate)) %>%
  ungroup %>%
  mutate(score = (rate/max)*100) %>%
  group_by(country) %>%
  summarize(Twitter = mean(score))

news <- read.csv('http://biodiversityengagementindicator.com/csvs/WEBHOSE-DETAIL.csv', na.strings = '') %>%
  group_by(country, issue) %>%
  summarize(count = sum(count))

news_baseline <- read.csv('http://biodiversityengagementindicator.com/csvs/WEBHOSE-BASELINE.csv', na.strings = '') %>%
  group_by(country) %>%
  summarize(baseline = sum(baseline))

news_all <- merge(news, news_baseline) %>%
  mutate(rate = count/baseline) %>%
  group_by(issue) %>%
  mutate(max=max(rate)) %>%
  ungroup %>%
  mutate(score = (rate/max)*100) %>%
  group_by(country) %>%
  summarize(Newspapers = mean(score))


#compare
all <- Reduce(merge, list(twit_all, news_all, trends))

all <- all %>% filter(!(Twitter==0 | Newspapers==0 | `Google Trends`==0))

labelformat <- function(x){
  paste0(signif(exp(x)*100, 2), '%')
}


library(psych)
pairs.panels(log(all[ , c('Newspapers', 'Twitter', 'Google Trends')]),
             smooth = FALSE, ellipses = FALSE, method="spearman", rug=FALSE, 
             hist.col = '#888888', xaxt = "n", yaxt = "n")


all <- all %>%
  arrange(desc(Twitter)) %>%
  mutate(Twitter_Rank = 1:n()) %>%
  arrange(desc(Newspapers)) %>%
  mutate(Newspapers_Rank = 1:n()) %>%
  arrange(desc(`Google Trends`)) %>%
  mutate(Trends_Rank = 1:n())

all$Top20 <- rowSums(all[ , c("Twitter_Rank", "Newspapers_Rank", "Trends_Rank")] <= 20) >= 2
