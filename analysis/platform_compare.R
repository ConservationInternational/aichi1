library(dplyr)
library(ggplot2)

#twitter
twit_d <- read.csv('https://ci-tweet-csv-dumps.s3.amazonaws.com/TWITTER-DETAIL.csv') %>%
  filter(issue != "" & !month %in% c('2017-10', '2018-04'))
twit_b <- read.csv('https://ci-tweet-csv-dumps.s3.amazonaws.com/TWITTER-BASELINE.csv') %>%
  filter(!month %in% c('2017-10', '2018-04'))

twit_total <- sum(twit_b$baseline)

twit_d <- twit_d %>%
  group_by(issue) %>%
  summarize(twitter_count = sum(count)) %>%
  mutate(twitter_rate = twitter_count/twit_total)

#newspapers
news_d <- read.csv('https://ci-tweet-csv-dumps.s3.amazonaws.com/WEBHOSE-DETAIL.csv') %>%
  filter(!month %in% c('2017-10', '2018-04'))
news_b <- read.csv('https://ci-tweet-csv-dumps.s3.amazonaws.com/WEBHOSE-BASELINE.csv') %>%
  filter(!month %in% c('2017-10', '2018-04'))

news_total <- sum(news_b$baseline)

news_d <- news_d %>%
  group_by(issue) %>%
  summarize(news_count = sum(count)) %>%
  mutate(news_rate = news_count/news_total)

#compare
all <- merge(news_d, twit_d) %>%
  arrange(news_rate)

cor(all$news_rate, all$twitter_rate, method="pearson")

labelformat <- function(x){
  paste0(signif(exp(x)*100, 2), '%')
}

labelissues <- c('climate change', 'biodiversity',
                 'deforestation', 'protected area',
                 'species diversity', 'keystone species',
                 'habitat fragmentation')

hjusts <- c(0, 0, 0, 0, 0, 0, 1)

ggplot(all) + 
  geom_point(aes(x=log(news_rate), y=log(twitter_rate))) + 
  geom_text(data=all %>% 
              filter(issue %in% labelissues) %>%
              mutate(hjusts=hjusts, issue=paste0(' ', issue, ' ')),
            aes(x=log(news_rate), y=log(twitter_rate), label=issue, hjust=hjusts)) +
  scale_x_continuous(labels=labelformat) + 
  scale_y_continuous(labels=labelformat) +
  ylab('Rate of Keyword on Twitter (Log Scale)') + 
  xlab('Rate of Keyword in Newspapers (Log Scale)') + 
  theme_bw()

ggsave('D:/Documents and Settings/mcooper/GitHub/aichi1/analysis/platform_compare.png', width=6, height=5)





