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
# instead of reloading input files, working with dataframe wrk_d which was
# saved as non_USfiltered.csv

wrk_d <- read.csv(file.choose())


samp <- head(wrk_d$text, 20)

# From looking at sample of tweets, emojis display as format -> \U0001f602



