#########################################################################
#    File_name: exploratory_data_analysis_v2.R
#    Version: R version 3.2.4 (2016-03-10)
#    Date: 03_18_2017
#    Author: amp5
#    Purpose: exploratory analysis after party added
#    Input_files: e_twts_w_affiliation.Rda, e_twts_w_party.Rda
#    Output_files: TBD
#    Previous_files: add_party.R
#    Required by: TBD (EDA_v2)
#    Status: Complete
#    Machine: OSX Yosemite v. 10.10.5 (laptop)
#########################################################################
library(tidyverse)
library(stringr)
library(lubridate)






# save all e tweets with new var -> EDA show many tweets are dem, rep and other in bar chart
# save only e_party tweets -> show distribution of e_twts by party