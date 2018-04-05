library(tidyverse)

cc <- read.csv('D://Documents and Settings/mcooper/GitHub/aichi1/countries.csv',
               col.names=c('fullname', 'country'))

twit_d <- read.csv('https://ci-tweet-csv-dumps.s3.amazonaws.com/TWITTER-DETAIL.csv') %>%
  filter(issue != "" & !month %in% c('2017-10', '2018-04')) %>%
  group_by(country, issue) %>%
  summarize(total_count = sum(count))

twit_b <- read.csv('https://ci-tweet-csv-dumps.s3.amazonaws.com/TWITTER-BASELINE.csv') %>%
  filter(!month %in% c('2017-10', '2018-04'))
twit_b$any[is.na(twit_b$any)] <- 0
twit_b$just_species[is.na(twit_b$just_species)] <- 0
twit_b$any <- twit_b$any - twit_b$just_species

twit_b <- twit_b %>%
  group_by(country) %>%
  summarize(baseline = sum(baseline))

twit <- merge(merge(twit_d, twit_b), cc, all.x=T, all.y=F) %>%
  mutate(rate = total_count/baseline) %>%
  select(-total_count, -baseline, -country) %>%
  spread(fullname, rate)

#Look at how many countries are missing many topics
#colSums(is.na(twit))

#remove countries with less than X topics represented
twit <- twit[ , colSums(is.na(twit)) < 13]
twit[is.na(twit)] <- 0

issues <- twit$issue
twit$issue <- NULL

#PCA
pc <- prcomp(twit)
pc <- pc$x

library(ggfortify)
autoplot(prcomp(twit, scale.=TRUE))

row.names(pc) <- issues

cormat <- cor(twit, pc)
