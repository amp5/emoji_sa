#########################################################################
#    File_name: extract_emoji_tw.R
#    Version: R version 3.2.4 (2016-03-10)
#    Date: 02_25_2017
#    Author: amp5
#    Purpose: Identify which tweets have emojis in them and which do not. 
#             From there filter out all tweets with at least one emoji.
#             - separate out just tweets and ids then merge back with big tibble at end
#             - figure out how many unique users and how many tweets after only emoji extracted
#    Input_files: filtered.csv, full_emoji_db.csv
#    Output_files: extracted_emojis.Rda and emoji_counts.csv
#    Previous_files: emoji_databases.R and refine_dataset.R
#    Required by: exploratoy_data_analysis.R
#    Status: Completed
#    Machine: OSX Yosemite v. 10.10.5 (laptop)
#########################################################################
library(tidyverse)
library(plyr)
library(ggplot2)
library(splitstackshape)
library(stringr)

# Setting path and loading files ------------------------------------------
path <- "/Users/alexandraplassaras/Desktop/Spring_2017/QMSS_Thesis/QMSS_thesis" 
setwd(path)

# load filtered.csv
wrk_d <- read.csv(file.choose())
# load full_emoji_db.csv
emojis <- read.csv(file.choose())


# Code --------------------------------------------------------------------
d <- as_tibble(wrk_d)
e <- as_tibble(emojis)

#tst <- head(d, 25)
#tweets <- d[12:14,]
#tweets <- d[12,]
#tweets <- d[1:25,]
tweets <- d

# for now just concered with text and an id for each tweet
tweets <- tweets[, c("X", "text")]

###### FIND TOP EMOJIS FOR A GIVEN SUBSET OF THE DATA
# From looking at sample of tweets, emojis display as format -> \U0001f602
# however R encodes this differently, must convert it
twts <- tweets %>%
  mutate(text_n_url = gsub('http.*\\s*', '', text)) %>%
  mutate(emoji = gsub("[abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ @!#$%^&*()|_+=:?.,;1234567890-]", "", text_n_url)) 

twts$emoji <- gsub("''", '', twts$emoji)
twts$emoji <- sub("//", "", twts$emoji)
twts$emoji <- gsub("'", '', twts$emoji)
twts$emoji <- sub("/", "", twts$emoji)

twts <- as_tibble(twts)
e_twts <- filter(twts, !(twts$emoji == ""))

e_twts <- e_twts %>%
  mutate(singl_emoji = strsplit(emoji, "")) %>%
  mutate(num = map_int(singl_emoji, length)) %>%
  unnest()
e_twts$internal_id <- 1:nrow(e_twts)

## create full tweets by emojis matrix
has_emoji <- vapply(e$bytes, regexpr, FUN.VALUE = integer(nrow(e_twts)),
                    e_twts$singl_emoji, useBytes = T )

rownames(has_emoji) <- 1:nrow(has_emoji)
colnames(has_emoji) <- 1:ncol(has_emoji) 
emoji_twts <- tibble::as_data_frame(has_emoji)

count <- colSums(has_emoji > -1)
emojis_m <- cbind(count, e) 
emojis_m <- arrange(emojis_m, desc(count))

emoji_c <- subset(emojis_m, count > 0)
emoji_c$dens <- round(1000 * (emoji_c$count / nrow(twts)), 1) 
emoji_c$dens_sm <- (emoji_c$count + 1) / (nrow(twts) + 1)


emoji_ids <- tibble::as_data_frame(which(emoji_twts > 0, arr.ind = T) )
result <- merge(e_twts, emoji_ids, by.x = "internal_id", by.y = "row", all.x = TRUE)
colnames(result)[8] <- "emoji_id"


result <- result %>%
  filter(!(is.na(result$emoji_id))) %>%
  group_by(X, text, emoji) %>% 
  nest(emoji_id)


(num_twts <- nrow(twts) )
(num_tweets_w_emojis <- nrow(result))
(num_emojis <- sum(emoji_c$count))
(num_types_emojis <- nrow(emoji_c))
round(100 * (num_tweets_w_emojis / num_twts), 1)


#add ranking section later
# order decscending percentage then do head for top 10
#emoji_c$rank <- as.numeric(row.names(emoji_c));
#emoji_cp <- subset(emoji_p, select = c(name, dens, count, rank));

# print summary stats
#subset(emojis.count.p, rank <= 10);  



# merge back with d data cols removed earlier
final <- merge(result, d, by= 'X', all.x = TRUE)
final <- subset(final, select=-text.y)


# Creating outputs  -------------------------------------------------------

save(final,file="data/processed/extracted_emojis.Rda")
write.csv(emoji_c, "data/interim/emoji_counts.csv")


