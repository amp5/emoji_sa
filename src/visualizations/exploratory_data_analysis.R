#########################################################################
#    File_name: exploratoy_data_analysis.R
#    Version: R version 3.2.4 (2016-03-10)
#    Date: 03_14_2017
#    Author: amp5
#    Purpose: exploratory analysis on data so far
#    Input_files: extracted_emojis.Rda, emoji_counts.csv
#    Output_files: commonly_used_e.pdf, US_map.pdf, twts_by_date.pdf, word_cloud.pdf
#    Previous_files: extract_emoji_tw.R
#    Required by: exploratoy_data_analysis_v2.R
#    Status: Complete
#    Machine: OSX Yosemite v. 10.10.5 (laptop)
#########################################################################
library(tidyverse)
library(maps)
library(stringr)
library(lubridate)
library(RColorBrewer)
library(wordcloud)
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
# Code --------------------------------------------------------------------
wrk_d <- final

(e_twts_num <- c(nrow(final)))
all_twts_num <- c(1816475)

type_o_twt <- c("all", "with_emojis")
twt_nums <- c(all_twts_num, e_twts_num)
(twt_counts <- data.frame(type_o_twt,  twt_nums))

# Mapping -----------------------------------------------------------------
ts <- data.frame(x = as.numeric(wrk_d$place_lon), y = as.numeric(wrk_d$place_lat))

## plot out the usage on world map
map("world", col="#E8E8E8", fill=TRUE, bg="white", lwd=0.4, interior=TRUE)
points(ts, pch=16, cex=.10, col="red")
# appears that few tweets are in Europe and Guam(?) with X, Y or place_lat, place_lon

# plot out the usage on US map
xlim <- c(-124.738281, -66.601563)
ylim <- c(24.039321, 50.856229)
map("world", col="#E8E8E8", fill=TRUE, bg="white", lwd=0.4, xlim=xlim, ylim=ylim, interior=TRUE)
points(ts, pch=16, cex=.10, col="#1DA1F2")
map("state", fill=FALSE, bg="white", add = TRUE)
title("Presidential Primary Tweets with Emojis, 2016")


# Emoji Types -------------------------------------------------------------
e_typ <- subset(emoji_typ, select=-c(X.1, bytes, rencoding, X))
e_typ <- e_typ[c(4, 3, 2, 1, 5, 6)]
e_typ <- as_tibble(e_typ)
e_typ <- e_typ %>%
  mutate(percent = count / e_twts_num)


top_10 <- head(e_typ, 10)
top_10$group <-  "emoji_tweets"

top_10 %>%
  ggplot(mapping = aes(x = reorder(name, percent), y = percent)) +
  geom_bar(stat="identity") +
  coord_flip() +
  geom_text(aes(label=round(percent, digits = 2)), vjust="inward", hjust = -.1, color="black", size=3.5)+
  theme_minimal() +
  ggtitle("Most Commonly Used Emojis in Emoji Tweets") +
  labs(x = "Emoji Names", y = "Percent (%)")
ggsave("reports/figures/commonly_used_e.pdf")

# ----------

e_typ2 <- subset(emoji_typ2, select=-c(X.1, bytes, rencoding, X))
e_typ2 <- e_typ2[c(4, 3, 2, 1, 5, 6)]
e_typ2 <- as_tibble(e_typ2)
e_typ2 <- e_typ2 %>%
  mutate(percent = count / e_twts_num)


top_10_2 <- head(e_typ2, 10)
top_10_2$group <-  "e_twts_p"

top_10_2 %>%
  ggplot(mapping = aes(x = reorder(name, percent), y = percent)) +
  geom_bar(stat="identity") +
  coord_flip() +
  geom_text(aes(label=round(percent, digits = 2)), vjust="inward", hjust = -.1, color="black", size=3.5)+
  theme_minimal() +
  ggtitle("Most Commonly Used Emojis in Emoji Tweets with Party Affiliation") +
  labs(x = "Emoji Names", y = "Percent (%)")
ggsave("reports/figures/commonly_used_e_p.pdf")





# Plot tweets by date:
twt_date_e <- as_tibble(table(factor(format(wrk_d$created))))
names(twt_date_e) <- c("date", "num")
twt_date_e$date <- as.Date(mdy(twt_date_e$date, tz = "America/New_York"))
twt_date_e$group <- "only_emoji"

twt_date_p <- as_tibble(table(factor(format(only_party$created))))
names(twt_date_p) <- c("date", "num")
twt_date_p$date <- as.Date(mdy(twt_date_p$date, tz = "America/New_York"))
twt_date_p$group <- "emoji_w_party"



twt_date_a <- as_tibble(table(factor(format(all_twts$created))))
names(twt_date_a) <- c("date", "num")
twt_date_a$date <- as.Date(mdy(twt_date_a$date, tz = "America/New_York"))
twt_date_a$group <- "all_tweets"

twt_date <- rbind(twt_date_e, twt_date_p)


# overall tweets - #999999
# e_tweets - #1DA1F2
# party tweets - purple color...

c('#1DA1F2', "#999999" )
# compare tweets, e_tweets and party_twts
ggplot(twt_date, aes(x=date, y = num, color = group)) + 
  geom_line() +
  geom_point() + 
  theme_minimal() +
  theme(axis.text.x=element_text(angle=90)) +
  scale_x_date(date_breaks = ("5 day"), date_labels = "%b %d") +
  ggtitle("Tweets by Date - Emoji Tweets vs. Emoji Tweets with Party") +
  labs(x = "Date", y = "Count of Tweets")
ggsave("reports/figures/twts_by_date_e_p.pdf")




ggplot(twt_date_a, aes(x=date, y = num)) + 
  geom_line(colour = "#1DA1F2") +
  geom_point(colour = "#1DA1F2") + 
  theme_minimal() +
  theme(axis.text.x=element_text(angle=90)) +
  scale_x_date(date_breaks = ("5 day"), date_labels = "%b %d") +
  ggtitle("All Tweets by Date") +
  labs(x = "Date", y = "Count of Tweets")
ggsave("reports/figures/twts_by_date_a.pdf")

# Word Cloud --------------------------------------------------------------
tc <- function(filename){
  filename$text <- sapply(filename$text,function(row) iconv(row, "latin1", "ASCII", sub=""))
  TweetCorpus<-paste(unlist(filename$text), collapse =" ")
  TweetCorpus <- Corpus(VectorSource(TweetCorpus))
  TweetCorpus <- tm_map(TweetCorpus, removePunctuation)
  TweetCorpus <- tm_map(TweetCorpus, removeWords, stopwords("english"))
  #TweetCorpus <- tm_map(TweetCorpus, stemDocument)
  TweetCorpus <- tm_map(TweetCorpus, content_transformer(tolower),lazy=TRUE)
  TweetCorpus <- tm_map(TweetCorpus, PlainTextDocument)
  TweetCorpus <- tm_map(TweetCorpus, removeWords, c("https",
                                                    "https...",
                                                    "via",
                                                    "use",
                                                    "just",
                                                    "think",
                                                    "say",
                                                    "that",
                                                    "its",
                                                    "this",
                                                    "will",
                                                    "the",
                                                    "lol", 
                                                    "now", 
                                                    "one", 
                                                    "still", 
                                                    "whi",
                                                    "amp",
                                                    "let",
                                                    "ill",
                                                    "come",
                                                    "and",
                                                    "realli",
                                                    "your",
                                                    "you",
                                                    "for",
                                                    "much",
                                                    "see",
                                                    "got",
                                                    "can",
                                                    "get"
  ))
  return(TweetCorpus)
}

wc_t <- function(filename){
  return(wordcloud(filename, min.freq = 400,  max.words = 1000, random.order = FALSE, colors = brewer.pal(4, "Dark2")))
}

names(only_party)[2] <-  "test"
wrk_d <- only_party

wc_t(tc(wrk_d))



