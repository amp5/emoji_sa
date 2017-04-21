#########################################################################
#    File_name: add_text_sentiment_robust_2.R
#    Version: R version 3.2.4 (2016-03-10)
#    Date: 04_03_2017
#    Author: amp5
#    Purpose: conduct sentiment analysis - robust sa with tf-idf
#    Input_files: sa_etwts.Rda
#    Output_files: twts_w_e_txt_sa.Rda
#    Previous_files: add_e_sentiment.R
#    Required by: robust_results_w.R
#    Status: Working On
#    Machine: OSX Yosemite v. 10.10.5 (laptop)
#########################################################################
library(tidyverse)
library(dplyr)
require(stringr)
library(tidytext)
library(wordcloud)
library(tidyr)
library(reshape2)


# Setting path and loading files ------------------------------------------
path <- "/Users/alexandraplassaras/Desktop/Spring_2017/QMSS_Thesis/QMSS_thesis" 
setwd(path)

# load sa_etwts.Rda
load(file.choose())

emoji_sa_f$txt_o <-  sapply(emoji_sa_f$text,function(row) iconv(row, "latin1", "ASCII", sub=""))

emoji_sa_f$txt_o <- gsub('http.*\\s*', '', emoji_sa_f$txt_o)
emoji_sa_f$txt_o <- gsub('&amp;', '', emoji_sa_f$txt_o)
emoji_sa_f$txt_o <- gsub('[@!#$%^&*()|_+=:?.,;]', '', emoji_sa_f$txt_o)

just_text <- select(emoji_sa_f, c(unique_id, txt_o, republican, democrat))
just_text <- as_tibble(just_text)

just_text$republican <- ifelse(just_text$republican == 1, "rep", "")
just_text$democrat <- ifelse(just_text$democrat == 1, "dem", "")

just_text$party <- paste(just_text$republican, just_text$democrat)
just_text$party <- ifelse(just_text$party == "rep dem", "both", just_text$party)


txt_party <- select(just_text, c(unique_id, txt_o, party))

tidy_twts <- txt_party %>%
  unnest_tokens(word, txt_o)

# attempt 3 with parties as "Documents" ---------------------------------------------------------------
tidy_twts2_un <- txt_party %>%
  unnest_tokens(word, txt_o) %>%
  count(unique_id, party, word, sort = TRUE) 

total_words_twt <- tidy_twts2_un %>% group_by(party) %>% summarize(total = sum(n))
tidy_twts2 <- left_join(tidy_twts2_un, total_words_twt)
tidy_twts2







twt_words <- tidy_twts2 %>%
  subset(select = -c(unique_id) ) %>%
  bind_tf_idf(word, party, n)

twt_words %>%
  select(-c(total)) %>%
  arrange(desc(tf_idf))

reordered <- twt_words %>%
  select(-total) %>%
  arrange(desc(tf_idf))


### didn't work.... or stalled R
# reordered %>%
#   top_n(5, tf_idf) %>%
#   ggplot(aes(reorder(word,tf_idf), tf_idf, fill = party)) +
#   geom_col() +
#   scale_fill_manual(values=c("#56B4E9","#9999CC", "#CC6666")) +
#   theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
#   ylab("Weighted Frequency (tf_idf) ") +
#   xlab("Top Words") 

# Weighted Scores Calculated -----------------------------------------
dem_idf <- subset(reordered, party == " dem", select = c("word", "tf_idf"))
dem_idf <- unique(dem_idf)
rep_idf <- subset(reordered, party == "rep ", select = c("word", "tf_idf"))
rep_idf <- unique(rep_idf)
both_idf <- subset(reordered, party == "both", select = c("word", "tf_idf"))
both_idf <- unique(both_idf)

afinn <- get_sentiments("afinn")
afinn$new <- afinn$score/5

w_afinn_d <- merge(afinn, dem_idf, by = "word", all.x = TRUE)
w_afinn_d <- subset(w_afinn_d, tf_idf != 0)
w_afinn_d$w_scr <- w_afinn_d$new * w_afinn_d$tf_idf



w_afinn_r <- merge(afinn, rep_idf, by = "word", all.x = TRUE)
w_afinn_r <- subset(w_afinn_r, tf_idf != 0)
w_afinn_r$w_scr <- w_afinn_r$new * w_afinn_r$tf_idf

w_afinn_b <- merge(afinn, both_idf, by = "word", all.x = TRUE)
w_afinn_b <- subset(w_afinn_b, tf_idf != 0)
w_afinn_b$w_scr <- w_afinn_b$new * w_afinn_b$tf_idf






w_afinn <- merge(w_afinn_d, w_afinn_r, by = "word", all = TRUE)
w_afinn <- merge(w_afinn, w_afinn_b, by = "word", all = TRUE)

w_afinn_scrs <- subset(w_afinn, select = c("word", "w_scr.x", "w_scr.x", "w_scr"))
w_afinn_scrs$avg_scr <-  rowMeans(subset(w_afinn_scrs, select = c(w_scr.x, w_scr.x, w_scr)), na.rm = TRUE)
w_afinn_scrs <- subset(w_afinn_scrs, avg_scr != 0)



w_scrs <- merge(afinn, w_afinn_scrs, by = "word", all = TRUE)
w_scrs <- subset(w_scrs, select = c("word", "new", "avg_scr"))
w_scrs$updated_scr <- ifelse(!is.na(w_scrs$avg_scr), w_scrs$avg_scr, w_scrs$new)

afinn_weighted <- subset(w_scrs, select = c("word", "updated_scr"))



afinn_word_upd <- twt_words %>%
  inner_join(afinn_weighted) %>%
  count(word, updated_scr, sort = TRUE) %>%
  ungroup()


# not that helpful.....
afinn_word_upd %>%
  mutate(polarity = ifelse(updated_scr > 0, "Positive", "Negative")) %>%
  group_by(polarity) %>%
  top_n(10, n) %>%
  ggplot(aes(reorder(word, n), n, fill = polarity)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~polarity, scales = "free_y") +
  labs(y = "Contribution to sentiment",
       x = NULL) +
  coord_flip() +
  ggtitle("Afinn Lexicon")





all_t_sa_a <- merge(tidy_twts2, afinn_weighted, by = "word")
all_t_sa_a$polarity <- ifelse(all_t_sa_a$updated_scr > 0, "positive", "negative")

all_sa_nest_a <- all_t_sa_a %>%
  group_by(unique_id) %>%
  nest(updated_scr)


all_sa_nest_a$sum_txt <- lapply(all_sa_nest_a$data, function(x) {
  x$sum_txt <- colSums(x, na.rm=T)
})

robust_sa <- merge(emoji_sa_f, all_sa_nest_a, by = "unique_id", all.x = TRUE)
table(is.na(robust_sa$sum_txt))

# FALSE  TRUE 
# 26026 15808 

robust_sa$char_n <- sapply(gregexpr("[A-z]\\W", robust_sa$txt_o), length)
final_txt_sa_r_w <- filter(robust_sa, !is.na(sum_txt))
final_txt_sa_r_w$txt_sent_scr <- as.numeric(final_txt_sa_r_w$sum_txt)/as.numeric(final_txt_sa_r_w$char_n)

# Output ------------------------------------------------------------------

save(final_txt_sa_r_w,file="data/processed/robust_sa_w.Rda")

