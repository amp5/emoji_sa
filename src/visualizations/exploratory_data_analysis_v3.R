#########################################################################
#    File_name: exploratory_data_analysis_v3.R
#    Version: R version 3.2.4 (2016-03-10)
#    Date: 03_27_2017
#    Author: amp5
#    Purpose: top 10 positive and negative emojis
#    Input_files: extracted_emojis.Rda, emoji_counts.csv
#    Output_files: commonly_used_e.pdf, US_map.pdf, twts_by_date.pdf, word_cloud.pdf
#    Previous_files: extract_emoji_tw.R
#    Required by: exploratoy_data_analysis_v2.R
#    Status: Working on
#    Machine: OSX Yosemite v. 10.10.5 (laptop)
#########################################################################
library(tidyverse)
library(stringr)
library(RColorBrewer)
library(NLP)
library(tm)

# Setting path and loading files ------------------------------------------
path <- "/Users/alexandraplassaras/Desktop/Spring_2017/QMSS_Thesis/QMSS_thesis" 
setwd(path)

# load extracted_emojis.Rda, var name is 'final'
load(file.choose())

# load e_twts_w_party.Rda, var name is 'only_party'
load(file.choose())

# load filtered.csv
all_twts <- read.csv(file.choose())

# emoji_counts.csv
emoji_typ <- read.csv(file.choose())

# emoji_counts_v2.csv
emoji_typ2 <- read.csv(file.choose())

# load "Emoji_Sentiment_Data.csv"
sa <- read.csv(file.choose())
# Code --------------------------------------------------------------------
(e_twts_num <- c(nrow(final)))
sa$Unicode.name <- tolower(sa$Unicode.name)

# Emoji Types -------------------------------------------------------------
e_typ2 <- subset(emoji_typ2, select=-c(X.1, bytes, rencoding, X))
e_typ2 <- e_typ2[c(4, 3, 2, 1, 5, 6)]
e_typ2 <- as_tibble(e_typ2)
e_typ2 <- e_typ2 %>%
  mutate(percent = count / e_twts_num)

# merge with scores....

e_typ2 <-  merge(e_typ2, sa, by.x = "name", by.y = "Unicode.name", all.x = TRUE)
e_typ2 <-  subset(e_typ2, select = -c(X, Emoji, Unicode.codepoint, Occurrences, 
                                          Position, Negative, Neutral, Positive, Unicode.block, p.neg,
                                          p.pos))
e_typ2_p <- filter(e_typ2, e_typ2$sent_score_updates > 0)
e_typ2_p <- e_typ2_p[with(e_typ2_p, order(- count)), ]
e_typ2_p$polarity <- "positive"

e_typ2_n <- filter(e_typ2, e_typ2$sent_score_updates < 0)
e_typ2_n <- e_typ2_n[with(e_typ2_n, order(- count)), ]
e_typ2_n$polarity <- "negative"


e_p <- head(e_typ2_p, 10)
e_n <- head(e_typ2_n, 10)

e_polarities <- rbind(e_p, e_n)


e_polarities %>%
  ggplot(mapping = aes(x = reorder(name, percent), y = percent, fill = polarity)) +
  geom_col(show.legend = FALSE) +
  coord_flip() +
  theme_minimal() +
  facet_wrap(~polarity, scales = "free_y") +
  ggtitle("Top 10 Used Emojis in Tweets with Party Affiliation") +
  labs(x = "Emoji Names", y = "Percent (%)") 




