#########################################################################
#    File_name: exploratory_data_analysis_v2.R
#    Version: R version 3.2.4 (2016-03-10)
#    Date: 03_18_2017
#    Author: amp5
#    Purpose: exploratory analysis after party added
#    Input_files: e_twts_w_affiliation.Rda, e_twts_w_party.Rda
#    Output_files: e_party_coords.csv, all_party_ref.pdf
#    Previous_files: add_party.R
#    Required by: TBD 
#    Status: Complete
#    Machine: OSX Yosemite v. 10.10.5 (laptop)
#########################################################################
library(tidyverse)
library(stringr)
library(lubridate)



# Setting path and loading files ------------------------------------------
path <- "/Users/alexandraplassaras/Desktop/Spring_2017/QMSS_Thesis/QMSS_thesis" 
setwd(path)

# load e_twts_w_affiliation.Rda, var name is 'w_affil'
load(file.choose())
# load e_twts_w_party.Rda, var name is 'only_party'
load(file.choose())


# Code --------------------------------------------------------------------

# save all e tweets with new var -> EDA show many tweets are dem, rep and other in bar chart
all <- subset(w_affil, select = c(X, republican, democrat, other))

(repub <- c(nrow(filter(all, all$republican == 1))))
(demo <- c(nrow(filter(all, all$democrat == 1))))
(other <- c(nrow(filter(all, all$other == 1))))

party <- c("republican", "democrat", "other")
counts <- c(repub, demo, other)

by_party <- as_tibble(data.frame(party, counts))

(total_w_affil <- nrow(all))

ggplot(data=by_party, aes(x = reorder(party,counts), y= counts / total_w_affil)) +
  geom_bar(stat="identity") +
  theme_minimal() +
  ggtitle("Emoji Tweets by Party Reference") +
  labs(x = "Party Reference", y = "Percent (%)")
ggsave("reports/figures/all_party_ref.pdf")


# save only e_party tweets -> show distribution of e_twts by party - location wise 
wrk_d <- subset(only_party, select = c(X, republican, democrat, place_lat, place_lon))



# twt_location <- as_tibble(table(factor(format(c(wrk_d$place_lat)))))
# names(twt_location) <- c("place_lat", "num")
# Easier to use QGIS for this   

# Output ------------------------------------------------------------------
write.csv(wrk_d, "data/interim/e_party_coords.csv")



