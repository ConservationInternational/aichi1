#Load relevant packages for data extraction
library(tidyverse)
library(ggplot2)
library(tidygraph)
library(ggraph)
library(countrycode)
library(RColorBrewer)
library(ggpubr)

####Open data files
#Twitter
twitter_base_df<-read.csv("Data/TWITTER-BASELINE.csv")
head(twitter_base_df)
str(twitter_base_df)
summary(twitter_base_df)

twitter_det_df<-read.csv("Data/TWITTER-DETAIL.csv")
head(twitter_det_df)
str(twitter_det_df)
summary(twitter_det_df)

#Filter NAs
twitter_base_filt_df<-twitter_base_df[apply(twitter_base_df,1,function(x) !any(is.na(x))),]
summary(twitter_base_filt_df)

####Data summary
#All data
twitter_base_sum<-twitter_base_filt_df %>% group_by(country,month) %>% summarise(mentions = sum(any),baseline = sum(baseline))
twitter_base_sum$issue<-"all"
twitter_base_sum$set<-"all"
summary(twitter_base_sum)
twitter_det_all_sum<-twitter_base_sum[,c(1,2,5,3,6)]
head(twitter_det_all_sum)
summary(twitter_det_all_sum)

#Keyword data
#Issues
twitter_det_issue_sum<-twitter_det_df %>% group_by(country,month,issue) %>% summarise(mentions = sum(count))
twitter_det_issue_sum<-twitter_det_issue_sum[-which(twitter_det_issue_sum$issue==""),]
twitter_det_issue_sum$set<-"issue"
head(twitter_det_issue_sum)
#Species
twitter_det_species_sum<-twitter_det_df %>% group_by(country,month,species) %>% summarise(mentions = sum(count))
twitter_det_species_sum<-twitter_det_species_sum[-which(twitter_det_species_sum$species==""),]
twitter_det_species_sum$set<-"species"
names(twitter_det_species_sum)[3]<-"issue"
head(twitter_det_species_sum)

#Merge keyowrd data in a single data frame
twitter_all_sum<-as.data.frame(bind_rows(twitter_det_issue_sum,twitter_det_species_sum,twitter_det_all_sum))
head(twitter_all_sum)
str(twitter_all_sum)

#Expand issue dataset to include missing cases
twitter_all_exp<-as.data.frame(complete(twitter_all_sum,country,nesting(issue,set),month,fill=list(mentions=0)))
twitter_all_exp<-unique(twitter_all_exp)
head(twitter_all_exp)
str(twitter_all_exp)
#Expand baseline dataset to include missing cases
twitter_base_all<-twitter_base_sum[,c(1,2,4)]
twitter_base_all<-as.data.frame(complete(twitter_base_all,country,month,fill=list(baseline=0)))
twitter_base_all<-unique(twitter_base_all)
head(twitter_base_all)
str(twitter_base_all)

#Merge all data
twitter_all<-as.data.frame(left_join(twitter_all_exp,twitter_base_all,by=c("country","month")))
head(twitter_all)

#Calculate relative twitter volume
twitter_all$rate<-twitter_all$mentions/twitter_all$baseline
twitter_all$rate[is.na(twitter_all$rate)]<-0
head(twitter_all)
summary(twitter_all)

#Save data to file
write.csv(twitter_all,"Data/TWITTER-ALL.CSV",row.names = F)


####Open data files
#Webhose
webhose_base_df<-read.csv("Data/WEBHOSE-BASELINE.csv")
head(webhose_base_df)
str(webhose_base_df)
summary(webhose_base_df)

webhose_det_df<-read.csv("Data/WEBHOSE-DETAIL.csv")
head(webhose_det_df)
str(webhose_det_df)
summary(webhose_det_df)

#Filter NAs
webhose_base_filt_df<-webhose_base_df[apply(webhose_base_df,1,function(x) !any(is.na(x))),]
summary(webhose_base_filt_df)

####Data summary
#All data
webhose_base_sum<-webhose_base_filt_df %>% group_by(country,month) %>% summarise(mentions = sum(any),baseline = sum(baseline))
webhose_base_sum$issue<-"all"
webhose_base_sum$set<-"all"
summary(webhose_base_sum)
webhose_det_all_sum<-webhose_base_sum[,c(1,2,5,3,6)]
head(webhose_det_all_sum)
summary(webhose_det_all_sum)

#Keyword data
#Issues
webhose_det_issue_sum<-webhose_det_df %>% group_by(country,month,issue) %>% summarise(mentions = sum(count))
webhose_det_issue_sum<-webhose_det_issue_sum[-which(webhose_det_issue_sum$country==""),]
webhose_det_issue_sum$set<-"issue"
head(webhose_det_issue_sum)

#Merge keyowrd data in a single data frame
webhose_all_sum<-as.data.frame(bind_rows(webhose_det_issue_sum,webhose_det_all_sum))
head(webhose_all_sum)
str(webhose_all_sum)

#Expand issue dataset to include missing cases
webhose_all_exp<-as.data.frame(complete(webhose_all_sum,country,nesting(issue,set),month,fill=list(mentions=0)))
webhose_all_exp<-unique(webhose_all_exp)
head(webhose_all_exp)
str(webhose_all_exp)
#Expand baseline dataset to include missing cases
webhose_base_all<-webhose_base_sum[,c(1,2,4)]
webhose_base_all<-as.data.frame(complete(webhose_base_all,country,month,fill=list(baseline=0)))
webhose_base_all<-unique(webhose_base_all)
head(webhose_base_all)
str(webhose_base_all)

#Merge all data
webhose_all<-as.data.frame(left_join(webhose_all_exp,webhose_base_all,by=c("country","month")))
webhose_all<-webhose_all[!is.na(webhose_all$baseline),]
head(webhose_all)

#Calculate relative webhose volume
webhose_all$rate<-webhose_all$mentions/webhose_all$baseline
webhose_all$rate[is.na(webhose_all$rate)]<-0
head(webhose_all)
summary(webhose_all)

#Save data to file
write.csv(webhose_all,"Data/WEBHOSE-ALL.CSV",row.names = F)
