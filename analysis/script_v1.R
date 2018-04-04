#Clean R memory
rm(list=ls())

#Set working directory
setwd(choose.dir())

#Load relevant packages for data extraction
library(tidyverse)

####Open data files
#Trends
trends_df<-read.csv("TRENDS.csv")
head(trends_df)
str(trends_df)

#Twitter-Baseline
twitter_df<-read.csv("TWITTER-BASELINE.csv")
head(twitter_df)
str(twitter_df)

#Webhose-Baseline
webhose_df<-read.csv("WEBHOSE-BASELINE.csv")
head(webhose_df)

####Sort data for analysis
#Trends
trends_df$country<-as.character(trends_df$country)
trends_wide<-spread(trends_df,country,rate)
trends_wide<-trends_wide[,c(4:251)]
head(trends_wide)

#Twitter
twitter_df$country<-as.character(twitter_df$country)
twitter_df<-twitter_df %>% group_by(country,month) %>% summarize(any=sum(any),baseline=sum(baseline))
twitter_df<-as.data.frame(twitter_df)
twitter_df$perc<-(twitter_df$any/twitter_df$baseline)*100
twitter_df<-twitter_df[,c(1:2,5)]
twitter_df$perc[is.na(twitter_df$perc)]<-0
twitter_wide<-spread(twitter_df,country,perc)
twitter_wide<-twitter_wide[,c(2:249)]
head(twitter_wide)

#webhose
webhose_df$country<-as.character(webhose_df$country)
webhose_df<-webhose_df %>% group_by(country,month) %>% summarize(any=sum(any),baseline=sum(baseline))
webhose_df<-as.data.frame(webhose_df)
webhose_df$perc<-(webhose_df$any/webhose_df$baseline)*100
webhose_df<-webhose_df[,c(1:2,5)]
webhose_df$perc[is.na(webhose_df$perc)]<-0
webhose_wide<-spread(webhose_df,country,perc)
webhose_wide<-webhose_wide[,c(2:212)]
head(webhose_wide)


#Network analysis Trends
library("qgraph")
corMat_trends <- trends_wide %>%
  correlate() %>%
  shave(upper = TRUE) %>%
  stretch(na.rm = TRUE) %>%
  filter(r >= 0.5)

set.seed(1)
cor.graph_trends <- as_tbl_graph(corMat_trends, directed = FALSE)
cor.graph_trends %>%
  activate(nodes) %>%
  mutate(centrality = centrality_authority()) %>% 
  ggraph(layout = "graphopt") + 
  geom_edge_link(width = 1, colour = "lightgray") +
  geom_node_point(aes(size = centrality, colour = centrality)) +
  geom_node_text(aes(label = name), repel = TRUE)+
  scale_color_gradient(low = "yellow", high = "red")+
  theme_graph()


#Network analysis twitter
corMat_twitter <- twitter_wide %>%
  correlate() %>%
  shave(upper = TRUE) %>%
  stretch(na.rm = TRUE) %>%
  filter(r >= 0.5)

set.seed(1)
cor.graph_twitter <- as_tbl_graph(corMat_twitter, directed = FALSE)
cor.graph_twitter %>%
  activate(nodes) %>%
  mutate(centrality = centrality_authority()) %>% 
  ggraph(layout = "graphopt") + 
  geom_edge_link(width = 1, colour = "lightgray") +
  geom_node_point(aes(size = centrality, colour = centrality)) +
  geom_node_text(aes(label = name), repel = TRUE)+
  scale_color_gradient(low = "yellow", high = "red")+
  theme_graph()


#Network analysis webhose
corMat_webhose <- webhose_wide %>%
  correlate() %>%
  shave(upper = TRUE) %>%
  stretch(na.rm = TRUE) %>%
  filter(r >= 0.5)

set.seed(1)
cor.graph_webhose <- as_tbl_graph(corMat_webhose, directed = FALSE)
cor.graph_webhose %>%
  activate(nodes) %>%
  mutate(centrality = centrality_authority()) %>% 
  ggraph(layout = "graphopt") + 
  geom_edge_link(width = 1, colour = "lightgray") +
  geom_node_point(aes(size = centrality, colour = centrality)) +
  geom_node_text(aes(label = name), repel = TRUE)+
  scale_color_gradient(low = "yellow", high = "red")+
  theme_graph()
