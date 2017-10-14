setwd('D://Documents and Settings/mcooper/GitHub/aichi1/scrape_wikipedia/')

top <- read.csv('scrape_results.csv')

top$relsize <- top$size/max(top$size, na.rm=T)
top$relview <- top$view/max(top$views, na.rm=T)

top$score <- rowSums(top[ , c('relsize', 'relview')], na.rm=T)

top <- arrange(top, desc(score))

write.csv(top[1:1100, 'species'], 'rank_species.csv', row.names=F)
