#########################################################################
#    File_name: robust_results.R
#    Version: R version 3.2.4 (2016-03-10)
#    Date: 03_30_2017
#    Author: amp5
#    Purpose: Make graphs needed for results
#    Input_files: robust_sa.Rda
#    Output_files: TBD
#    Previous_files: add_text_sentiment.R
#    Required by: TBD
#    Status: Working on
#    Machine: OSX Yosemite v. 10.10.5 (laptop)
#########################################################################
library(tidyverse)
library(lubridate)


# Setting path and loading files ------------------------------------------
path <- "/Users/alexandraplassaras/Desktop/Spring_2017/QMSS_Thesis/QMSS_thesis" 
setwd(path)

# load robust_sa.Rda
load(file.choose())

final_robust <- select(final_txt_sa_r, -c(txt_o, data, sum_txt, char_n, other, sent_simple))

final_robust$republican <- ifelse(final_robust$republican == 1, "rep", "")
final_robust$democrat <- ifelse(final_robust$democrat == 1, "dem", "")

final_robust$party <- paste(final_robust$republican, final_robust$democrat)
final_robust$party <- ifelse(final_robust$party == "rep dem", "both", final_robust$party)


ggplot(final_robust, aes(x = txt_sent_scr, y = sent_robust)) +
  geom_point() +
  geom_count() +
  theme_minimal() +
  geom_vline(xintercept = 0) + geom_hline(yintercept = 0) +
  labs(x = "text sentiment", y = "emoji sentiment") +
  ggtitle("Robust Sentiment of Emoji vs. Text", subtitle = "n = 26,026")

ggplot(final_robust, aes(x = txt_sent_scr, y = sent_robust, color = party)) +
  geom_point() +
  scale_color_manual(values=c("#56B4E9", "#9999CC", "#CC6666")) +
  geom_count() +
  theme_minimal() +
  geom_vline(xintercept = 0) + geom_hline(yintercept = 0) +
  labs(x = "text sentiment", y = "emoji sentiment") +
  facet_wrap(~party, ncol = 2) +
  ggtitle("Robust Sentiment of Emoji vs. Text by Political Reference", subtitle = "n = 26,026")



final_dem <- filter(final_robust, final_robust$party == " dem")
final_dem <- select(final_dem, c(created, sent_robust))
final_dem_date <-  aggregate(. ~ created, final_dem, mean)
final_dem_date$party <- "dem"

final_rep <- filter(final_robust, final_robust$party == "rep ")
final_rep <- select(final_rep, c(created, sent_robust))
final_rep_date <-  aggregate(. ~ created, final_rep, mean)
final_rep_date$party <- "rep"

final_both <- filter(final_robust, final_robust$party == "both")
final_both <- select(final_both, c(created, sent_robust))
final_both_date <-  aggregate(. ~ created, final_both, mean)
final_both_date$party <- "both"

final_s_date_d <- rbind(final_both_date, final_dem_date, final_rep_date)
final_s_date_d$created <- as.Date(mdy(final_s_date_d$created, tz = "America/New_York"))
final_s_date_d$party_f <-factor(final_s_date_d$party, levels = c("dem", "both", "rep")) 


ggplot(final_s_date_d, aes(x = created, y = sent_robust, color = party)) +
  geom_point() +
  scale_color_manual(values=c("#9999CC", "#56B4E9", "#CC6666")) +
  geom_smooth(method = "lm", se = TRUE) +
  theme_minimal() +
  theme(axis.text.x=element_text(angle=90)) +
  scale_x_date(date_breaks = ("5 day"), date_labels = "%b %d") +
  labs(x = "Date", y = "Average Emoji Sentiment") +
  facet_wrap(~party_f, ncol = 2) +
  ggtitle("Robust Sentiment of Emoji Over Time by Political Reference", subtitle = "n = 26,026")





final_demt <- filter(final_robust, final_robust$party == " dem")
final_demt <- select(final_demt, c(created, txt_sent_scr))
final_dem_datet <-  aggregate(. ~ created, final_demt, mean)
final_dem_datet$party <- "dem"

final_rept <- filter(final_robust, final_robust$party == "rep ")
final_rept <- select(final_rept, c(created, txt_sent_scr))
final_rep_datet <-  aggregate(. ~ created, final_rept, mean)
final_rep_datet$party <- "rep"

final_botht <- filter(final_robust, final_robust$party == "both")
final_botht <- select(final_botht, c(created, txt_sent_scr))
final_both_datet <-  aggregate(. ~ created, final_botht, mean)
final_both_datet$party <- "both"

final_s_date_dt <- rbind(final_both_datet, final_dem_datet, final_rep_datet)
final_s_date_dt$created <- as.Date(mdy(final_s_date_dt$created, tz = "America/New_York"))
final_s_date_dt$party_f <-factor(final_s_date_dt$party, levels = c("dem", "both", "rep")) 


ggplot(final_s_date_dt, aes(x = created, y = txt_sent_scr, color = party)) +
  geom_point() +
  scale_color_manual(values=c("#9999CC", "#56B4E9", "#CC6666")) +
  geom_smooth(method = "lm", se = TRUE) +
  theme_minimal() +
  theme(axis.text.x=element_text(angle=90)) +
  scale_x_date(date_breaks = ("5 day"), date_labels = "%b %d") +
  labs(x = "Date", y = "Average Emoji Sentiment") +
  facet_wrap(~party_f, ncol = 2) +
  ggtitle("Robust Sentiment of Text Over Time by Political Reference", subtitle = "n = 26,026")


ggplot(final_robust, aes(x = sent_robust, fill = party)) +
  geom_histogram(binwidth = 0.1)  +
  scale_fill_manual(values=c("#56B4E9","#9999CC", "#CC6666")) +
  theme_minimal() +
  labs(x = "Emoji Sentiment") +
  facet_wrap(~party, ncol = 2) +
  ggtitle("Robust Emoji Sentiment Score Distribution", subtitle = "n = 26,026")


ggplot(final_robust, aes(x = txt_sent_scr, fill = party)) +
  geom_histogram(binwidth = 0.1)  +
  scale_fill_manual(values=c("#56B4E9","#9999CC", "#CC6666")) +
  theme_minimal() +
  labs(x = "Text Sentiment") +
  facet_wrap(~party, ncol = 2) +
  ggtitle("Robust Text Sentiment Score Distribution", subtitle = "n = 26,026")







