#########################################################################
#    File_name: add_text_sentiment.R
#    Version: R version 3.2.4 (2016-03-10)
#    Date: 03_18_2017
#    Author: amp5
#    Purpose: conduct sentiment analysis - simple sa
#    Input_files: sa_etwts.Rda
#    Output_files: twts_w_e_txt_sa.Rda
#    Previous_files: add_e_sentiment.R
#    Required by: simple_results.R
#    Status: Completed
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

bing <- get_sentiments("bing")
# removing trump from lexicon - used as a positive sentiment
bing <- bing[-6177, ] 
twtsentiment <- cleaned_twts %>%
  inner_join(bing) %>%
  count(word, index = unique_id %/% 80, sentiment) %>%
  spread(sentiment, n, fill = 0) %>%
  mutate(sentiment = positive - negative)

bing_word_c <- cleaned_twts %>%
  inner_join(bing) %>%
  count(word, sentiment, sort = TRUE) %>%
  ungroup()

bing_word_c

bing_word_c %>%
  filter(n > 200) %>%
  mutate(n = ifelse(sentiment == "negative", -n, n)) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(word, n, fill = sentiment)) +
  geom_bar(stat = "identity") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  ylab("Contribution to sentiment")

cleaned_twts %>%
  count(word) %>%
  with(wordcloud(word, n, max.words = 200))

cleaned_twts %>%
  inner_join(bing) %>%
  count(word, sentiment, sort = TRUE) %>%
  acast(word ~ sentiment, value.var = "n", fill = 0) %>%
  comparison.cloud(colors = c("#F8766D", "#00BFC4"),
                   max.words = 200)

tidy_twts

ttl <- nrow(bing_word_c)

bing_word_c %>%
  group_by(sentiment) %>%
  top_n(10) %>%
  ggplot(aes(reorder(word, n), n/ttl, fill = sentiment)) +
  geom_col(show.legend = FALSE) +
  geom_text(aes(label=round(n/ttl, digits = 2), y =mean(range(n/ttl)))) +
  facet_wrap(~sentiment, scales = "free_y") +
  labs(y = "Contribution to sentiment",
       x = NULL) +
  coord_flip()

sent_scrs <- tidy_twts %>%
  inner_join(bing)

all_t_sa <- merge(tidy_twts, bing, by = "word")
all_t_sa$score <- ifelse(all_t_sa$sentiment == "positive", 1, ifelse(all_t_sa$sentiment == "negative", -1, 0))

all_sa_nest <- all_t_sa %>%
  group_by(unique_id) %>%
  nest(score)

all_sa_nest$sum_txt <- lapply(all_sa_nest$data, function(x) {
  x$sum_txt <- colSums(x, na.rm=T)
})

simple_sa <- merge(emoji_sa_f, all_sa_nest, by = "unique_id", all.x = TRUE)

table(is.na(simple_sa$sum_txt))

# FALSE  TRUE 
# 24457 17377 

simple_sa$char_n <- sapply(gregexpr("[A-z]\\W", simple_sa$txt_o), length)

final_txt_sa <- filter(simple_sa, !is.na(sum_txt))
final_txt_sa$txt_sent_scr <- as.numeric(final_txt_sa$sum_txt)/as.numeric(final_txt_sa$char_n)

# Output ------------------------------------------------------------------

save(final_txt_sa,file="data/processed/twts_w_e_txt_sa.Rda")

