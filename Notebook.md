<p align="center">
  <b>2/8/17 - Refining Data Set</b>
</p>
- Current raw filtered data has 50 variables:

 [1] "X.1"                       "id_str"                   
 [3] "idx"                       "text"                     
 [5] "created_at"                "user_lang"                
 [7] "truncated"                 "retweeted"                
 [9] "favorite_count"            "verified"                 
[11] "user_id_str"               "source"                   
[13] "followers_count"           "in_reply_to_screen_name"  
[15] "location"                  "retweet_count"            
[17] "favorited"                 "utc_offset"               
[19] "statuses_count"            "description"              
[21] "friends_count"             "user_url"                 
[23] "geo_enabled"               "in_reply_to_user_id_str"  
[25] "lang"                      "user_created_at"          
[27] "favourites_count"          "name"                     
[29] "time_zone"                 "in_reply_to_status_id_str"
[31] "protected"                 "listed_count"             
[33] "place_lon"                 "expanded_url"             
[35] "place_id"                  "full_name"                
[37] "lat"                       "country_code"             
[39] "place_name"                "url"                      
[41] "country"                   "lon"                      
[43] "place_type"                "place_lat"                
[45] "X"                         "Y"                        
[47] "STATEFP"                   "NAME"                     
[49] "COUNT"                     "user_id"  

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
| ETL  | Clean data  | Remove unnecessary columns  | N  | N/A |
| ETL  | Reshape data  | Filter US only  | N  | N/A |
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

