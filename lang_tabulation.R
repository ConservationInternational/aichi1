library(dplyr)

setwd('D://Documents and Settings/mcooper/GitHub/aichi1/')

csv <- read.csv('langcounts.csv', header=F)

getAfterDash <- function(str){
  dash <- gregexpr('-', str)[[1]][1]
  space <- gregexpr(' ', str)[[1]][1]
  substr(str, dash + 1, space - 1)
}

getAfterSpace <- function(str){
  space <- gregexpr(' ', str)[[1]][1]
  substr(str, space + 1, nchar(str))
}

getBeforeDash <- function(str){
  dash <- gregexpr('-', str)[[1]][1]
  substr(str, 1, dash-1)
}

csv$lang <- sapply(csv$V1, getAfterDash)
csv$count <- sapply(csv$V1, getAfterSpace)
csv$country <- sapply(csv$V1, getBeforeDash)

langtab <- csv %>% 
  group_by(lang) %>%
  summarize(count = sum(as.integer(count))) %>%
  arrange(desc(count))

write.csv(langtab, 'lang_tabulation.csv', row.names=F)

countrytab <- csv %>%
  filter((!lang %in% c('und', 'null')) & (!country %in% c('', 'xx'))) %>%
  filter(count > 100) %>%
  group_by(lang) %>%
  summarize(count=n()) %>%
  arrange(desc(count))











