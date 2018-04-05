library(dplyr)

######################
#Overlap between species and other keywords
###################
twit_d <- read.csv('https://ci-tweet-csv-dumps.s3.amazonaws.com/TWITTER-DETAIL.csv',
                   na.strings = '') %>%
  filter(!month %in% c('2017-10', '2018-04'))
twit_b <- read.csv('https://ci-tweet-csv-dumps.s3.amazonaws.com/TWITTER-BASELINE.csv',
                   na.strings = '') %>%
  filter(!month %in% c('2017-10', '2018-04'))

#Total count of species
total_species <- sum(twit_d$count[twit_d$species != ''])

total_only_species <- sum(twit_b$just_species, na.rm=T)

#Percent of species tweets that also contained keywords
(total_species - total_only_species)/total_species

####################################
#Comparison by countries between species and other keywords
######################################
#nonspecies
twit <- read.csv('https://ci-tweet-csv-dumps.s3.amazonaws.com/TWITTER-BASELINE.csv',
                 na.strings = '') %>%
  filter(!month %in% c('2017-10', '2018-04'))
twit$any[is.na(twit$any)] <- 0
twit$just_species[is.na(twit$just_species)] <- 0

twit$any <- twit$any - twit$just_species

twit <- twit %>% group_by(country) %>%
  summarize(twitter_count = sum(any),
            twitter_total = sum(baseline)) %>%
  mutate(twitter_rate = twitter_count/twitter_total)

#species
twit_d <- read.csv('https://ci-tweet-csv-dumps.s3.amazonaws.com/TWITTER-DETAIL.csv',
                   na.strings = '') %>%
  filter(!month %in% c('2017-10', '2018-04') & species != '') %>%
  group_by(country) %>%
  summarize(species_count = sum(count))

species <- merge(twit, twit_d, all.x=F, all.y=F)

species$species_rate <- species$species_count/species$twitter_total

plot(log(species$species_rate), log(species$twitter_rate))
cor(log(species$species_rate), log(species$twitter_rate))
