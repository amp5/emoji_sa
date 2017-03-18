#########################################################################
#    File_name: exploratoy_data_analysis.R
#    Version: R version 3.2.4 (2016-03-10)
#    Date: 03_14_2017
#    Author: amp5
#    Purpose: exploratory analysis on data so far
#    Input_files: extracted_emojis.Rda
#    Output_files: commonly_used_e.pdf, US_map.pdf
#    Previous_files: extract_emoji_tw.R
#    Required by: TBD
#    Status: Working on
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

# emoji_counts.csv
emoji_typ <- read.csv(file.choose())


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

top_10 %>%
  ggplot(mapping = aes(x = reorder(name, percent), y = percent)) +
  geom_bar(stat="identity") +
  coord_flip() +
  geom_text(aes(label=round(percent, digits = 2)), vjust="inward", hjust = -.1, color="black", size=3.5)+
  theme_minimal() +
  ggtitle("Most Commonly Used Emojis") +
  labs(x = "Emoji Names", y = "Percent (%)")
ggsave("reports/figures/commonly_used_e.pdf")

# Plot tweets by date:
twt_date <- as_tibble(table(factor(format(wrk_d$created))))
names(twt_date) <- c("date", "num")

twt_date$date <- as.Date(mdy(twt_date$date, tz = "America/New_York"))


ggplot(twt_date, aes(x=date, y = num)) + 
  geom_line(colour = "#999999") +
  geom_point(colour="#1DA1F2") + 
  theme_minimal() +
  theme(axis.text.x=element_text(angle=90)) +
  scale_x_date(date_breaks = ("4 day"), date_labels = "%b %d") +
  ggtitle("Emoji Tweets by Date") +
  labs(x = "Date", y = "Count of Tweets")
ggsave("reports/figures/twts_by_date.pdf")


# Word Cloud, cuz why not
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

wc_t(tc(wrk_d))



