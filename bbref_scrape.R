# scraping and cleaning NL batting table from baseball-refrence
library(rvest)
library(dplyr)
url<-"http://www.baseball-reference.com/leagues/NL/2016-standard-batting.shtml"
css<-"#players_standard_batting.sortable.stats_table"
read_html(url) %>% html_node(css) %>% html_table()->nlbatting.raw
nlbatting.raw %>% mutate(Name=repair_encoding(Name))->nlbatting.raw
names(nlbatting.raw)<-repair_encoding(names(nlbatting.raw))
names(nlbatting.raw)<-make.names(names(nlbatting.raw))
x<-(1:562)%%26
xl<-x>0
nlbatting.cleaner<-nlbatting.raw[xl,]
nlbatting.cleaner<-nlbatting.cleaner[,-1]
nlbatting.cleaner$Age<-as.numeric(nlbatting.cleaner$Age)
nlbatting.cleaner[,4:27]<-sapply(nlbatting.cleaner[,4:27],as.numeric)
nlbatting.cleaner %>% mutate(X1B=H-X2B-X3B-HR,Points=X1B+R+RBI+BB+SB+(2*X2B)+(4*X3B)+(4*HR))->nlbatting.cleaner
nlbatting.cleaner$Name<-gsub('[#*]',"",nlbatting.cleaner$Name)
nlbatting.cleaner$Name<-make.names(nlbatting.cleaner$Name)
fieldUrl<-"http://www.baseball-reference.com/leagues/NL/2016-standard-fielding.shtml"
fieldCss<-"#players_standard_fielding.sortable.stats_table"
read_html("http://www.baseball-reference.com/leagues/NL/2016-standard-fielding.shtml") %>% 
html_node('#players_standard_fielding.sortable.stats_table') %>% html_table()->field











