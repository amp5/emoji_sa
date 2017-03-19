#########################################################################
#    File_name: add_e_sentiment.R
#    Version: R version 3.2.4 (2016-03-10)
#    Date: 03_18_2017
#    Author: amp5
#    Purpose: Adding emoji sentiment score for each emoji
#    Input_files: extracted_emojis.Rda, Emoji_Sentiment_Data.csv
#    Output_files: TBD
#    Previous_files: add_party.R
#    Required by: TBD
#    Status: In Progress
#    Machine: OSX Yosemite v. 10.10.5 (laptop)
#########################################################################
library(tidyverse)

# Setting path and loading files ------------------------------------------
path <- "/Users/alexandraplassaras/Desktop/Spring_2017/QMSS_Thesis/QMSS_thesis" 
setwd(path)

# load e_twts_w_party.Rda, var name is 'only_party'
load(file.choose())

# load "Emoji_Sentiment_Data.csv"
sa <- read.csv(file.choose())

# load full_emoji_db.csv
e_df <- read.csv(file.choose())


# Code --------------------------------------------------------------------

sa$Unicode.name <- tolower(sa$Unicode.name)
sa <- subset(sa, select = -c(Position, X))

emoji_w_sa <- merge(e_df, sa, by.x = "name", by.y = "Unicode.name", all.x = TRUE) 
emoji_w_sa <- subset(emoji_w_sa, select = -c(bytes, X, rencoding, Emoji, Unicode.codepoint))
names(emoji_w_sa) <- c("name", "unicode", "emojiid", "occurances", "neg", "neut", 
                       "pos", "type", "p_neg", "p_pos", "sentiment_scr")

just_emoji <- subset(only_party, select = c(X, emoji, data))
unnested <- just_emoji %>%
  unnest()

unnest_emoji_sa <- as_tibble(merge(unnested, emoji_w_sa, by.x = "emoji_id", 
                                   by.y = "emojiid", all.x = TRUE))
emojis_sa <- subset(unnest_emoji_sa, select = c(X, emoji, emoji_id, sentiment_scr))

emojis_sa <- emojis_sa %>%
  group_by(X, emoji) %>%
  nest(sentiment_scr)


tst <- head(emojis_sa, 50)
tst <- emojis_sa[28,]
tst <- emojis_sa


tst_ul <- unlist(tst$data)
tst$sum <- lapply(tst$data[[1]], function(x) sum(x))
names(tst$sum) <- "sum"
tst$avg <- as.numeric(as.matrix(tst$sum)) / nchar(tst$emoji)


e_party_sa <- merge(only_party, tst, by = "X", all = T)
e_party_sa <- subset(e_party_sa, select = -c(emoji.y))

names(e_party_sa) <- c("unique_id", "text", "emoji", "unique_e_id_lst", "user_id", "id_str",
                       "created", "lang", "verified", "place_lat", "place_lon", "text_only",
                       "hc", "bs", "tc", "dt", "mr", "rep", "dem", "republican", "democrat", 
                       "other", "sent_list", "sent_sum", "sent_scr")


emoji_sa_f <- subset(e_party_sa, select = c(unique_id, text, emoji, created, 
                                            republican, democrat, other, sent_scr))



#### giving me what I want for all but a few rows......
# Outputs -----------------------------------------------------------------

# entire data
save(e_party_sa,file="data/processed/e_twts_w_sa.Rda")

# data that I'll most likely only use
save(emoji_sa_f,file="data/processed/sa_etwts.Rda")

