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

tweets <- wrk_d[12:13,]
tweets <- wrk_d

tweets <- tweets[, c("X.1", "text")]

# From looking at sample of tweets, emojis display as format -> \U0001f602

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

# tweets <- subset(tweets.final, hashtag %in% c('#womensmarch'));
## create full tweets by emojis matrix
tweets$text_n_url <- gsub('http.*\\s*', '', tweets$text)


tweets$emoji_conv <- as.factor(iconv(tweets$text_n_url, "latin1", "ASCII", "byte"))

df.s<- matrix(NA, nrow = nrow(tweets), ncol = ncol(emojis)); 
system.time(df.s <- sapply(emojis$rencoding, regexpr, tweets$emoji_conv, ignore.case = T, useBytes = T));





rownames(df.s) <- 1:nrow(df.s); 
colnames(df.s) <- 1:ncol(df.s); 
df.t <- data.frame(df.s); 


df.t$tweetid <- tweets$X.1;

# merge in hashtag data from original tweets dataset
df.a <- subset(tweets, select = c(tweetid, hashtag)); 
df.u <- merge(df.t, df.a, by = 'tweetid'); 
df.u$z <- 1; 
df.u <- arrange(df.u, tweetid); 



tweets.emojis.matrix <- df.t
## create emoji count dataset
df <- subset(tweets.emojis.matrix)[, c(1:842)]; 
count <- colSums(df > -1);
emojis.m <- cbind(count, emojis); 
emojis.m <- arrange(emojis.m, desc(count));

emojis.count <- subset(emojis.m, count > 1); 
emojis.count$dens <- round(1000 * (emojis.count$count / nrow(tweets)), 1); 
emojis.count$dens.sm <- (emojis.count$count + 1) / (nrow(tweets) + 1);

emojis.count$rank <- as.numeric(row.names(emojis.count));
emojis.count.p <- subset(emojis.count, select = c(name, dens, count, rank));

# print summary stats
subset(emojis.count.p, rank <= 10);
num.tweets <- nrow(tweets); 
df.t <- rowSums(tweets.emojis.matrix[, c(1:842)] > -1); 
num.tweets.with.emojis <- length(df.t[df.t > 0]); 
num.emojis <- sum(emojis.count$count);


num.tweets; 
num.tweets.with.emojis; 
round(100 * (num.tweets.with.emojis / num.tweets), 1); 
num.emojis; 
nrow(emojis.count)

