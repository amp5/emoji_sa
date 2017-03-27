#########################################################################
#    File_name: add_e_sentiment.R
#    Version: R version 3.2.4 (2016-03-10)
#    Date: 03_18_2017
#    Author: amp5
#    Purpose: Adding emoji sentiment score for each emoji. Two sets of scores:
#     One is simple so looking at -1, 0, 1 of emojis and the other is more nuanced
#    Input_files: extracted_emojis.Rda, Emoji_Sentiment_Data.csv
#    Output_files: e_twts_w_sa.Rda, sa_etwts.Rda
#    Previous_files: add_party.R
#    Required by: add_text_sentiment.R
#    Status: Complete
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
                       "pos", "type", "p_neg", "p_pos", "sentiment_scr", "sent_score_updates")

just_emoji <- subset(only_party, select = c(X, emoji, data))
unnested <- just_emoji %>%
  unnest()

unnest_emoji_sa <- as_tibble(merge(unnested, emoji_w_sa, by.x = "emoji_id", 
                                   by.y = "emojiid", all.x = TRUE))
emojis_sa <- subset(unnest_emoji_sa, select = c(X, emoji, emoji_id, sent_score_updates))

emojis_sa <- emojis_sa %>%
  group_by(X, emoji) %>%
  nest(sent_score_updates)


# tst <- head(emojis_sa, 50)
# tst <- emojis_sa[1:3,]
tst <- emojis_sa


tst$sum_simp <- lapply(tst$data, function(x) {
  x$sum_simp <- colSums(x, na.rm=T)
})
tst$avg_simple <- as.numeric(as.matrix(tst$sum_simp)) / nchar(tst$emoji)



##### Adding the other sentiment score - more robust
emojis_sa2 <- subset(unnest_emoji_sa, select = c(X, emoji, emoji_id, sentiment_scr))

emojis_sa2 <- emojis_sa2 %>%
  group_by(X, emoji) %>%
  nest(sentiment_scr)


# tst <- head(emojis_sa, 50)
# tst <- emojis_sa[1:3,]
tst2 <- emojis_sa2


tst2$sum_r <- lapply(tst2$data, function(x) {
  x$sum_r <- colSums(x, na.rm=T)
})
tst2$avg_robust <- as.numeric(as.matrix(tst2$sum_r)) / nchar(tst2$emoji)




tst_comp <- merge(tst, tst2, by = c("X", "emoji"))


e_party_sa <- merge(only_party, tst_comp, by = "X", all = T)
e_party_sa <- subset(e_party_sa, select = -c(emoji.y, data.x, data.y, sum_simp, sum_r))

names(e_party_sa) <- c("unique_id", "text", "emoji", "unique_e_id_lst", "user_id", "id_str",
                       "created", "lang", "verified", "place_lat", "place_lon", "text_only",
                       "hc", "bs", "tc", "dt", "mr", "rep", "dem", "republican", "democrat", 
                       "other", "sent_simple", "sent_robust")


emoji_sa_f <- subset(e_party_sa, select = c(unique_id, text, emoji, created, 
                                            republican, democrat, other, sent_simple, sent_robust))



#### giving me what I want for all but a few rows......
# Outputs -----------------------------------------------------------------

# entire data
save(e_party_sa,file="data/processed/e_twts_w_sa.Rda")

# data that I'll most likely only use
save(emoji_sa_f,file="data/processed/sa_etwts.Rda")

