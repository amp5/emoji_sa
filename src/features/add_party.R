#########################################################################
#    File_name: add_party.R
#    Version: R version 3.2.4 (2016-03-10)
#    Date: 03_17_2017
#    Author: amp5
#    Purpose: For each tweet add col that shows which party tweet is referring to
#    Input_files: extracted_emojis.Rda, 
#    Output_files: TBD
#    Previous_files: exploratoy_data_analysis.R
#    Required by: TBD
#    Status: Working on
#    Machine: OSX Yosemite v. 10.10.5 (laptop)
#########################################################################
library(tidyverse)

# Setting path and loading files ------------------------------------------
path <- "/Users/alexandraplassaras/Desktop/Spring_2017/QMSS_Thesis/QMSS_thesis" 
setwd(path)

# load extracted_emojis.Rda, var name is 'final'
load(file.choose())