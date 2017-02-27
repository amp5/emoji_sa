#########################################################################
#    File_name: emoji_databases.R
#    Version: R version 3.2.4 (2016-03-10)
#    Date: 02_26_2017
#    Author: amp5
#    Purpose: Load all emoji databases and merge together 
#    Input_files: emoticon_conversion_noGraphic.csv , emDict.csv
#    Output_files: full_emoji_db.csv
#    Previous_files: refine_dataset.R
#    Status: Completed
#    Machine: OSX Yosemite v. 10.10.5 (laptop)
#########################################################################

library(tidyverse)
library(plyr)
library(ggplot2)
library(splitstackshape)
library(stringr)

#### READ IN EMOJI DICTIONARIES
setwd("/Users/alexandraplassaras/Desktop/Spring_2017/QMSS_Thesis/QMSS_thesis/data/external")
emdict.la <- read.csv('emoticon_conversion_noGraphic.csv', header = F); #Lauren Ancona; https://github.com/laurenancona/twimoji/tree/master/twitterEmojiProject
emdict.la <- emdict.la[-1, ]; row.names(emdict.la) <- NULL; names(emdict.la) <- c('unicode', 'bytes', 'name'); emdict.la$emojiid <- row.names(emdict.la);
emdict.jpb <- read.csv('emDict.csv', header = F) #Jessica Peterka-Bonetta; http://opiateforthemass.es/articles/emoticons-in-R/
emdict.jpb <- emdict.jpb[-1, ]; row.names(emdict.jpb) <- NULL; names(emdict.jpb) <- c('name', 'bytes', 'rencoding'); emdict.jpb$name <- tolower(emdict.jpb$name);
emdict.jpb$bytes <- NULL;
## merge dictionaries
emojis <- merge(emdict.la, emdict.jpb, by = 'name');  emojis$emojiid <- as.numeric(emojis$emojiid); emojis <- arrange(emojis, emojiid);

write.csv(emojis, "full_emoji_db.csv")

