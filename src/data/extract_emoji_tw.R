#########################################################################
#    File_name: extract_emoji_tw.R
#    Version: R version 3.2.4 (2016-03-10)
#    Date: 02_25_2017
#    Author: amp5
#    Purpose: Identify which tweets have emojis in them and which do not. 
#             From there filter out all tweets with at least one emoji.
#    Input_files: non_USfiltered.csv
#    Output_files: 
#    Previous_files: refine_dataset.R
#    Status: Working on
#    Machine: OSX Yosemite v. 10.10.5 (laptop)
#########################################################################

library(tidyverse)
library(plyr)
library(ggplot2)
library(splitstackshape)
library(stringr)
# instead of reloading input files, working with dataframe wrk_d which was
# saved as non_USfiltered.csv

wrk_d <- read.csv(file.choose())

tst <- head(wrk_d, 20)
tweets <- wrk_d[12:14,]
tweets <- wrk_d

# for now just concered with text and an id for each tweet
tweets <- tweets[, c("X.1", "text")]


#### READ IN EMOJI DICTIONARIES
setwd("/Users/alexandraplassaras/Desktop/Spring_2017/QMSS_Thesis/QMSS_thesis/data/external")
emdict.la <- read.csv('emoticon_conversion_noGraphic.csv', header = F); #Lauren Ancona; https://github.com/laurenancona/twimoji/tree/master/twitterEmojiProject
emdict.la <- emdict.la[-1, ]; row.names(emdict.la) <- NULL; names(emdict.la) <- c('unicode', 'bytes', 'name'); emdict.la$emojiid <- row.names(emdict.la);
emdict.jpb <- read.csv('emDict.csv', header = F) #Jessica Peterka-Bonetta; http://opiateforthemass.es/articles/emoticons-in-R/
emdict.jpb <- emdict.jpb[-1, ]; row.names(emdict.jpb) <- NULL; names(emdict.jpb) <- c('name', 'bytes', 'rencoding'); emdict.jpb$name <- tolower(emdict.jpb$name);
emdict.jpb$bytes <- NULL;
## merge dictionaries
emojis <- merge(emdict.la, emdict.jpb, by = 'name');  emojis$emojiid <- as.numeric(emojis$emojiid); emojis <- arrange(emojis, emojiid);

setwd("/Users/alexandraplassaras/Desktop/Spring_2017/QMSS_Thesis/QMSS_thesis")
###### FIND TOP EMOJIS FOR A GIVEN SUBSET OF THE DATA

# From looking at sample of tweets, emojis display as format -> \U0001f602
# however R encodes this differently, must convert it
tweets$text_n_url <- gsub('http.*\\s*', '', tweets$text)
tweets$emoji <- gsub("[abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ @!#$%^&*()_+=:]", "", tweets$text_n_url)


tweets$emoji_conv <- as.factor(iconv(tweets$emoji, "latin1", "ASCII", "byte"))

## create full tweets by emojis matrix
emoji.fv <- vapply(emojis$bytes, regexpr,FUN.VALUE = integer(nrow(tweets)),
                                 tweets$text, useBytes = T )
rownames(emoji.fv) <- 1:nrow(emoji.fv); 
colnames(emoji.fv) <- 1:ncol(emoji.fv); 
df.t <- data.frame(emoji.fv); 

## create emoji count dataset
df <- subset(df.t)[, c(1:842)]; 
count <- colSums(df > -1);

emojis.m <- cbind(count, emojis); 
emojis.m <- arrange(emojis.m, desc(count));

emoji_c <- subset(emojis.m, count > 0)
emoji_c$dens <- round(1000 * (emoji_c$count / nrow(tweets)), 1); 
emoji_c$dens_sm <- (emoji_c$count + 1) / (nrow(tweets) + 1);

#emoji_c$rank <- as.numeric(row.names(emoji_c));
#emoji_cp <- subset(emoji_p, select = c(name, dens, count, rank));

# print summary stats
#subset(emojis.count.p, rank <= 10);
num.tweets <- nrow(tweets); 
tweets_w_emojis <- rowSums(df.t[, c(1:842)] > -1); 
num.tweets.with.emojis <- length(tweets_w_emojis[tweets_w_emojis > 0]); 
num.emojis <- sum(emoji_c$count);


num.tweets; 
num.tweets.with.emojis; 
round(100 * (num.tweets.with.emojis / num.tweets), 1); 
num.emojis; 
nrow(emoji_c)

