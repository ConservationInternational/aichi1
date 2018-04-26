library(dplyr)
library(ggplot2)
library(tidyr)
library(geojsonR)
library(RColorBrewer)

options(stringsAsFactors = FALSE)

trends <- read.csv('http://biodiversityengagementindicator.com/csvs/TRENDS.csv',
                   na.strings = NULL) %>%
  group_by(country, fullname) %>%
  summarize(`Google Trends` = mean(rate))

twit <- read.csv('http://biodiversityengagementindicator.com/csvs/TWITTER-DETAIL.csv'
                 , na.strings = '') %>%
  group_by(country) %>%
  summarize(count = sum(count))

news <- read.csv('http://biodiversityengagementindicator.com/csvs/WEBHOSE-DETAIL.csv',
                 na.strings = '') %>%
  group_by(country) %>%
  summarize(count = sum(count))

twit_baseline <- read.csv('http://biodiversityengagementindicator.com/csvs/TWITTER-BASELINE.csv'
                          , na.strings = '') %>%
  group_by(country) %>%
  summarize(baseline = sum(baseline))

news_baseline <- read.csv('http://biodiversityengagementindicator.com/csvs/WEBHOSE-BASELINE.csv'
                          , na.strings = '') %>%
  group_by(country) %>%
  summarize(baseline = sum(baseline))

twitm <- merge(twit, twit_baseline) %>%
  mutate(twitrate = count/baseline) %>%
  mutate(Twitter = (twitrate/0.01)*100) %>%
  select(country, Twitter)

newsm <- merge(news, news_baseline) %>%
  mutate(newsrate = count/baseline) %>%
  mutate(Newspapers = (newsrate/0.25)*100) %>%
  select(country, Newspapers)

all <- Reduce(function(x, y){merge(x, y, all=T)}, list(twitm, newsm, trends))

all[is.na(all)] <- 0
all$Twitter[all$Twitter > 100] <- 100
all$Newspapers[all$Newspapers > 100] <- 100

all <- all %>%
  mutate(`Overall Score` = (Twitter + Newspapers + `Google Trends`)/3)

all$country[all$country == 'BQ'] <- 'AN'

gjs <- read.csv('D://Documents and Settings/mcooper/GitHub/aichi1/countries_med.csv',
                stringsAsFactors = F)

sp <- geojson_read('G:/My Drive/CI Docs/Aichi 1 Indicator/WorldMaps/gadm28_adm0_low.json', what="sp")

sp <- sp[sp$NAME_ENGLI != "Antarctica", ]


fort <- fortify(sp)

dat <- cbind(fort, sp@data[fort$id, ])

dat <- merge(dat, all, by.x="ISO2", by.y="country", all=F)

pal = brewer.pal(3, "RdYlGn")

labelformat <- function(x){
  floor(exp(x))
}

ggplot(dat, aes(long, lat, group=group)) + 
  geom_polygon(aes(fill=log(`Overall Score`)), color="#5b5c61") +
  scale_fill_gradient2(low="#fc8d59", mid = "#ffffbf", high = "#91cf60",
                       midpoint=log(2),
                      labels=labelformat) +
  scale_x_continuous(expand = c(0.0,0)) +
  scale_y_continuous(expand = c(0.0,0))  + 
  labs(fill = 'Overall Score') + 
  theme(axis.line=element_blank(),axis.text.x=element_blank(),
          axis.text.y=element_blank(),axis.ticks=element_blank(),
          axis.title.x=element_blank(),
          axis.title.y=element_blank(),
          panel.border=element_blank(),panel.grid.major=element_blank(),
          panel.grid.minor=element_blank(),plot.background=element_blank())
ggsave('D://Documents and Settings/mcooper/GitHub/aichi1/analysis/Overall Indicator over Space.png', height=3, width=8)
