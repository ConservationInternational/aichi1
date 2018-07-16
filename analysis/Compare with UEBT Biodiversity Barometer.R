#Load relevant packages for data extraction
library(tidyverse)
library(countrycode)

######################################
#Process and Edit Data
######################################

####Open data files
#Twitter
twitter_base_df <- read.csv("http://biodiversityengagementindicator.com/csvs/TWITTER-BASELINE.csv",
                            na.strings="")
twitter_det_df <- read.csv("http://biodiversityengagementindicator.com/csvs/TWITTER-DETAIL.csv",
                           na.strings="") %>%
  filter(is.na(species)) %>%
  select(-species)

#Remove species column
twitter_base_df$just_species[is.na(twitter_base_df$just_species)] <- 0
twitter_base_df$any <- twitter_base_df$any - twitter_base_df$just_species
twitter_base_df$just_species <- NULL

####Data summary
#All data
twitter_base_sum <- twitter_base_df %>% 
  group_by(country, month) %>% 
  summarise(mentions = sum(any, na.rm=T), baseline = sum(baseline, na.rm=T)) %>%
  data.frame
twitter_base_sum$issue <- "all"
twitter_base_sum$set <- "all"
twitter_base_sum[is.na(twitter_base_sum$mentions), 3] <- 0
twitter_base_sum$country <- as.character(twitter_base_sum$country)
twitter_det_all_sum <- twitter_base_sum[ , c(1,2,5,3,6)]

#Keyword data
#Issues
twitter_det_issue_sum <- twitter_det_df %>% 
  group_by(country,month,issue) %>% 
  summarise(mentions = sum(count, na.rm=T)) %>%
  data.frame
twitter_det_issue_sum$set <- "issue"

#Merge keyowrd data in a single data frame
twitter_all_sum <- bind_rows(twitter_det_issue_sum, twitter_det_all_sum)

#Expand issue dataset to include missing cases
twitter_all_exp <- as.data.frame(complete(twitter_all_sum, country, nesting(issue, set), month, fill=list(mentions=0)))
twitter_all_exp <- unique(twitter_all_exp)

#Expand baseline dataset to include missing cases
twitter_base_all <- twitter_base_sum[,c(1,2,4)]
twitter_base_all <- as.data.frame(complete(twitter_base_all,country,month,fill=list(baseline=0)))
twitter_base_all <- unique(twitter_base_all)


#Merge all data
twitter_all <- as.data.frame(left_join(twitter_all_exp,twitter_base_all,by=c("country","month")))

#Calculate relative twitter volume
twitter_all$rate <- twitter_all$mentions/twitter_all$baseline
twitter_all$rate[is.na(twitter_all$rate)] <- 0

####Open data files
#Webhose
webhose_base_df <- read.csv("http://biodiversityengagementindicator.com/csvs/WEBHOSE-BASELINE.csv",
                            na.strings="")
webhose_det_df <- read.csv("http://biodiversityengagementindicator.com/csvs/WEBHOSE-DETAIL.csv",
                           na.strings="")

####Data summary
#All data
webhose_base_sum <- webhose_base_df %>% 
  group_by(country,month) %>% 
  summarise(mentions = sum(any, na.rm=T),baseline = sum(baseline, na.rm=T)) %>%
  data.frame
webhose_base_sum$issue <- "all"
webhose_base_sum$set <- "all"
webhose_base_sum[is.na(webhose_base_sum$mentions),3] <- 0
webhose_base_sum$country <- as.character(webhose_base_sum$country)
webhose_det_all_sum <- webhose_base_sum[,c(1,2,5,3,6)]


#Keyword data
#Issues
webhose_det_issue_sum <- webhose_det_df %>% 
  group_by(country,month,issue) %>% 
  summarise(mentions = sum(count)) %>%
  data.frame
webhose_det_issue_sum$set <- "issue"

#Merge keyowrd data in a single data frame
webhose_all_sum <- bind_rows(webhose_det_issue_sum,webhose_det_all_sum)

#Expand issue dataset to include missing cases
webhose_all_exp <- as.data.frame(complete(webhose_all_sum,country,nesting(issue,set),month,fill=list(mentions=0)))
webhose_all_exp <- unique(webhose_all_exp)

#Expand baseline dataset to include missing cases
webhose_base_all <- webhose_base_sum[,c(1,2,4)]
webhose_base_all <- as.data.frame(complete(webhose_base_all,country,month,fill=list(baseline=0)))
webhose_base_all <- unique(webhose_base_all)

#Merge all data
webhose_all <- as.data.frame(left_join(webhose_all_exp,webhose_base_all,by=c("country","month")))
webhose_all <- webhose_all[!is.na(webhose_all$baseline),]

#Calculate relative webhose volume
webhose_all$rate <- webhose_all$mentions/webhose_all$baseline
webhose_all$rate[is.na(webhose_all$rate)] <- 0

####Open data files
#Trends
trends_df <- read.csv("http://biodiversityengagementindicator.com/csvs/TRENDS.csv",stringsAsFactors = F,
                      na.strings="")
#Twitter
twitter_df <- twitter_all
twitter_df <- twitter_df[twitter_df$issue %in% trends_df$issue,]

#Webhose
webhose_df <- webhose_all
webhose_df <- webhose_df[webhose_df$issue %in% trends_df$issue,]

#Filter countries
trends_df <- trends_df[trends_df$country %in% webhose_df$country,]
twitter_df <- twitter_df[twitter_df$country %in% webhose_df$country,]

#Identify max rate per issue
twitter_df_maxrate <- as.data.frame(twitter_df %>% group_by(issue) %>% summarise(top = max(rate)))
twitter_df_maxrate1000 <- as.data.frame(subset(twitter_df,twitter_df$baseline>=500) %>% group_by(issue) %>% summarise(top = max(rate)))
webhose_df_maxrate <- as.data.frame(webhose_df %>% group_by(issue) %>% summarise(top = max(rate)))
webhose_df_maxrate1000 <- as.data.frame(subset(webhose_df,webhose_df$baseline>=500) %>% group_by(issue) %>% summarise(top = max(rate)))

#Merge datasets and scale
twitter_merge <- left_join(twitter_df,twitter_df_maxrate1000,by=("issue"))
twitter_merge$rvol <- (twitter_merge$rate*100)/twitter_merge$top
twitter_merge$rvol[which(twitter_merge$rvol>100)] <- 100
twitter_sum <- as.data.frame(twitter_merge %>% group_by(country,issue) %>% summarise(mean_rvol_tw = mean(rvol)))

webhose_merge <- left_join(webhose_df,webhose_df_maxrate1000,by=("issue"))
webhose_merge$rvol <- (webhose_merge$rate*100)/webhose_merge$top
webhose_merge$rvol[which(webhose_merge$rvol>100)] <- 100
webhose_sum <- as.data.frame(webhose_merge %>% group_by(country,issue) %>% summarise(mean_rvol_wh = mean(rvol)))

trends_sum <- as.data.frame(trends_df %>% group_by(country,issue) %>% summarise(mean_rvol_tr = mean(rate)))

all_df <- left_join(trends_sum,twitter_sum,by=c("country","issue"))
all_df <- left_join(all_df,webhose_sum,by=c("country","issue"))
all_df$mean_rvol <- (all_df$mean_rvol_tr+all_df$mean_rvol_tw+all_df$mean_rvol_wh)/3
all_sum <- all_df[,c(1,2,6)]

#Convert database from wide to long format
all_sum_wide <- spread(all_sum,issue,mean_rvol)
#remove countries where search interest never peaked above 5 - this removes coutnries with few data
all_sum_wide_filt <- all_sum_wide[apply(all_sum_wide[,2:23],1,function(x) any(x>5)),]

#Plot by country
trends_sum_wide <- spread(trends_sum,issue,mean_rvol_tr)
twitter_sum_wide <- spread(twitter_sum,issue,mean_rvol_tw)
webhose_sum_wide <- spread(webhose_sum,issue,mean_rvol_wh)

biodiversity <- Reduce(merge, list(
  trends_sum_wide %>%
    select(country, trends=biodiversity),
  twitter_sum_wide %>%
    select(country, twitter=biodiversity),
  webhose_sum_wide %>%
    select(country, webhose=biodiversity)))

biodiversity$biodiversity_overall <- rowMeans(biodiversity %>% select(-country))

all <- Reduce(function(x,y) merge(x,y, by='country'), list(
  trends_sum_wide, twitter_sum_wide, webhose_sum_wide))

all$overall <- rowMeans(all %>% select(-country))

all <- all %>%
  select(country, overall)

#Get Biodiversity Barometer Scores:
#https://static1.squarespace.com/static/577e0feae4fcb502316dc547/t/5b296f4303ce646e89dfb50a/1529442211066/UEBT+2018-Biodiversitybarometer.pdf

barometer <- data.frame(country = c("US", "MX", "CO", "EC", 
                                 "PE", "BR", "GB", "NL", "FR", "DE", "CH", 
                                 "KR", "CN", "JP", "IN", "VN"), 
                        aware = c(55, 90, 93, 80, 94, 91, 66, 59, 90, 53, 83, 73, 94, 62, 40, 95), 
                        correct_def = c(25, 46, 44, 20, 72, 49, 22, 27, 34, 25, 37, 47, 64, 29, 1, 36), 
                        partial_def = c(16, 20, 10, 29, 14, 15, 12, 16, 16, 9, 18, 16, 22, 21, 26, 6))

final <- Reduce(merge, list(all, biodiversity, barometer))

cor(final %>% select(-country), method = "spearman")
