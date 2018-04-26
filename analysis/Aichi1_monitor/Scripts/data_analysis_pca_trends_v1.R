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

####Open data files
#Trends
trends_df<-read.csv("Data/TRENDS.csv")
head(trends_df)
str(trends_df)

#Summarize data for the sampling period
trends_df_sum<-trends_df %>% group_by(country,issue) %>% summarise(rate = mean(rate))
#Convert contry names to character
trends_df_sum$country<-as.character(trends_df_sum$country)
#Convert database from wide to long format
trends_sum_wide<-spread(trends_df_sum,issue,rate)
#Remove unecessary columns
trends_sum_wide<-trends_sum_wide[c(2:249),]
#remove countries where search interest never peaked above 25 - this removes coutnries with few data
trends_sum_wide<-trends_sum_wide[apply(trends_sum_wide[,2:23],1,function(x) any(x>10)),]
head(trends_sum_wide)

#Associate countries with continents and create a data frame with that information
unique_ctr_sum<-trends_sum_wide$country
country_data_sum<-data.frame(ctr_names_iso2=unique_ctr_sum,
                             ctr_names_full=countrycode(unique_ctr_sum, 'iso2c', 'country.name'),
                             continent=countrycode(unique_ctr_sum, 'iso2c', 'continent'),
                             stringsAsFactors=F)
country_data_sum$continent<-as.factor(country_data_sum$continent)

#Calculate PCA
res.pca <- prcomp(trends_sum_wide[,c(2:23)], scale = TRUE)
rownames(res.pca$x)<-unique_ctr_sum
cols<-brewer.pal(5, "Spectral")
#Country plot
ctr.plot<-fviz_pca_ind(res.pca, 
             geom.ind = c("point","text"),
             pointshape = 21,
             pointsize = "cos2",
             fill.ind = country_data_sum$continent,col.ind="black",invisible = "quali",
             legend.title = list(fill = "Continent", size = "Representation"),
             repel = TRUE)+
          ggpubr::fill_palette("Spectral")+
          theme(legend.position = "bottom")+
          guides(fill = guide_legend(override.aes = list(size = 5)))
ctr.plot<-ggpar(ctr.plot,
                title = "Principal Component Analysis - Google Trends country data",
                xlab = "PC1 (26.6%)", ylab = "PC2 (12.2%)")
ctr.plot

#Variable plot
var.plot<-fviz_pca_var(res.pca, col.var = "cos2",
                       gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
                       legend.title = "Contribution",repel=T,labelsize = 4)+
          theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
                panel.background = element_rect(fill="white"))
var.plot<-ggpar(var.plot,
                title = "Variable contribution",
                xlab = "PC1 (26.6%)", ylab = "PC2 (12.2%)")
var.plot

#Build multipart figure
figure <- ggdraw() +
  draw_plot(ctr.plot, x = 0, y = 0, width = .82, height = 1) +
  draw_plot(var.plot, x = .5, y = .35, width = 0.6, height = 0.65)
figure

#Save plot
ggsave("Figure1.tiff",figure,scale=1.2,width=25,height=12,units="cm",dpi=300)


pc1 <- res.pca$x[ , 1 ]
pc2 <- res.pca$x[ , 2 ]

pc1[order(pc1)]
pc2[order(pc2)]
