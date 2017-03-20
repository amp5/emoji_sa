<p align="center">
  <b>3/19/17 - Sentiment Analysis Half Done</b>
</p>

Since the last note I've complted the sentiment analysis for the emojis. The equation I used is on page 15 of https://arxiv.org/pdf/1509.07761.pdf. 

uses Laplace estimation
p-, p0, p1

negativity = (-1 * p_neg + 1)/(occurances + 3)
positivity = (p_pos + 1)/(occurances + 3)
sentiment = positivity + negativity

Next step is to figure out best way to compute sentiment analysis for text.

Considering, (-1 * p_neg)/occurances and  (p_pos)/occurances for text but need to make sure that I can compare two results with one another. 

4 major text lexicons:
- Bing Liu Opinion (https://github.com/mjhea0/twitter-sentiment-analysis/tree/master/wordbanks)
- MPQA Subjectivity (http://mpqa.cs.pitt.edu/lexicons/subj_lexicon/)
- Harvard General Inquire
- SentiWordNet

This website talking about creating my own lexicon as well as outlines above lexicons: http://sentiment.christopherpotts.net/lexicons.html#mpqa

**Further Study:** Look at the differences between lexicons and compare with emoji sentiments. Also create own lexicon using all 4 of the above. 

**Note:** The emoji part of code only focuses on single character emojis. Not double character emojis. See Novak's Table 7 for refresher. That study also didn't look at double character emojis. 

**Note:** A limitation to add to paper is that the emoji sentiment database from novak calculated sentiment using sometimes very small sample sizes (i.e. n = 5). So that is something to keep in mind. Used Laplace to try to approximate but something worth noting. 


Also, should read: https://people.cs.pitt.edu/~wiebe/pubs/papers/emnlp05polarity.pdf
Consider using this script to do text analysis: https://github.com/mjhea0/twitter-sentiment-analysis/blob/master/R/sentiment_new.R

Look at this for ides on how to visualize my data: http://nl.ijs.si/janes/wp-content/uploads/2016/09/CMC2016_kralj_novak.pdf

<p align="center">
  <b>3/14/17 - EDA</b>
</p>

Focus for now will be EDA - exploratory data analysis. Below are things that I shoudl answer / visualize:
- How many tweets have emojis vs not (bar chart)
- top 10 or 20 most commonly used emojis
- map tweets with emojis (are any outside US like before?)
- average number of emojis per tweet. Or the overall distribution
- when tweet created (scatter plot of num tweets by day)
- which language (lang) tweet 
- how many tweets with emojis and how many unique users
- average amount of tweets per user
- verified vs not verified emoji tweets

**Note** It appears that the American flag is not being captured by emoji extraction. Last col in image below represents unique emoji_id but this emoji returns NA. 
![](https://cloud.githubusercontent.com/assets/5368361/23931625/454d699a-0909-11e7-9731-b9344becdbd0.png)

**Note** Emojis with various skin color options are counted as two emojis for one image but only one emoji_id is identified..... Usefult to add to paper somewhere
![](https://cloud.githubusercontent.com/assets/5368361/23931612/3b8683f6-0909-11e7-8370-25ebe5388530.png)

**Note** Also, some emojis were not identified but overall I think it did a fairly good job... Could have been emoji not in the 800~ list
![](https://cloud.githubusercontent.com/assets/5368361/23931608/36a9979c-0909-11e7-98c0-edbae274aa76.png)


**Reference**
- Used https://rpubs.com/twgrant/132808 for code to make maps
- Used https://github.com/today-is-a-good-day/Emoticons/blob/master/postEmoticons.R and http://opiateforthemass.es/articles/emoticons-in-R/ to help match emojis in tweets with correct emoji in dictionary


- [ ] Use QGIS to come up with nice maps than R's maps or ggplot


<p align="center">
  <b>3/13/17 - Revamp</b>
</p>

First off, I made sure that my code is reproducible by deleting my R environment and redoing all of the code from scratch. Things I have learned from the data so far:
- currently contains no retweets (per var retweeted)
- currently contains no tweets with country_code outside of US (despite a few tweet coordinates showing up in Europe and Asia)
- there are 237,499 unique users in large data set and [INSERT EMOJI_TWEET USERS]
- there are 1,816,475 original tweets and 93,411 tweets with emojis in them (~ 5% of all tweets) which is similar to average geolocated ratio but a bit surprising here. Would have thought there were more emojis used. But then again these tweets are about the primaries...
- there were no instances of the following vars: `retweet_count` `favorited` `fav_count` `protected `
- all tweets had the following vars: `truncated`, `geo_enabled`
- The emoji dictionary has 842 different emojis and the code I have now has found 727 different emojis in the tweets
- decided to use `place_lat` and `place_lon` over the other two pairs of coordinate data because 1) `lat` and `lon` had missing values whereas place vars didn't and 2) while `X` and `Y` didn't have missing values only some of the pairs matched with theplace vars. When i attempted to figure out what the difference between the two vars was I couldn't find the right documentation and all of the tutorials and articles I found online used the place vars to map coordinated and not the X/Y vars. So I'll stick with the trend until told otherwise. 
- `lang` is not a good var to filter on if looking for all tweets in english. There were a total of 45 different languages identified for all tweets (1.8 mil tweets) and after checking a few examples found that this var does not equate to the tweet not being in English. 
- I originally had the date-time information for each tweet but I think I will only need the date so the current data file only has date and not time for each tweet
- Of the huge data set there were 24,453 verified tweets and 1,792,022 unverified tweets. Potentially something to look into further with emoji tweets?

Still trying to figure out this whole not captured all emojis in a tweet thing. And have all the data I need in a tidy data set. TBD on that part.

<p align="center">
  <b>3/06/17 - Thinking about...</b>
</p>

- filter only US for all tweets and map before emoji to see if I can get all US tweets only
- when looking for emoji sentiment score, use a left_join() with x being my data and y being the file from emoji SA
- check encoding of emojis and text with writeLines()
- create heatmap of tweets for location? maybe?
- remove retweets in orig dataset
- map SA of text vs emoji in QGIS (easier program to do this)
- when I do text analysis, make note that in paper talk about how this removes any emoticons and any punctuation marks that might give more nuancd sentiment. So losing information. 
- can find no reason at the moment where I'd need the time for each tweet. will use date only and use lubridate packagen  and as_date() to convert date-time to date
- add var path on each file, make sure my code is reproducible and my working env is cleared when project is closed
- define my functions - step by step, inputs and arguments, outputs, tests....

<p align="center">
  <b>2/26/17 - Summary of next steps</b>
</p>

- [x] turn dataframe into tibble
- [x] remove duplicate tweets
- [x] check that all code it working (remove save to environment when I close Rstudio)
- [x] run emoji extraction again
- [x] map emoji only tweets to see location is US only (smaller num of euro and guam but still there.....)

<p align="center">
  <b>2/26/17 - Identify Emoji Tweets - Continued....</b>
</p>

Spent all of ysterday and today trying to extract which tweets had emojis and which didn't and then counting the differnt types of tweets. Was planning on doing that in that order but ended up finding code on internet in the reverse order. That is with a test data set I  was able to identify which emojis in a tweet were counted and then I refined the large data set to look at only tweets with emojis present. For the most part I think I was able to do this. Out of 1.8 million tweets (1816475 to be exact), I reduced my working df to one of 152,516 tweets. That includes retweets AND some tweets that don't have emojis but have special characters. I'll refine this after I calculate which emojis are in which tweets. 

First though I need to do this:
- [x] will need to confirm that duplicate tweets are removed.... (in main dataset -> wrk_d)

1. Then after I do that I will re-run my code to generate 'emoji_twts'.
2. From there I will run the rest of the code I have in file 'extract_emoji_tw.R'
3. Then I will fix ranking section
4. From there do some basic descriptive analysis on emojis present
5. Do the dame descriptive work for the text.

There appears to be a problem with the counting. It isn;t with the code I don't think but with the recoding that R does for emojis
![](https://cloud.githubusercontent.com/assets/5368361/23345620/0d6b86b2-fc5f-11e6-975b-728f08a57a2a.png)

The picture above shows some sample data I'm working with. Row 23 visually has 5 smiling crying faces. but the converted emoji into bytes isn't the same sequence of code 5 times. The first sequence "<f0><9f><98><ad>" is not the same as the others "<f0><9f><98><82>". At this point I don't know why it is doing that but when I count them I'm only getting three for that one. And one for the crying cat face (row) 13. At the moment I will keep moving forward with the code and make note of this in my report so the sentiment will not be 100% accurate for the emoji because it will be losing the frequency for the emojis but so far it appears to be at least counting that some of the same emoji exists in a tweet. And it is also counting the unique emojis. 

**References**
- https://www.slideshare.net/rdatamining/text-mining-with-r-an-analysis-of-twitter-data use for text analysis - exploratory
- https://cran.r-project.org/web/packages/emojifont/vignettes/emojifont.html and maybe https://guangchuangyu.github.io/2015/12/use-emoji-font-in-r/ use for ggplot2 when graphing emoji
- Used http://opiateforthemass.es/articles/emoticons-in-R/ to convert the emojis into rencoding in order to classify
- Used http://miningthedetails.com/blog/r/IdentifyEmojiInTweets/ to help with emoji calculation
- https://prismoji.com/2017/02/06/emoji-data-science-in-r-tutorial/ Use for emoji visualizations

<p align="center">
  <b>2/25/17 - Identify Emoji Tweets</b>
</p>
**Note to self:** be careful what you name things. And then remove dfs you don't need anymore from working directory
- [x] need to rearrange src files. shouldn't all be in data folder

**References:**
- Used ![this tutorial](https://prismoji.com/2017/02/06/emoji-data-science-in-r-tutorial/) to come up with emoji dictionary. Only 842 emojis and are slightly out of date with the latest and greatest emojis. BUT it should be enough for my purposes
- https://github.com/PRISMOJI/emojis/blob/master/2017.0206%20emoji%20data%20science%20tutorial/R%20Code%20Parts%202-4%20(PUB).R used the code to create emoji dictionary and attempt to create matrix calculating emoji counts
- https://github.com/laurenancona/twimoji/tree/master/twitterEmojiProject took emoji dictionary and combined with others
- http://apps.timwhitlock.info/unicode/inspect/hex/1F614 used this to confirm emoji in tweet
- https://github.com/twitter/twemoji + http://miningthedetails.com/blog/r/IdentifyEmojiInTweets/ maybe use in future?



<p align="center">
  <b>2/22/17 - Brainstorming data transformations</b>
</p>

1. create new column for T/F or binary variable representing whether tweet has emoji - use contains 
2. create subset of only tweets with emoji and text in them


<p align="center">
  <b>2/8/17 - Refining Data Set</b>
</p>
- Current raw filtered data has 50 variables:

 ` "X.1"                       "id_str"                   
  "idx"                       "text"                     
  "created_at"                "user_lang"                
  "truncated"                 "retweeted"                
 "favorite_count"            "verified"                 
 "user_id_str"               "source"                   
 "followers_count"           "in_reply_to_screen_name"  
 "location"                  "retweet_count"            
 "favorited"                 "utc_offset"               
"statuses_count"            "description"              
 "friends_count"             "user_url"                 
 "geo_enabled"               "in_reply_to_user_id_str"  
"lang"                      "user_created_at"          
 "favourites_count"          "name"                      "time_zone"                 "in_reply_to_status_id_str"
 "protected"                 "listed_count"             
 "place_lon"                 "expanded_url"             
 "place_id"                  "full_name"                
 "lat"                       "country_code"             
"place_name"                "url"                      
"country"                   "lon"                     "place_type"                "place_lat"                
 "X"                         "Y"                        
 "STATEFP"                   "NAME"                     
"COUNT"                     "user_id"  `

- will keep only the following:
  - user_id, id_str, created_at, text, geo_enabled, country_code, X, Y, place_lat, lon, lat, place_lon
- from here will verify that all tweets have been sent within US
  - final working dataset will include the following:
    - user_id, id_str, created_at, text
    - will want to create 2 new vars with confirmed latitude and longitude using the 8 variables above referring to location


<p align="center">
  <b> 2/2/17 and 2/3/17 - Deidentifying and Uploading Raw data</b>
</p>
- worked on de-identifying twitter data. Replaces screen_name variable with unique user_id in raw data.
- stored key of sreen_name and user_id in .gitignore so I would still have access to it on my local computer and it could be stored with project while preventing others from seeing this info
- will most likely use this information when visualizing results. Perhaps seeing what kind of sentiments each candidate had for text and emoji overall
- de-identified raw data was too large to upload onto github. Have a merge conflict and needed to resolve this. Ended up saving zip file of raw data onto dropbox and posting a link to page on github in data section.
- decided against removing lon and lat data since main identifying data from raw data set was already replaced.
- next after cleaning up my data file will need to find out whether I can upload this new cleaned file onto github. Must be under 100 MB or under 27 MB - saw two different messages on github about this. TBD

<p align="center">
  <b> 1/31/17 and 2/1/17  - Adding Additional Information</b>
</p>

- Methodology paper and 2 page paper on data have been added. These will be used to structure analysis and to write final thesis. 
- Currently thinking about how necessary it is to remove personal identification from scraped Tweets. Professor suggested to remove usernames but then I would be removing a layer of potential informaiton. As in which tweets Trump or Clinton tweeted. Also location data like lat & lon is needed for me to filter out US only sent tweets but could be used to identify people with other information. 
- should I add QMSS_thesis.Rproj to my gitignore? Not clear on what data Rproj stores on user. 


<p align="center">
  <b> 1/30/17 - Planning</b>
</p>


For now, here is a brief roadmap of the project:

| Main Task  | Sub Task | Completed Definition  | Completed |Date Completed |
| ------------- | ------------- | ------------- | ------------- |------------- |
| ETL | Input data  | Able to load and display  | Y  | 2/3/17 |
| ETL  | Clean data  | Remove unnecessary columns  | Y  | 2/8/17 |
| ETL  | Reshape data  | Filter US only  | W  | 2/8/17 |
| ETL  | Extract data  | only Emoji Tweets  | W  | N/A |
| Exploration  | Descriptives  | Distribution of tweets per candidate, Num of users, Avg tweet per user  | N  | N/A |
| Exploration  | Visualization  | Images of above  | N  | N/A |
| Analysis  | Modeling  | Sentiment Analysis - Text and Emojis  | N | N/A |
| Output  | Graphs  | Difference in sentiment graphs, SNA graphs, top (-) and (+) words & emojis   | N  | N/A |
| Output  | Report  | Thesis paper  | N  | N/A |
| Output  | Presentation  | 10 slides or less on whole project v. website  | N  | N/A |

Last updated: 1/30/17


General Overview of file organization:
- **data**
  - **raw**  *<- original, immutable data dump*
    - Twitter data
  - **external**  *<- data from third party sources*
    - emoji data from outside research
  - **interim**  *<- intermediate transformed data*
    - filtered twitter data to include only necessary columns and only US data
    - cleaned emoji data with only necessary information (form of dictionary?)
  - **processed**  *<- final processed data set*
    - one data set with all necessary tweet data and binary values for particular emojis per tweet
- **src**
  - **data** *<- code to read/munge raw data*
    - read in Twitter data
    - read in emoji data
  - **features** *<- code to transform/append data*
    - clean twitter data
    - clean emoji data
  - **models** *<- code to analyze the data*
    - conduct sentiment analysis on both text and emoji on each tweet
    - analyize difference between both groups and compare within tweet
  - **visualizations** *<- gode to generate visualizations*
    - create basic exploratory visualziations (Descriptive Graphs, etc.)
    - create visuals based on results (Sentiment Analysis)
- **reports**
  - **documents** *<- documents synthesizing analysis*
    - data description
    - literature review
    - methodology
    - drafts of thesis
    - final thesis report
  - **figures** *<- images generated by the code*
    - graphs
    - charts
    - tables
- **references** *<- data dictionaries, explanatory materials*
  - emoji data converted into dictionary for analysis
  - refernces on sentiment analysis calculation
- **TODO** *<- future improvements, bug fixes*
- **notebook** *<- high-lelvel project description*

