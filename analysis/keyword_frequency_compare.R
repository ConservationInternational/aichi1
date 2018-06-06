library(dplyr)
library(ggplot2)
library(ggrepel)

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

news_total <- sum(news_b$baseline, na.rm=T)

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

labelissues <- c("biodiversity", 
                 "biosphere", "climate change", "deforestation", "desertification", 
                 "ecology", "ecosystem service", "endangered species", "endemic species", 
                 "extinction", "genetic diversity", "habitat destruction", "habitat fragmentation", 
                 "invasive species", "keystone species", "natural capital", "ocean acidification", 
                 "protected area", "species diversity", "subspecies", "sustainability", 
                 "wildlife trade")

#climate change, sustainability, extinction, biodiversity, and ecology, while 
#the least popular keywords were endemic species, ocean acidification, habitat destruction, keystone species, and habitat fragmentation. 


ggplot(all) + 
  geom_point(aes(x=log(news_rate), y=log(twitter_rate))) + 
  geom_text_repel(data=all %>% 
              filter(issue %in% labelissues),
            aes(x=log(news_rate), y=log(twitter_rate), label=issue)) +
  scale_x_continuous(labels=labelformat) + 
  scale_y_continuous(labels=labelformat) +
  ylab('Rate of Keyword on Twitter (Log Scale)') + 
  xlab('Rate of Keyword in Newspapers (Log Scale)') + 
  theme_bw()

ggsave('D:/Documents and Settings/mcooper/GitHub/aichi1/analysis/keyword_frequency_compare.png', width=9, height=7.5)





