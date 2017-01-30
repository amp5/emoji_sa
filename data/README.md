data is formatted as follows:
- **raw**  *<- original, immutable data dump*
  - Twitter data
- **external**  *<- data from third party sources*
  - emoji data from outside research
- **interim**  *<- intermediate transformed data*
  - filtered twitter data to include only necessary columns and only US data
  - cleaned emoji data with only necessary information (form of dictionary?)
- **processed**  *<- final processed data set*
  - one data set with all necessary tweet data and binary values for particular emojis per tweet
