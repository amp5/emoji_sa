#########################################################################
#    File_name: exploratoy_data_analysis.R
#    Version: R version 3.2.4 (2016-03-10)
#    Date: 03_14_2017
#    Author: amp5
#    Purpose: exploratory analysis on data so far
#    Input_files: extracted_emojis.Rda
#    Output_files: TBD
#    Previous_files: extract_emoji_tw.R
#    Required by: TBD
#    Status: Working on
#    Machine: OSX Yosemite v. 10.10.5 (laptop)
#########################################################################
library(tidyverse)
library(maps)
library(stringr)


# Setting path and loading files ------------------------------------------
path <- "/Users/alexandraplassaras/Desktop/Spring_2017/QMSS_Thesis/QMSS_thesis" 
setwd(path)

# load extracted_emojis.Rda, var name is 'final'
load(file.choose())


# emoji_unicode.csv
emoji_unicode <- read.csv(file.choose())
names(emoji_unicode) <- tolower(names(emoji_unicode))

# emoji_counts.csv
emoji_typ <- read.csv(file.choose())

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

# e_typ_full <- merge(e_typ, emoji_unicode, by = 'unicode')
# e_typ_full <- subset(e_typ_full, select=-description)
# e_typ_f_ordered <- as_tibble(e_typ_full[order(count),])

#### cal the % for each emoji

top_10 <- head(e_typ, 10)


top_10 %>%
  ggplot(mapping = aes(x = reorder(name, percent), y = percent)) +
  geom_bar(stat="identity") +
  coord_flip() +
  geom_text(aes(label=round(percent, digits = 2)), vjust="inward", hjust = -.3, color="black", size=3.5)+
  theme_minimal() +
  ggtitle("Most Commonly Used Emojis") +
  labs(x = "Emoji Names", y = "Percent - (%)")





# remove outlier for face with tears of joy

