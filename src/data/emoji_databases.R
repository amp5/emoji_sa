#########################################################################
#    File_name: emoji_databases.R
#    Version: R version 3.2.4 (2016-03-10)
#    Date: 02_26_2017
#    Author: amp5
#    Purpose: Load all emoji databases and merge together 
#    Input_files: emoticon_conversion_noGraphic.csv , emDict.csv
#    Output_files: full_emoji_db.csv
#    Previous_files: refine_dataset.R
#    Required by: extract_emoji_tw.R
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


#### READ IN EMOJI DICTIONARIES
emdict_la <- read.csv('data/external/emoticon_conversion_noGraphic.csv', header = F); #Lauren Ancona; https://github.com/laurenancona/twimoji/tree/master/twitterEmojiProject
emdict_jpb <- read.csv('data/external/emDict.csv', header = F) #Jessica Peterka-Bonetta; http://opiateforthemass.es/articles/emoticons-in-R/



# Code --------------------------------------------------------------------
emdict_la <- emdict_la[-1, ]
row.names(emdict_la) <- NULL
names(emdict_la) <- c('unicode', 'bytes', 'name') 
emdict_la$emojiid <- row.names(emdict_la)

emdict_jpb <- emdict_jpb[-1, ]
row.names(emdict_jpb) <- NULL
names(emdict_jpb) <- c('name', 'bytes', 'rencoding')
emdict_jpb$name <- tolower(emdict_jpb$name)
emdict_jpb$bytes <- NULL;

## merge dictionaries
emojis <- merge(emdict_la, emdict_jpb, by = 'name')  
emojis$emojiid <- as.numeric(emojis$emojiid)
emojis <- arrange(emojis, emojiid)


# Creating outputs -------------------------------------------------------
write.csv(emojis, "data/processed/full_emoji_db.csv")

