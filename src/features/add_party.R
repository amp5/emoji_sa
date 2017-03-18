#########################################################################
#    File_name: add_party.R
#    Version: R version 3.2.4 (2016-03-10)
#    Date: 03_17_2017
#    Author: amp5
#    Purpose: For each tweet add col that shows which party tweet is referring to
#    Input_files: extracted_emojis.Rda, 
#    Output_files: e_twts_w_affiliation.Rda, e_twts_w_party.Rda
#    Previous_files: exploratoy_data_analysis.R
#    Required by: exploratory_data_analysis_v2.R, TBD (adding emoji sentiment src)
#    Status: Complete
#    Machine: OSX Yosemite v. 10.10.5 (laptop)
#########################################################################
library(tidyverse)

# Setting path and loading files ------------------------------------------
path <- "/Users/alexandraplassaras/Desktop/Spring_2017/QMSS_Thesis/QMSS_thesis" 
setwd(path)

# load extracted_emojis.Rda, var name is 'final'
load(file.choose())


# Code --------------------------------------------------------------------

wrk_d <- select(final, c(X, text.x))

wrk_d <- wrk_d %>%
  mutate(text_only = text.x)
         
wrk_d$text_only <- sapply(wrk_d$text_only,function(row) iconv(row, "latin1", "ASCII", sub=""))


t <- wrk_d

t$HC <- 0
t$HC[grepl("Clinton | clinton | Hillary | hillary | Hillaryclinton | hillaryclinton |
           Hillary Clinton | hillary clinton | HillaryClinton | @HillaryClinton | HILLARY | CLINTON | imwithher", t$text_only)] <- 1
t$BS <- 0
t$BS[grepl("Berniesanders | berniesanders | Bernie Sanders  | bernie sanders | Bernie |
           bernie | @Sensanders | sensanders | @BernieSanders | BERNIE | SANDERS  | @Berniesanders | feelthebern", t$text_only)] <- 1
t$TC <- 0
t$TC[grepl("Cruz | cruz | Ted | ted | Tedcruz | tedcruz | Ted Cruz | ted cruz | 
           @tedcruz | @SenTedCruz | TED | CRUZ" , t$text_only)] <- 1
t$DT <- 0
t$DT[grepl("Donaldtrump  | donaldtrump | Donald Trump | donald trump | Trump | trump | 
           Donald | donald | Trumpf | trumpf |realDonaldTrump | @realDonaldTrump | DONALD | 
           TRUMP | alwaystrump | nevertrump | makeamericagreatagain" , t$text_only)] <- 1
t$MR <- 0
t$MR[grepl("Marcorubio | marcorubio | Marco Rubio | marco rubio | @marcorubio | MARCO | 
           RUBIO | Rubio" , t$text_only)] <- 1
t$Rep <- 0
t$Rep[grepl("Republican | republican | rep | Rep", t$text_only)] <- 1
t$Dem <- 0
t$Dem[grepl("Democrat | democrat | dem | Dem ", t$text_only)] <- 1
         
t$republican <- with(t, ifelse(t$Rep == 1 | t$DT == 1 | t$TC == 1 | t$MR == 1, 1, 0))
t$democrat <- with(t, ifelse(t$Dem == 1 | t$HC == 1 | t$BS == 1, 1, 0))
t$other <- with(t, ifelse(t$republican == 0 & t$democrat == 0, 1, ifelse(t$republican == 1 | t$democrat == 1, 0, "error")))


t <- subset(t, select=-text.x)

w_affil <- merge(final, t, by = "X", all.x = TRUE)
only_party <-filter(w_affil, w_affil$other == 0)


# merge this data back into wrk_d and make sure no NAs for anything - no NAs
apply(only_party, 2, function(x) any(is.na(x)))


# Output ------------------------------------------------------------------
save(w_affil,file="data/interim/e_twts_w_affiliation.Rda")
save(only_party,file="data/processed/e_twts_w_party.Rda")




