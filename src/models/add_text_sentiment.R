#########################################################################
#    File_name: add_text_sentiment.R
#    Version: R version 3.2.4 (2016-03-10)
#    Date: 03_18_2017
#    Author: amp5
#    Purpose: conduct sentiment analysis - simple sa
#    Input_files: sa_etwts.Rda
#    Output_files: TBD
#    Previous_files: add_e_sentiment.R
#    Required by: TBD
#    Status: Working on
#    Machine: OSX Yosemite v. 10.10.5 (laptop)
#########################################################################
library(tidyverse)
library(dplyr)
library(stringr)
library(tidytext)
library(wordcloud)
library(tidyr)
library(reshape2)


# Setting path and loading files ------------------------------------------
path <- "/Users/alexandraplassaras/Desktop/Spring_2017/QMSS_Thesis/QMSS_thesis" 
setwd(path)

# load sa_etwts.Rda
load(file.choose())

emoji_sa_f %>%
  mutate(txt_o = sapply(emoji_sa_f$text,function(row) iconv(row, "latin1", "ASCII", sub=""))) 

emoji_sa_f$txt_o <- gsub('http.*\\s*', '', emoji_sa_f$txt_o)
emoji_sa_f$txt_o <- gsub('&amp;', '', emoji_sa_f$txt_o)
emoji_sa_f$txt_o <- gsub('[@!#$%^&*()|_+=:?.,;]', '', emoji_sa_f$txt_o)

just_text <- select(emoji_sa_f, c(unique_id, txt_o))
just_text <- as_tibble(just_text)

tidy_twts <- just_text %>%
  unnest_tokens(word, txt_o)

data("stop_words")
custom_stop_words <- bind_rows(data_frame(word = c("trump"), 
                                          lexicon = c("custom")), 
                               stop_words)

custom_stop_words



cleaned_twts <- tidy_twts %>%
  anti_join(custom_stop_words)

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
  with(wordcloud(word, n, max.words = 100))



cleaned_twts %>%
  inner_join(bing) %>%
  count(word, sentiment, sort = TRUE) %>%
  acast(word ~ sentiment, value.var = "n", fill = 0) %>%
  comparison.cloud(colors = c("#F8766D", "#00BFC4"),
                   max.words = 200)

tidy_twts


bing_word_c %>%
  group_by(sentiment) %>%
  top_n(10) %>%
  ggplot(aes(reorder(word, n), n, fill = sentiment)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~sentiment, scales = "free_y") +
  labs(y = "Contribution to sentiment",
       x = NULL) +
  coord_flip()


sent_scrs <- tidy_twts %>%
  inner_join(bing)

sent_scrs$score <- ifelse(sent_scrs$sentiment == "positive", 1, 
                          ifelse(sent_scrs$sentiment == "negative", -1, 0))
  





# Not working below…. -----------------------------------------------------
tidy_tweets <- as_tibble(tidy_twts)
sent_scores <- as_tibble(sent_scrs)

all_t_sa <- merge(tidy_tweets, sent_scrs, by = word, all.x = TRUE)

all_t_sa <- left_join(tidy_tweets, sent_scrs, by = word)
