#########################################################################
#    File_name: extract_id_username_keys.R
#    Version: R version 3.2.4 (2016-03-10)
#    Date: 02_01_2017
#    Author: amp5
#    Purpose: extracting username and id to create key. The next step would be to remove usernames
#             from my raw data before processing it. Professor noted that keeping this info in 
#             raw dataset uploaded on github would not be a good pactice. Still want record of id
#             for potentail later use in visualization or tables.
#    Input_files: tweets_all_sent_mapped.csv
#    Output_files: id_user_keys.csv and de_identified_raw.csv
#    Previous_files: N/A
#    Status: Working on
#    Machine: OSX Yosemite v. 10.10.5 (laptop)
#########################################################################
setwd("/Users/alexandraplassaras/Desktop/Spring_2017/QMSS_Thesis/QMSS_thesis")
d <- read.csv(file.choose())

user <- subset(d, select = c(screen_name ))
head(user)

# d$id_str and d$idx are unique identifiers for the tweet. Appears that only identifier for user is screenname
# need to generate own unique numeric id instead of screenname

     
uniq_user <- unique(user)
# unique count is 237,499
uniq_user$user_id <- 1:nrow(uniq_user)

# saving key to csv, stored in .gitignore
write.csv(uniq_user, "id_user_keys.csv")

# merging uniq_user with main df
raw <- merge(d, uniq_user, by = "screen_name")


#removing screen_name
raw$screen_name <- NULL

write.csv(raw, "de_identified_raw.csv")


