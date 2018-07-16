#Load relevant packages for data extraction
library(tidyverse)
library(countrycode)
library(RColorBrewer)
library(factoextra)
library(ggplot2)
library(tidygraph)
library(ggraph)
library(ggpubr)
library(cowplot)
library(ggcorrplot)
library(ggrepel)
library(GGally)

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

#remove countries where search interest never peaked above 5 - this removes coutnries with few data
all_sum_wide_filt <- all_sum_wide[apply(all_sum_wide[,2:23],1,function(x) any(x>5)),]

#Associate countries with continents and create a data frame with that information
unique_ctr_sum <- countrycode(all_sum_wide_filt$country, 'iso2c', 'country.name')
country_data_sum <- data.frame(ctr_names_iso2=unique_ctr_sum,
                               ctr_names_full=countrycode(unique_ctr_sum, 'country.name', 'iso2c'),
                               continent=countrycode(unique_ctr_sum, 'country.name', 'continent'),
                               stringsAsFactors=F)
country_data_sum$continent <- as.factor(country_data_sum$continent)

labelcountries <- c('Mexico', 'Ecuador', 'New Zealand', 'Kazakhstan', 'Kyrgyzstan', 'Bolivia', 'Guatemala',
                    'Dominican Republic', 'Bolivia', 'Peru', 'Colombia', 'Ethiopia', 'Kenya', 'Tanzania', 'Ghana', 
                    'Uganda', 'Fiji', 'United States', 'Canada', 'Australia', 'Honduras', 'El Salvador', 'Panama',
                    'Philippines', 'Nepal', "Austria", "Lebanon", "Mauritania", 
                    'Venezuela', 'Russia', 'South Africa', 'Zimbabwe')

unique_ctr_sum[!unique_ctr_sum %in% labelcountries] <- ''

#Calculate PCA
res.pca <- prcomp(all_sum_wide_filt[,c(2:23)], scale = TRUE)
rownames(res.pca$x)<-all_sum_wide_filt$country
cols<-brewer.pal(5, "Spectral")


labeldf <- data.frame(res.pca$x)
labeldf$lab <- unique_ctr_sum

#Country plot
ctr.plot<-fviz_pca_ind(res.pca,
                       geom.ind = c("point"),
                       pointshape = 21,
                       pointsize = "cos2",
                       fill.ind = country_data_sum$continent,col.ind="black",invisible = "quali",
                       legend.title = list(fill = "Continent", size = "Representation"),repel=T)+
  ggpubr::fill_palette("Spectral")+
  scale_x_reverse()+
  geom_text_repel(data=labeldf, aes(x=PC1, y=PC2, label=lab), show.legend=F, size=4,
                  inherit.aes=FALSE, point.padding = 0.5)+
  theme(legend.position = "bottom")+
  guides(fill = guide_legend(override.aes = list(size = 5)))

pc1 <- round(summary(res.pca)$importance["Proportion of Variance", "PC1"]*100, digits=1)
pc2 <- round(summary(res.pca)$importance["Proportion of Variance", "PC2"]*100, digits=1)

ctr.plot<-ggpar(ctr.plot,
                title = "",
                xlab = paste0("Principal Conponent 1 (", pc1, "%)"), ylab = paste0("Principal Component 2 (", pc2, "%)"))
ctr.plot

ggsave("C://Git/aichi1/analysis/Figure 6 - PCA.tiff", ctr.plot, scale=1.5,width=18.75,height=9,units="cm",dpi=300)

#Variable plot
var.plot<-fviz_pca_var(res.pca, col.var = "cos2",
                       gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
                       legend.title = "Contribution",repel=T,labelsize = 4) +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_rect(fill="white"))+
  scale_x_reverse()
var.plot<-ggpar(var.plot,
                title = "Variable contribution",
                xlab = "", ylab = "")
var.plot

#Save
ggsave("C://Git/aichi1/analysis/Appendix 3.tiff", var.plot, scale=1.5, width=10,height=10,units="cm",dpi=300)
