#Load relevant packages for data extraction
library(tidyverse)
library(ggplot2)
library(tidygraph)
library(ggraph)
library(countrycode)
library(RColorBrewer)
library(factoextra)
library(ggpubr)
library(cowplot)
library(ggcorrplot)
library(ggrepel)
library(rworldmap)
library(maptools)
library(viridis)
library(GGally)
library(geojsonio)

setwd('D://Documents and Settings/mcooper/Github/aichi1/analysis/Aichi1_monitor2/')

####Open data files
#Trends
trends_df<-read.csv("Data_Apr/TRENDS.csv",stringsAsFactors = F)
unique(trends_df$issue)
trends_df$country[is.na(trends_df$country)]<-"NA"
unique(trends_df$country)
trends_df<-subset(trends_df,trends_df$month!="2018-05")
unique(trends_df$month)
head(trends_df)
str(trends_df)

#Twitter
twitter_df<-read.csv("Data_Apr/TWITTER-ALL.csv",stringsAsFactors = F)
twitter_df<-twitter_df[twitter_df$issue %in% trends_df$issue,]
unique(twitter_df$issue)
twitter_df$country[is.na(twitter_df$country)]<-"NA"
unique(twitter_df$country)
twitter_df<-subset(twitter_df,twitter_df$month!="2018-05")
unique(twitter_df$month)
head(twitter_df)
str(twitter_df)

#Webhose
webhose_df<-read.csv("Data_Apr/WEBHOSE-ALL.csv",stringsAsFactors = F)
webhose_df<-webhose_df[webhose_df$issue %in% trends_df$issue,]
unique(webhose_df$issue)
webhose_df$country[is.na(webhose_df$country)]<-"NA"
unique(webhose_df$country)
webhose_df<-subset(webhose_df,webhose_df$month!="2018-5")
unique(webhose_df$month)
head(webhose_df)
str(webhose_df)

#Filter countries
trends_df<-trends_df[trends_df$country %in% webhose_df$country,]
twitter_df<-twitter_df[twitter_df$country %in% webhose_df$country,]
#Identify max rate per issue
twitter_df_maxrate<-as.data.frame(twitter_df %>% group_by(issue) %>% summarise(top = max(rate)))
twitter_df_maxrate1000<-as.data.frame(subset(twitter_df,twitter_df$baseline>=500) %>% group_by(issue) %>% summarise(top = max(rate)))
webhose_df_maxrate<-as.data.frame(webhose_df %>% group_by(issue) %>% summarise(top = max(rate)))
webhose_df_maxrate1000<-as.data.frame(subset(webhose_df,webhose_df$baseline>=500) %>% group_by(issue) %>% summarise(top = max(rate)))
#Merge datasets and scale
twitter_merge<-left_join(twitter_df,twitter_df_maxrate1000,by=("issue"))
twitter_merge$rvol<-(twitter_merge$rate*100)/twitter_merge$top
twitter_merge$rvol[which(twitter_merge$rvol>100)]<-100
twitter_sum<-as.data.frame(twitter_merge %>% group_by(country,issue) %>% summarise(mean_rvol_tw = mean(rvol)))

webhose_merge<-left_join(webhose_df,webhose_df_maxrate1000,by=("issue"))
webhose_merge$rvol<-(webhose_merge$rate*100)/webhose_merge$top
webhose_merge$rvol[which(webhose_merge$rvol>100)]<-100
webhose_sum<-as.data.frame(webhose_merge %>% group_by(country,issue) %>% summarise(mean_rvol_wh = mean(rvol)))

trends_sum<-as.data.frame(trends_df %>% group_by(country,issue) %>% summarise(mean_rvol_tr = mean(rate)))

all_df<-left_join(trends_sum,twitter_sum,by=c("country","issue"))
all_df<-left_join(all_df,webhose_sum,by=c("country","issue"))
head(all_df)
all_df$mean_rvol<-(all_df$mean_rvol_tr+all_df$mean_rvol_tw+all_df$mean_rvol_wh)/3
all_sum<-all_df[,c(1,2,6)]

#Convert database from wide to long format
all_sum_wide<-spread(all_sum,issue,mean_rvol)
#remove countries where search interest never peaked above 5 - this removes coutnries with few data
all_sum_wide_filt<-all_sum_wide[apply(all_sum_wide[,2:23],1,function(x) any(x>5)),]
head(all_sum_wide)



#Associate countries with continents and create a data frame with that information
unique_ctr_sum<-all_sum_wide_filt$country
country_data_sum<-data.frame(ctr_names_iso2=unique_ctr_sum,
                             ctr_names_full=countrycode(unique_ctr_sum, 'iso2c', 'country.name'),
                             continent=countrycode(unique_ctr_sum, 'iso2c', 'continent'),
                             stringsAsFactors=F)
country_data_sum$continent<-as.factor(country_data_sum$continent)

#Calculate PCA
res.pca <- prcomp(all_sum_wide_filt[,c(2:23)], scale = TRUE)
rownames(res.pca$x)<-unique_ctr_sum
cols<-brewer.pal(5, "Spectral")
#Country plot
ctr.plot<-fviz_pca_ind(res.pca,
             geom.ind = c("point"),
             pointshape = 21,
             pointsize = "cos2",
             fill.ind = country_data_sum$continent,col.ind="black",invisible = "quali",
             legend.title = list(fill = "Continent", size = "Representation"),repel=T)+
          ggpubr::fill_palette("Spectral")+
          scale_x_reverse()+
          geom_text_repel(aes(label=name),hjust=0, vjust=0, show.legend=F, size=4)+
          theme(legend.position = "bottom")+
          guides(fill = guide_legend(override.aes = list(size = 5)))
ctr.plot<-ggpar(ctr.plot,
                title = "Principal Component Analysis",
                xlab = "PC1 (26%)", ylab = "PC2 (13.5%)")
ctr.plot

#Variable plot
var.plot<-fviz_pca_var(res.pca, col.var = "cos2",
                       gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
                       legend.title = "Contribution",repel=T,labelsize = 4)+
          theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
                panel.background = element_rect(fill="white"))+
          scale_x_reverse()
var.plot<-ggpar(var.plot,
                title = "Variable contribution",
                xlab = "", ylab = "")
var.plot

#Build multipart figure
figure <- ggdraw() +
  draw_plot(ctr.plot, x = 0, y = 0, width = .92, height = 1) +
  draw_plot(var.plot, x = .55, y = .32, width = 0.55, height = 0.55)
figure

#Save plot
ggsave("Figure1.tiff",figure,scale=1.5,width=25,height=12,units="cm",dpi=300)


#####Test Plots
#Summary by country
all_mean_ctr<-data.frame(country=all_sum_wide[,1],
                         `Overall Score`=apply(all_sum_wide[,2:23],1,function(x) mean(x)))

#Plot world map
sp <- geojson_read('G:/My Drive/CI Docs/Aichi 1 Indicator/WorldMaps/gadm28_adm0_low.json', what="sp")
sp <- sp[sp$NAME_ENGLI != "Antarctica", ]


fort <- fortify(sp)
dat <- cbind(fort, sp@data[fort$id, ])
dat$roworder <- row.names(dat)
all_mean_ctr <- rbind(all_mean_ctr, data.frame(country=setdiff(dat$ISO2, all_mean_ctr$country),
                                               Overall.Score=NA))

dat <- merge(dat, all_mean_ctr, by.x="ISO2", by.y="country", all.x=T, all.y=F)

pal = brewer.pal(3, "RdYlGn")

ggplot(dat, aes(long, lat, group=group)) + 
  geom_polygon(aes(fill=Overall.Score), color="black", size=0.25) +
  scale_fill_viridis(name="Overall Score", na.value="grey25") + 
  labs(fill = 'Overall Score', x="", y="") + 
  scale_x_continuous(expand = c(0.0,0)) +
  theme(plot.background = element_rect(fill = "transparent", colour = NA),
        panel.border = element_blank(),
        panel.background = element_rect(fill = "grey80", color = "black"),
        panel.grid = element_blank(),
        axis.text = element_blank(),
        axis.ticks = element_blank(),
        axis.line=element_blank())

ggsave("Figure2v2.tiff",width=8,height=3)

#Plot by country
trends_sum_wide<-spread(trends_sum,issue,mean_rvol_tr)
twitter_sum_wide<-spread(twitter_sum,issue,mean_rvol_tw)
webhose_sum_wide<-spread(webhose_sum,issue,mean_rvol_wh)

var_mean_ctr<-data.frame(country=trends_sum_wide[,1],
                         ctr_fips=countrycode(all_sum_wide[,1], 'iso2c', 'fips'),
                         mean_tr_vol=apply(trends_sum_wide[,2:23],1,function(x) log10(mean(x)+1)),
                         mean_tw_vol=apply(twitter_sum_wide[,2:23],1,function(x) log10(mean(x)+1)),
                         mean_wh_vol=apply(webhose_sum_wide[,2:23],1,function(x) log10(mean(x)+1)))

var_mean_ctr_filt<-var_mean_ctr[apply(var_mean_ctr[,3:5],1,function(x) all(x>0)),]
head(var_mean_ctr_filt)

#Corr plot
library(psych)
pairs.panels(select(var_mean_ctr_filt, Newspapers=mean_wh_vol, Twitter=mean_tw_vol, `Google Trends`=mean_tr_vol),
             smooth = FALSE, ellipses = FALSE, method="pearson", rug=FALSE, 
             hist.col = '#888888', xaxt = "n", yaxt = "n")

#Plot by issue
var_mean_issue<-data.frame(issue=names(trends_sum_wide[,2:23]),
                           mean_tr_vol=apply(trends_sum_wide[,2:23],2,function(x) log10(mean(x)+1)),
                           mean_tw_vol=apply(twitter_sum_wide[,2:23],2,function(x) log10(mean(x)+1)),
                           mean_wh_vol=apply(webhose_sum_wide[,2:23],2,function(x) log10(mean(x)+1)))


all <- select(var_mean_ctr_filt, Newspapers=mean_wh_vol, Twitter=mean_tw_vol, `Google Trends`=mean_tr_vol, country) %>%
  arrange(desc(Twitter)) %>%
  mutate(Twitter_Rank = 1:n()) %>%
  arrange(desc(Newspapers)) %>%
  mutate(Newspapers_Rank = 1:n()) %>%
  arrange(desc(`Google Trends`)) %>%
  mutate(Trends_Rank = 1:n())

all$Top15 <- rowSums(all[ , c("Twitter_Rank", "Newspapers_Rank", "Trends_Rank")] <= 15) >= 2

View(all)


#Corr plot
pairs.panels(select(var_mean_issue, Newspapers=mean_wh_vol, Twitter=mean_tw_vol, `Google Trends`=mean_tr_vol),
             smooth = FALSE, ellipses = FALSE, method="pearson", rug=FALSE, 
             hist.col = '#888888', xaxt = "n", yaxt = "n")

ggsave("Figure4.tiff",figure4,scale=2,width=10,height=8,units="cm",dpi=300)


####Test PCA
names(trends_sum_wide)<-paste0(names(trends_sum_wide),"_tr")
names(twitter_sum_wide)<-paste0(names(twitter_sum_wide),"_tw")
names(webhose_sum_wide)<-paste0(names(webhose_sum_wide),"_wh")
test_df<-cbind(trends_sum_wide,twitter_sum_wide[,2:23],webhose_sum_wide[,2:23])
names(test_df)
#remove countries where search interest never peaked above 5 - this removes coutnries with few data
test_df<-test_df[apply(test_df[,2:67],1,function(x) any(x>5)),]
head(test_df)



#Associate countries with continents and create a data frame with that information
unique_ctr_sum.2<-test_df$country
country_data_sum.2<-data.frame(ctr_names_iso2=unique_ctr_sum.2,
                             ctr_names_full=countrycode(unique_ctr_sum.2, 'iso2c', 'country.name'),
                             continent=countrycode(unique_ctr_sum.2, 'iso2c', 'continent'),
                             stringsAsFactors=F)
country_data_sum.2$continent<-as.factor(country_data_sum.2$continent)


#Calculate PCA
res.pca.2 <- prcomp(test_df[,c(2:67)], scale = TRUE)
rownames(res.pca.2$x)<-unique_ctr_sum.2
cols<-brewer.pal(5, "Spectral")
#Country plot
ctr.plot<-fviz_pca_ind(res.pca.2, 
                       geom.ind = c("point"),
                       pointshape = 21,
                       pointsize = "cos2",
                       fill.ind = country_data_sum.2$continent,col.ind="black",invisible = "quali",
                       legend.title = list(fill = "Continent", size = "Representation"))+
  ggpubr::fill_palette("Spectral")+
  geom_text(aes(label=name),hjust=0, vjust=0, show.legend=F, check_overlap=T,size=3.5)+
  theme(legend.position = "bottom")+
  guides(fill = guide_legend(override.aes = list(size = 5)))
ctr.plot<-ggpar(ctr.plot,
                title = "Principal Component Analysis",
                xlab = "PC1 (26%)", ylab = "PC2 (13.5%)")
ctr.plot

#Variable plot
var.plot<-fviz_pca_var(res.pca.2, col.var = "cos2",
                       gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
                       legend.title = "Contribution",repel=T,labelsize = 4)+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_rect(fill="white"))
var.plot<-ggpar(var.plot,
                title = "Variable contribution",
                xlab = "", ylab = "")
var.plot

#Build multipart figure
figure <- ggdraw() +
  draw_plot(ctr.plot, x = 0, y = 0, width = .92, height = 1) +
  draw_plot(var.plot, x = .51, y = .22, width = 0.6, height = 0.6)
figure

#Save plot
ggsave("Figure1_test.tiff",figure,scale=1.4,width=25,height=12,units="cm",dpi=300)
