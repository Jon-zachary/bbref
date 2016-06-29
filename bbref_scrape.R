# scraping and cleaning NL batting table from baseball-refrence
library(rvest)
library(dplyr)

## Get batting and fielding tables 

url<-"http://www.baseball-reference.com/leagues/NL/2016-standard-batting.shtml"
css<-"#players_standard_batting.sortable.stats_table"
fieldUrl<-"http://www.baseball-reference.com/leagues/NL/2016-standard-fielding.shtml"
fieldCss<-"#players_standard_fielding.sortable.stats_table"
read_html(fieldUrl) %>% html_node(fieldCss) %>% html_table()->field
read_html(url) %>% html_node(css) %>% html_table()->bat

## Fix encoding issues and make the col names r friendly

Encoding(names(bat))<-"UTF-8"
Encoding(names(field))<-"UTF-8"
names(bat)<-make.names(names(bat))
names(field)<-make.names(names(field))
bat$Name<-repair_encoding(bat$Name)
field$Name<-repair_encoding(field$Name)
bat$Name<-gsub('[#*]',"",bat$Name)
bat$Name<-make.names(bat$Name)
field$Name<-make.names(field$Name)
bat$Name<-gsub('[.]'," ",bat$Name)
field$Name<-gsub('[.]'," ",field$Name)
## Filter out redundant headers
bat %>% filter(!(Name=="Name"))->bat
field %>% filter(!(Name=="Name"))->field
bat %>% select(-1)->bat
field %>% select(-1)->field
## Use only the row of total stats for hitters with multiple teams and filter out players that have not taken the field
bat %>% group_by(Name) %>% filter(G==max(G))->bat
scrubs<-setdiff(bat$Name,field$Name)[1:2]
bat %>% filter(!(Name==scrubs[1]|Name==scrubs[2]))->bat
bat<-ungroup(bat)
## Convert the numeric cols from char to num
bat$Age<-as.numeric(bat$Age)
bat[,4:27]<-sapply(bat[,4:27],as.numeric)
## Add Errors from field and create points column
bat %>% mutate(E=as.numeric(field$E))->bat
bat %>% mutate(X1B=H-X2B-X3B-HR,Points=X1B+R+RBI+BB+SB+(2*X2B)+(4*X3B)+(4*HR)-E)->bat
## add the position summary from the fielding data, really weird behavior, breaks if i don't have an empty select
bat$Position<-field$Pos.Summary
## remove pitchers
bat %>% filter(!(Position == "P"))->bat
###### download and clean starting pitching tables
pitchCSS<-"#players_starter_pitching.sortable.stats_table"
pitchURL<-"http://www.baseball-reference.com/leagues/NL/2016-starter-pitching.shtml"
read_html(pitchURL) %>% html_node(pitchCSS) %>% html_table()->pitch
Encoding(pitch$Name)<-'UTF-8'
pitch$Name<-make.names(pitch$Name)
pitch$Name<-gsub('[.]'," ",pitch$Name)












