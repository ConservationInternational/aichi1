#Load relevant packages for data extraction
library(tidyverse)
library(ggplot2)
library(tidygraph)
library(ggraph)
library(countrycode)
library(RColorBrewer)
library(ggpubr)
library(arules)
library(arulesViz)

####Open data files
#Trends
trends_df<-read.csv("Data/TRENDS.csv")
head(trends_df)
str(trends_df)

#Twitter
twitter_df<-read.csv("Data/TWITTER-ALL.csv")
twitter_df<-twitter_df[which(twitter_df$set=="issue"),c(1,2,4,7)]
head(twitter_df)
str(twitter_df)

#Webhose
webhose_df<-read.csv("Data/WEBHOSE-ALL.csv")
webhose_df<-webhose_df[which(webhose_df$set=="issue"),c(1,2,4,7)]
head(webhose_df)
str(webhose_df)

####Data editing
#Generate wide data frames
#Trends
trends_df$issue<-paste0("GT.",trends_df$issue)
trends_wide<-spread(trends_df,issue,rate)
head(trends_wide)

#Twitter
twitter_df$issue<-paste0("TW.",twitter_df$issue)
twitter_wide<-spread(twitter_df,issue,rate)
head(twitter_wide)

#Webhose
webhose_df$issue<-paste0("WH.",webhose_df$issue)
webhose_wide<-spread(webhose_df,issue,rate)
head(webhose_wide)

#Select countries that match in all datasets
ctry<-Reduce(intersect, list(trends_wide$country,twitter_wide$country,webhose_wide$country))
#Trends
trends_wide_sel<-trends_wide[trends_wide$country %in% ctry,]
summary(trends_wide_sel)
#Twitter
twitter_wide_sel<-twitter_wide[twitter_wide$country %in% ctry,]
summary(twitter_wide_sel)
#Webhose
webhose_wide_sel<-webhose_wide[webhose_wide$country %in% ctry,]
webhose_wide_sel$month<-as.character(webhose_wide_sel$month)
webhose_wide_sel$month[which(webhose_wide_sel$month=="2018-1")]<-"2018-01"
webhose_wide_sel$month[which(webhose_wide_sel$month=="2018-2")]<-"2018-02"
webhose_wide_sel$month[which(webhose_wide_sel$month=="2018-3")]<-"2018-03"
summary(webhose_wide_sel)

#Merge datasets
all_db<-left_join(twitter_wide_sel,webhose_wide_sel,by=c("country","month"))
all_db<-left_join(all_db,trends_wide_sel,by=c("country","month"))
head(all_db)
str(all_db)

#Calculate monthly rate differences
all_db_diff<-data.frame()
for(i in unique(all_db$country)){
  set<-all_db[which(all_db$country==i),3:68]
  mdiff<-as.data.frame(diff(as.matrix(set)))
  mdiff$country<-i
  all_db_diff<-rbind(all_db_diff,mdiff)
  print(i)
}

#Replace differences by categories
all_db_diff[,1:66] <- lapply(all_db_diff[,1:66], function(x) ifelse(x>0, "Increase",
                                                        ifelse(x<0,"Decrease","No change")))
all_db_diff[,1:66] <- lapply(all_db_diff[,1:66], factor)
all_db_diff$continent<-countrycode(all_db_diff$country, 'iso2c', 'continent')
head(all_db_diff)
str(all_db_diff)

#Clear memory
objs<-ls()
objs<-objs[-2]
objs
rm(list=objs)

#Calculate association rules
names(all_db_diff)
arm_data_ame<-all_db_diff[which(all_db_diff$continent=="America"),c(1:66)]

rules_biodiv_ame <- apriori(arm_data_ame,
                        appearance = list(rhs=c("WH.invasive species=No change")),
                        control = list(verbose=T))
rules_biodiv_ame.sorted <- sort(rules_biodiv_ame, by="lift")
inspect(head(sort(rules_biodiv_ame.sorted), n=10))
