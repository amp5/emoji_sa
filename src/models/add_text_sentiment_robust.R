#########################################################################
#    File_name: add_text_sentiment_robust.R
#    Version: R version 3.2.4 (2016-03-10)
#    Date: 03_29_2017
#    Author: amp5
#    Purpose: conduct sentiment analysis - robust sa
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

just_text <- select(emoji_sa_f, c(unique_id, txt_o))
just_text <- as_tibble(just_text)

tidy_twts <- just_text %>%
  unnest_tokens(word, txt_o)

data("stop_words")
cleaned_twts <- tidy_twts %>%
  anti_join(stop_words)

cleaned_twts %>%
  count(word, sort = TRUE) 

afinn <- get_sentiments("afinn")
# this lexicon did not have trump as term
twtsentiment_a <- cleaned_twts %>%
  inner_join(afinn) %>%
  count(word, index = unique_id %/% 80, score) %>%
  spread(sentiment, n, fill = 0)

afinn_word_c <- cleaned_twts %>%
  inner_join(afinn) %>%
  count(word, score, sort = TRUE) %>%
  ungroup()

afinn_word_c
 
afinn_word_c %>%
  filter(n > 200) %>%
  mutate(word = reorder(word, score)) %>%
  mutate(polarity = ifelse(score > 0, "Positive", "Negative")) %>%
  ggplot(aes(word, score, fill = polarity)) +
  geom_bar(stat = "identity") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  ylab("Contribution to sentiment") +
  ggtitle("Afin Lexicon") 

cleaned_twts %>%
  count(word) %>%
  with(wordcloud(word, n, max.words = 200))

# Not very helpful as a visualization
cleaned_twts %>%
  inner_join(afinn) %>%
  count(word, score, sort = TRUE) %>%
  mutate(polarity = ifelse(score > 0, "Positive", "Negative")) %>%
  acast(word ~ polarity, value.var = "n", fill = 0) %>%
  comparison.cloud(colors = c("#F8766D", "#00BFC4"),
                   max.words = 200)

afinn_word_c %>%
  mutate(polarity = ifelse(score > 0, "Positive", "Negative")) %>%
  group_by(polarity) %>%
  top_n(10, n) %>%
  ggplot(aes(reorder(word, n), n, fill = polarity)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~polarity, scales = "free_y") +
  labs(y = "Contribution to sentiment",
       x = NULL) +
  coord_flip() +
  ggtitle("Afin Lexicon")

all_t_sa_a <- merge(tidy_twts, afinn, by = "word")
all_t_sa_a$polarity <- ifelse(all_t_sa_a$score > 0, "positive", "negative")

all_sa_nest_a <- all_t_sa_a %>%
  group_by(unique_id) %>%
  nest(score)

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

