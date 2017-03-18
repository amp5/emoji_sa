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