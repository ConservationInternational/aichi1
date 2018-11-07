#Load relevant packages for data extraction
library(tidyverse)
library(countrycode)
library(geojsonio)
library(viridis)
library(ggplot2)
library(cowplot)

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
all_df$mean_rvol <- (all_df$mean_rvol_tr + all_df$mean_rvol_tw + all_df$mean_rvol_wh)/3
all_sum <- all_df[ , c("country", "issue", "mean_rvol")]

#Convert database from wide to long format
all_sum_wide <- spread(all_sum,issue,mean_rvol)

#Summary by country
all_mean_ctr <- data.frame(country=all_sum_wide[,1],
                           mean_rvol=apply(all_sum_wide[,2:23],1,mean))

all_mean_ctr_adj <- all_mean_ctr
all_mean_ctr_adj[all_mean_ctr_adj < 0.15] <- 0.15151515

sp <- geojson_read('G:/My Drive/CI Docs/Aichi 1 Indicator/WorldMaps/gadm28_adm0_low.json', what="sp")

sp <- sp[sp$NAME_ENGLI != "Antarctica", ]

fort <- fortify(sp)

dat <- cbind(fort, sp@data[fort$id, ])

dat$orig_order <- 1:nrow(dat)

dat <- merge(dat, all_mean_ctr_adj, by.x="ISO2", by.y="country", all.x=T, all.y=F)

dat <- dat[order(dat$orig_order), ]

names(dat)[names(dat) == 'mean_rvol'] <- "Overall Score"

ggplot(dat, aes(long, lat, group=group)) + 
  geom_polygon(aes(fill=`Overall Score`), color="black") + 
  scale_fill_viridis(name="Overall Score", na.value="grey", 
                     guide=guide_colorbar(title.position="top", title.hjust = 0.5)) +
  scale_x_continuous(expand = c(0.0,0)) +
  scale_y_continuous(expand = c(0.0,0))  + 
  labs(fill = 'Overall Score') + 
  theme(axis.line=element_blank(),axis.text.x=element_blank(),
        axis.text.y=element_blank(),axis.ticks=element_blank(),
        axis.title.x=element_blank(),
        axis.title.y=element_blank(),
        panel.border=element_blank(),panel.grid.major=element_blank(),
        panel.grid.minor=element_blank(),plot.background=element_blank(),
        panel.background=element_rect(fill="#FFFFFF"))
ggsave('C://Git/aichi1/analysis/Figure 5 - Indicator over Space.png', height=3, width=8)

##Just plot climate change
cc <- all_df %>%
  filter(issue == 'climate change')

dat_cc <- cbind(fort, sp@data[fort$id, ])

dat_cc$orig_order <- 1:nrow(dat_cc)

dat_cc <- merge(dat_cc, cc, by.x="ISO2", by.y="country", all.x=T, all.y=F)

dat_cc <- dat_cc[order(dat_cc$orig_order), ]

names(dat_cc)[names(dat_cc) == 'mean_rvol'] <- "Overall Score"

clim <- ggplot(dat_cc, aes(long, lat, group=group)) + 
  geom_polygon(aes(fill=log(`Overall Score`)), color="black") + 
  scale_fill_viridis(name="Climate Change", na.value="grey", 
                     labels=function(x) signif(exp(x), 2),
                     guide=guide_colorbar(title.position="top", title.hjust = 0.5)#,
                     #low = "#132B43", high = "#56B1F7"
                     ) +
  scale_x_continuous(expand = c(0.0,0)) +
  scale_y_continuous(expand = c(0.0,0))  + 
  labs(fill = 'Overall Score') + 
  theme(axis.line=element_blank(),axis.text.x=element_blank(),
        axis.text.y=element_blank(),axis.ticks=element_blank(),
        axis.title.x=element_blank(),
        axis.title.y=element_blank(),
        panel.border=element_blank(),panel.grid.major=element_blank(),
        panel.grid.minor=element_blank(),plot.background=element_blank(),
        panel.background=element_rect(fill="#FFFFFF"),
        legend.position="bottom",
        legend.justification="center",
        legend.key.width=unit(2,"cm"))

##Just plot endangered species
endangeredspecies <- all_df %>%
  filter(issue == 'endangered species')

dat_end <- cbind(fort, sp@data[fort$id, ])

dat_end$orig_order <- 1:nrow(dat_end)

dat_end <- merge(dat_end, endangeredspecies, by.x="ISO2", by.y="country", all.x=T, all.y=F)

dat_end <- dat_end[order(dat_end$orig_order), ]

names(dat_end)[names(dat_end) == 'mean_rvol'] <- "Overall Score"

endang <- ggplot(dat_end, aes(long, lat, group=group)) + 
  geom_polygon(aes(fill=log(`Overall Score`)), color="black") + 
  scale_fill_viridis(name="Endangered Species", na.value="grey", 
                     labels=function(x) signif(exp(x), 2),
                     guide=guide_colorbar(title.position="top", title.hjust = 0.5)#,
                     #low = "#132B43", high = "#56B1F7"
                     ) +
  scale_x_continuous(expand = c(0.0,0)) +
  scale_y_continuous(expand = c(0.0,0))  + 
  labs(fill = 'Overall Score') + 
  theme(axis.line=element_blank(),axis.text.x=element_blank(),
        axis.text.y=element_blank(),axis.ticks=element_blank(),
        axis.title.x=element_blank(),
        axis.title.y=element_blank(),
        panel.border=element_blank(),panel.grid.major=element_blank(),
        panel.grid.minor=element_blank(),plot.background=element_blank(),
        panel.background=element_rect(fill="#FFFFFF"),
        legend.position="bottom",
        legend.justification="center",
        legend.key.width=unit(2,"cm"))

plot_grid(clim, endang, labels="AUTO")

ggsave('C://Git/aichi1/analysis/Figure 6 - Keywords Over Space.png', height=5, width=20)
