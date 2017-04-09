#########################################################################
#    File_name: add_text_sentiment_robust_2.R
#    Version: R version 3.2.4 (2016-03-10)
#    Date: 04_03_2017
#    Author: amp5
#    Purpose: conduct sentiment analysis - robust sa with tf-idf
#    Input_files: sa_etwts.Rda
#    Output_files: twts_w_e_txt_sa.Rda
#    Previous_files: add_e_sentiment.R
#    Required by: TBD
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

# j_txt <- select(txt_party, -party)
# j_txt$group <- "all"


tidy_twts <- txt_party %>%
  unnest_tokens(word, txt_o, token = "ngrams", n = 2)


data("stop_words")
cleaned_twts <- tidy_twts %>%
  anti_join(stop_words)

cleaned_twts %>%
  count(word, sort = TRUE) 

afinn_word_c <- cleaned_twts %>%
  inner_join(afinn) %>%
  count(word, new, sort = TRUE) %>%
  ungroup()

# removing stop words doesn't work here since we've first created bigrams
# also can't add scores since we'd have to hand code sentiment for earch bi-gram


# For tf-idf - keep in all words, don't remove stop words


# attempt 1 ---------------------------------------------------------------

tidy_twts2 <- txt_party %>%
  unnest_tokens(word, txt_o) %>%
  count(unique_id, word, sort = TRUE) 

total_words_twt <- tidy_twts2 %>% group_by(unique_id) %>% summarize(total = sum(n))
tidy_twts2 <- left_join(tidy_twts2, total_words_twt)
tidy_twts2

twt_words <- tidy_twts2 %>%
  bind_tf_idf(word, unique_id, n)

twt_words %>%
  select(-c(total)) %>%
  arrange(desc(tf_idf))
# attempt 2 ---------------------------------------------------------------


tidy_twts2 <- txt_party %>%
  unnest_tokens(word, txt_o) %>%
  count(unique_id, word, sort = TRUE) 

total_words_twt <- tidy_twts2 %>% group_by(party) %>% summarize(total = sum(n))
tidy_twts2 <- left_join(tidy_twts2, total_words_twt)
tidy_twts2

twt_words <- tidy_twts2 %>%
  bind_tf_idf(word, party, n)




# attempt 3 ---------------------------------------------------------------
tidy_twts2 <- txt_party %>%
  unnest_tokens(word, txt_o) %>%
  count(party, word, sort = TRUE) 

total_words_twt <- tidy_twts2 %>% group_by(party) %>% summarize(total = sum(n))
tidy_twts2 <- left_join(tidy_twts2, total_words_twt)
tidy_twts2


twt_words <- tidy_twts2 %>%
  bind_tf_idf(word, party, n)

twt_words %>%
  select(-c(total)) %>%
  arrange(desc(tf_idf))






reordered <- twt_words %>%
  select(-total) %>%
  arrange(desc(tf_idf))

reordered %>%
  top_n(5, tf_idf) %>%
  ggplot(aes(reorder(word,tf_idf), tf_idf, fill = party)) +
  geom_col() +
 scale_fill_manual(values=c("#56B4E9","#9999CC", "#CC6666")) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  ylab("Weighted Frequency (tf_idf) ") +
  xlab("Top Words") 



# Stopped Here - Need to Re-Think -----------------------------------------



afinn <- get_sentiments("afinn")
afinn$new <- afinn$score/5

# this lexicon did not have trump as term
# twtsentiment_a <- cleaned_twts %>%
#   inner_join(afinn) %>%
#   count(word, index = unique_id %/% 80, new) %>%
#   spread(sentiment, n, fill = 0)

afinn_word_c <- twt_words %>%
  inner_join(afinn) %>%
  count(word, new, sort = TRUE) %>%
  ungroup()

afinn_w_weight <- merge(afinn_word_c, twt_words, by)



afinn_word_c %>%
  mutate(polarity = ifelse(new > 0, "Positive", "Negative")) %>%
  group_by(polarity) %>%
  top_n(10, n) %>%
  ggplot(aes(reorder(word, n), n, fill = polarity)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~polarity, scales = "free_y") +
  labs(y = "Contribution to sentiment",
       x = NULL) +
  coord_flip() +
  ggtitle("Afinn Lexicon")

all_t_sa_a <- merge(tidy_twts, afinn, by = "word")
all_t_sa_a$polarity <- ifelse(all_t_sa_a$new > 0, "positive", "negative")

all_sa_nest_a <- all_t_sa_a %>%
  group_by(unique_id) %>%
  nest(new)

all_sa_nest_a$sum_txt <- lapply(all_sa_nest_a$data, function(x) {
  x$sum_txt <- colSums(x, na.rm=T)
})

robust_sa <- merge(emoji_sa_f, all_sa_nest_a, by = "unique_id", all.x = TRUE)
table(is.na(robust_sa$sum_txt))

# FALSE  TRUE 
# 26026 15808 

robust_sa$char_n <- sapply(gregexpr("[A-z]\\W", robust_sa$txt_o), length)
final_txt_sa_r <- filter(robust_sa, !is.na(sum_txt))
final_txt_sa_r$txt_sent_scr <- as.numeric(final_txt_sa_r$sum_txt)/as.numeric(final_txt_sa_r$char_n)

# Output ------------------------------------------------------------------

save(final_txt_sa_r,file="data/processed/robust_sa.Rda")

