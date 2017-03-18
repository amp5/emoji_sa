#########################################################################
#    File_name: refine_dataset.R
#    Version: R version 3.2.4 (2016-03-10)
#    Date: 02_08_2017
#    Author: amp5
#    Purpose: Data set currently has 50 vairables. Extracting only necessary
#             variables for my analysis + geolocation data. 
#             -  convert as tbl -> as_tibble()
#             -  mutate to only have date not date-time -> as_date()
#             -  remove non-necessary cols
#             -  confirm cooridinates
#    Input_files: de_identified_raw.csv
#    Output_files: filtered.csv
#    Previous_files: extract_id_username_keys.R
#    Required by: extract_emoji_tw.R
#    Status: Completed
#    Machine: OSX Yosemite v. 10.10.5 (laptop)
#########################################################################
library(tidyverse)
library(rworldmap)
library(lubridate)
library(stringr)
library(maps)

# Setting path and loading files ------------------------------------------
path <- "/Users/alexandraplassaras/Desktop/Spring_2017/QMSS_Thesis/QMSS_thesis" 
setwd(path)

# choose de_identified_raw.csv
d <- read.csv(file.choose())

# Code --------------------------------------------------------------------
d <- as_tibble(d)

# no retweeted
d %>%
  count(country) 

# different languages
languages <- d %>%
  count(lang) 
# 45 different languages in lang col identified
# test to see if text is in french
french <- filter(d, lang == 'fr')

# converting date-time string to date string
d_date <-  d %>%
  separate( created_at, c("d_o_w", "mon", "day", "time", "milsec", "year"), sep = " ") %>%
  mutate(month = match(mon, month.abb)) %>%
  mutate(created = str_c(month, day, year, sep = "/")) %>%
  mutate(date = mdy(created))




# removing non-essential cols -> makes processing easier to compute and read

# created - date for tweet sent
# text - tweet
# user_id - unique id for a user - in lieu of screenname
# lang - should keep since the lang identified is not best way to tell if text is en or not
# id_str - unique tweet id (maybe helpful)
# verified - maybe useful to see what sentiments come from verified versus unverified
# place_lon, place_lat, lat, lon, X and Y for coordinates


tw_d <- subset(d_date, select = c(user_id, id_str, created, text,
                                  lang, verified, place_lat, place_lon,
                                  lon, lat, X, Y ))


# X and Y are coordinates and no cells contain NAs
any(is.na(tw_d$X))
any(is.na(tw_d$Y))

# place_lat and place_lon also have no NAs
any(is.na(tw_d$place_lat))
any(is.na(tw_d$place_lon))

# lat and lon do have NAs. Will not use this col
any(is.na(tw_d$lat))
any(is.na(tw_d$lon))

# some X and Y coords match with place_lat and _lon but not all
any(tw_d$Y == tw_d$place_lat)
all(tw_d$Y == tw_d$place_lat)

any(tw_d$X == tw_d$place_lon)
all(tw_d$X == tw_d$place_lon)

# new dataframe without unecessary cols
wrk_d <- subset(tw_d, select = c(user_id, id_str, created, text,
                                 lang, verified, place_lat, place_lon ))


ts <- data.frame(x = as.numeric(wrk_d$place_lon), y = as.numeric(wrk_d$place_lat))
#points <- points[points$y > 25, ]

## plot out the usage on world map
map("world", col="#E8E8E8", fill=TRUE, bg="white", lwd=0.4, interior=TRUE)
points(ts, pch=16, cex=.10, col="red")
# appears that few tweets are in Europe and Guam(?) with X, Y or place_lat, place_lon

# plot out the usage on US map
xlim <- c(-124.738281, -66.601563)
ylim <- c(24.039321, 50.856229)
map("world", col="#E8E8E8", fill=TRUE, bg="white", lwd=0.4, xlim=xlim, ylim=ylim, interior=TRUE)
points(ts, pch=16, cex=.10, col="red")
map("state", fill=FALSE, bg="white", add = TRUE)

# Creating outputs -------------------------------------------------------
write.csv(wrk_d, "data/interim/filtered.csv")


