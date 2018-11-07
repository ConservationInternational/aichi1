library(dplyr)
library(ggplot2)
library(ggrepel)

#twitter
twit_d <- read.csv("http://biodiversityengagementindicator.com/csvs/TWITTER-DETAIL.csv")
twit_b <- read.csv("http://biodiversityengagementindicator.com/csvs/TWITTER-BASELINE.csv")

twit_total <- sum(twit_b$baseline)

twit_d <- twit_d %>%
  group_by(issue) %>%
  summarize(twitter_count = sum(count)) %>%
  mutate(twitter_rate = twitter_count/twit_total)

#newspapers
news_d <- read.csv('http://biodiversityengagementindicator.com/csvs/WEBHOSE-DETAIL.csv')
news_b <- read.csv('http://biodiversityengagementindicator.com/csvs/WEBHOSE-BASELINE.csv')
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
options(scipen=999)

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

ggsave('C:/Git/aichi1/analysis/Figure 3.png', width=9, height=7.5)

