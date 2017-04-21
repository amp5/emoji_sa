#########################################################################
#    File_name: robust_results.R
#    Version: R version 3.2.4 (2016-03-10)
#    Date: 04_21_2017
#    Author: amp5
#    Purpose: Make graphs needed for weighted results
#    Input_files: robust_sa_w.Rda
#    Output_files: TBD
#    Previous_files: add_text_sentiment_robust_2.R
#    Required by: TBD
#    Status: Working on
#    Machine: OSX Yosemite v. 10.10.5 (laptop)
#########################################################################
library(tidyverse)
library(lubridate)
library(gmodels)
library(reshape2)


# Setting path and loading files ------------------------------------------
path <- "/Users/alexandraplassaras/Desktop/Spring_2017/QMSS_Thesis/QMSS_thesis" 
setwd(path)

# load robust_sa_w.Rda
load(file.choose())

users_uniq <- data.frame(unique(final_txt_sa_r_w$user_id))
nrow(users_uniq)

final_robust <- select(final_txt_sa_r_w, -c(txt_o, data, sum_txt, char_n, other, sent_simple))

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

final_s_date_d$type <- "emoji"
colnames(final_s_date_d)[2] <- "score"

final_s_date_dt$type <- "text" 
colnames(final_s_date_dt)[2]<- "score"

o_t <- rbind(final_s_date_d, final_s_date_dt)
o_t$party <- NULL
colnames(o_t)[3] <- "party"

ggplot(o_t, aes(x = created, y = score, color = party, shape = type)) +
  geom_point() +
  geom_point() +
  scale_color_manual(values=c("#56B4E9", "#9999CC", "#CC6666"), labels = c("Democrat", "Both", "Republican")) +
  geom_smooth(method = "lm", se = TRUE) +
  theme_minimal() +
  theme(axis.text.x=element_text(angle=90)) +
  scale_x_date(date_breaks = ("5 day"), date_labels = "%b %d") +
  labs(x = "Date", y = "Average Sentiment") +
  facet_grid(party ~ type) +
  ggtitle(" ", subtitle = "n = 26,026")




txt <- subset(final_robust, select = c(party, txt_sent_scr))
colnames(txt)[2] <- "score"
txt$type <- "text"

emoji <- subset(final_robust, select = c(party, sent_robust))
colnames(emoji)[2] <- "score"
emoji$type <- "emoji"

total <- nrow(final_robust)

hist_both <- rbind(txt, emoji)
hist_both$percent <- hist_both$score/total



ggplot(hist_both, aes(x = score, fill = party)) +
  geom_histogram(binwidth = 0.1)  +
  scale_fill_manual(values=c("#56B4E9","#9999CC", "#CC6666")) +
  theme_minimal() +
  geom_vline(xintercept = 0) + geom_hline(yintercept = 0) +
  labs(x = "Emoji Sentiment") +
  facet_grid(party ~ type) +
  theme(legend.position="none") +
  ggtitle(" ", subtitle = "n = 26,026")


hist_both$polarity <- ifelse(hist_both$score > 0, "pos", 
                             ifelse(hist_both$score == 0, "neut", 
                                    ifelse(hist_both$score < 0, "neg", 0)))
p_n_n <- subset(hist_both, select = c(score, party, type, polarity))

tbl <- aggregate(score ~ type + party + polarity, p_n_n, length)
tbl$percent <- tbl$score / total

tbl_a <- aggregate(score ~ type + polarity, p_n_n, length)
tbl_a$percent <- tbl_a$score / total

tbl_p <- aggregate(score ~ polarity + party, p_n_n, length)
tbl_p$percent <- tbl_p$score / total



ggplot(data = hist_both, aes(x = type, y = score)) + 
  geom_boxplot(aes(fill=party), outlier.alpha = 0.1) +
  scale_fill_manual(values=c("#56B4E9","#9999CC", "#CC6666")) +
  theme_minimal() +
  labs(x = "Character Type", y = "Score") +
  facet_grid( ~ party) +
  ggtitle(" ", subtitle = "n = 26,026")


sent_matrix <- final_robust[c("sent_robust", "txt_sent_scr")]
cor.test(sent_matrix$sent_robust, sent_matrix$txt_sent_scr, method="pearson")
# Pearson's product-moment correlation

# data:  sent_matrix$sent_robust and sent_matrix$txt_sent_scr
# t = 3.1328, df = 26024, p-value = 0.001733
# alternative hypothesis: true correlation is not equal to 0
# 95 percent confidence interval:
# 0.007268816 0.031558077
# sample estimates:
# cor 
# 0.01941631 

ggplot(sent_matrix, aes(x = sent_robust, y = txt_sent_scr)) +
  geom_point() +
  geom_count() +
  geom_smooth(method = "lm") +
  geom_vline(xintercept = 0) + geom_hline(yintercept = 0) +
  theme_minimal() +
  labs(x = "Emoji Sentiment", y = " Text Sentiment") +
  ggtitle(cor(sent_matrix, method="pearson")[2], subtitle = "n = 26,026, t = 3.1328, df = 26024, p-value = 0.001733")



party_sent <- final_robust[c("party", "sent_robust", "txt_sent_scr")]


party_sent$emoji_scr <- ifelse(party_sent$sent_robust > 0, "pos", 
                               ifelse(party_sent$sent_robust == 0, "neu", 
                                      ifelse(party_sent$sent_robust < 0, "neg", "error")))


party_sent$txt_scr <- ifelse(party_sent$txt_sent_scr > 0, "pos", 
                             ifelse(party_sent$txt_sent_scr == 0, "neu", 
                                    ifelse(party_sent$txt_sent_scr < 0, "neg", "error")))

dem_scr <- filter(party_sent, party_sent$party == " dem")
dem_scr$combo <- paste(dem_scr$txt_scr, "-", dem_scr$emoji_scr)
p_dem <- subset(dem_scr, select = c(party, combo))
dt <- as_tibble(table(p_dem))
dt$percent <- dt$n/nrow(dem_scr)

rep_scr <- filter(party_sent, party_sent$party == "rep ")
rep_scr$combo <- paste(rep_scr$txt_scr, "-", rep_scr$emoji_scr)
p_rep <- subset(rep_scr, select = c(party, combo))
rt <- as_tibble(table(p_rep))
rt$percent <- rt$n/nrow(rep_scr)

both_scr <- filter(party_sent, party_sent$party == "both")
both_scr$combo <- paste(both_scr$txt_scr, "-", both_scr$emoji_scr)
p_both <- subset(both_scr, select = c(party, combo))
bt <- as_tibble(table(p_both))
bt$percent <- bt$n/nrow(both_scr)



breakdown_p <- rbind(dt, rt, bt)


breakdown_p %>%
  ggplot(aes(x = combo, y = percent, fill = party)) +
  geom_col(position = "dodge") +
  scale_fill_manual(values=c("#56B4E9","#9999CC", "#CC6666")) +
  theme_minimal() +
  theme(axis.text.x=element_text(angle=45, hjust=1)) +
  labs(x = "Text - Emoji Sentiment", y = "Percent") +
  geom_text(
    aes(x = combo, y = percent, label = sprintf("%1.1f%%", 100*percent), group = party),
    position = position_dodge(width = 1),
    vjust = -0.5, size = 2.6)






percentages <- subset(party_sent, select = c(txt_scr, emoji_scr))
table(percentages)



# Looking at top 5 tweets for text and emoji sentiment --------------------
rank_txt_l <- final_robust[order(final_robust$txt_sent_scr),]
rank_txt_h <- final_robust[order(-final_robust$txt_sent_scr),]

txt_l <- head(rank_txt_l, 5)
txt_l <- subset(txt_l, select = c(text, txt_sent_scr))

txt_h <- head(rank_txt_h, 5)
txt_h<- subset(txt_h, select = c(text, txt_sent_scr))


rank_e_l <- final_robust[order(final_robust$sent_robust),]
rank_e_h <- final_robust[order(-final_robust$sent_robust),]

e_l <- head(rank_e_l, 5)
e_l <- subset(e_l, select = c(text, sent_robust))
e_h <- head(rank_e_h, 5)
e_h <- subset(e_h, select = c(text, sent_robust))


txt_extremes <- rbind(txt_l, txt_h)

e_extremes <- rbind(e_l, e_h)


