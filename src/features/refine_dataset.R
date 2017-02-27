#########################################################################
#    File_name: refine_dataset.R
#    Version: R version 3.2.4 (2016-03-10)
#    Date: 02_08_2017
#    Author: amp5
#    Purpose: Data set currently has 50 vairables. Extracting only necessary
#             variables for my analysis + geolocation data. Next step after 
#             this will be to confirm tweets sent in US and to save latitude
#             and longitude data from 8 variable vars. 
#    Input_files: de_identified_raw.csv
#    Output_files: targeted_data.csv, non_USfiltered.csv
#    Previous_files: N/A
#    Status: Working on
#    Machine: OSX Yosemite v. 10.10.5 (laptop)
#########################################################################

# instead of reloading input files, working with dataframe raw which was
# transformed into de_identified_raw.csv

tw_d <- subset(raw, select = c(user_id, id_str, created_at, text, 
                                  geo_enabled, country_code, X, Y, 
                                  place_lat, lon, lat, place_lon ))

# all geoenabled, US country coded
table(tw_d$geo_enabled)
table(tw_d$country_code)

# X and Y are coordinates and no cells contain NAs
any(is.na(tw_d$X))
any(is.na(tw_d$Y))

# place_lat and place_lon also have no NAs
any(is.na(tw_d$place_lat))
any(is.na(tw_d$place_lon))

# lat and lon do have NAs. Will not use this col
any(is.na(tw_d$lat))
any(is.na(tw_d$lon))



# new dataframe without unecessary cols
wrk_d <- subset(raw, select = c(user_id, id_str, created_at, text, 
                             X, Y, place_lat, place_lon ))

# attempting to eyeball points to confirm only US sent tweets
library(rworldmap)
testmap <- getMap(resolution = "low")
plot(testmap, asp = 1)
points(wrk_d$X, wrk_d$Y, col = "red", cex = .6)

# appears that few tweets are in Europe and Guam(?) with X, Y or place_lat, place_lon
# with lat, lon, few tweets come from India and Japan (could be US base in Japan)

write.csv(wrk_d, "non_USfiltered.csv")


