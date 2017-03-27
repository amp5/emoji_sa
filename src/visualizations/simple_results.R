#########################################################################
#    File_name: simple_results.R
#    Version: R version 3.2.4 (2016-03-10)
#    Date: 03_26_2017
#    Author: amp5
#    Purpose: Make graphs needed for results
#    Input_files: twts_w_e_txt_sa.Rda
#    Output_files: TBD
#    Previous_files: add_text_sentiment.R
#    Required by: TBD
#    Status: Working on
#    Machine: OSX Yosemite v. 10.10.5 (laptop)
#########################################################################
library(tidyverse)

# Setting path and loading files ------------------------------------------
path <- "/Users/alexandraplassaras/Desktop/Spring_2017/QMSS_Thesis/QMSS_thesis" 
setwd(path)

# load twts_w_e_txt_sa.Rda
load(file.choose())
