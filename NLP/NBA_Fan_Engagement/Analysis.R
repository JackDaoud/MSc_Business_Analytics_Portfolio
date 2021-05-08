#' ---
#' title: "Text Analysis: NBA Fan Engagement via Twitter"
#' author: "by Jack Daoud"
#' output:
#'   html_notebook:
#'     number_sections: yes
#'     theme: readable
#'     highlight: pygments
#'     toc: yes
#'     toc_float:
#'       collapsed: no
#'   html_document:
#'     toc: yes
#'     df_print: paged
#' ---
#' 
## ----options & packages, message=FALSE, warning=FALSE, include=FALSE-------------------------------------------
# REMOVE # to install packages
#install.packages("plyr")
#install.packages("qdap")
#install.packages("tm")
#install.packages("docstring")
#install.packages("ggthemes")
#install.packages("lubridate")
#install.packages('dendextend')
#install.packages('circlize')
#install.packages("magrittr")
#install.packages('wordcloud')
#install.packages('wordcloud2')

# load Packages
lapply(c("lubridate", "plyr", "stringi", "ggdendro", 'dendextend',
          'circlize', "qdap", "tm", "docstring", "ggthemes", 'magrittr',
          'ggplot2', 'dplyr', 'readr', 'stringr', 'tidyr', 'ggalt', 
          'plotrix', 'wordcloud'), 
       library, character.only = TRUE)

# set options
options(stringsAsFactors = FALSE)
Sys.setlocale('LC_ALL', 'C')
set.seed(123)

# set working directory
#setwd('./personal/case_NBA')

#' 
#' # Data Exploration
#' 
#' ## Import
#' 
## ----import & sample data, message=FALSE, warning=FALSE--------------------------------------------------------
# import and merge all data sets Oct 2019-20
data_directory <- "./_data/original"
csv_files      <- list.files(path       = data_directory, 
                             pattern    = "*.csv",
                             full.names = TRUE)
tweets         <- ldply(csv_files, read_csv)

# take a sample of 1%
tweets         <- slice_sample(tweets, prop = 0.01)

# export tweet sample
write.csv(tweets,'./_data/manipulated/tweets_sample.csv', row.names = F)

#' 
#' ## Wrangle
#' 
## ----data wrangling, message=FALSE, warning=FALSE--------------------------------------------------------------
# import tweet sample
tweets <- read_csv('./_data/manipulated/tweets_sample.csv')

################################################################################
# Create placeholder for Region column
tweets$region <- ''

# Loop through each row and match teams with their respective region
for (i in 1:nrow(tweets)) {
  if (tweets[i, "team"] == "Boston Celtics" |
      tweets[i, "team"] == "Brooklyn Nets" |
      tweets[i, "team"] == "New York Knicks" |
      tweets[i, "team"] == "Philadelphia Sixers" |
      tweets[i, "team"] == "Toronto Raptors") {
    tweets[i, "region"] <- "Atlantic"
  }
  else if (tweets[i, "team"] == "Chicago Bulls" |
           tweets[i, "team"] == "Cleveland Cavaliers" |
           tweets[i, "team"] == "Detroit Pistons" |
           tweets[i, "team"] == "Indiana Pacers" |
           tweets[i, "team"] == "Milwaukee Bucks") {
    tweets[i, "region"] <- "Central"
  }
  else if (tweets[i, "team"] == "Atlanta Hawks" |
           tweets[i, "team"] == "Charlotte Hornets" |
           tweets[i, "team"] == "Miami Heat" |
           tweets[i, "team"] == "Orlando Magic" |
           tweets[i, "team"] == "Washington Wizards") {
    tweets[i, "region"] <- "Southeast"
  }
  else if (tweets[i, "team"] == "Denver Nuggets" |
           tweets[i, "team"] == "Minnesota Timberwolves" |
           tweets[i, "team"] == "Oklahoma City Thunder" |
           tweets[i, "team"] == "Portland Trail Blazers" |
           tweets[i, "team"] == "Utah Jazz") {
    tweets[i, "region"] <- "Northwest"
  }
  else if (tweets[i, "team"] == "Golden State Warriors" |
           tweets[i, "team"] == "LA Clippers" |
           tweets[i, "team"] == "LA Lakers" |
           tweets[i, "team"] == "Phoenix Suns" |
           tweets[i, "team"] == "Sacramento Kings") {
    tweets[i, "region"] <- "Pacific"
  }
  else if (tweets[i, "team"] == "Dallas Mavericks" |
           tweets[i, "team"] == "Houston Rockets" |
           tweets[i, "team"] == "Memphis Grizzlies" |
           tweets[i, "team"] == "New Orleans Pelicans" |
           tweets[i, "team"] == "San Antonio Spurs") {
    tweets[i, "region"] <- "Southwest"
  }
}

################################################################################
# Feature engineering date & time values
tweets         <- tweets %>% rename(timestamp = created)
tweets$year    <- year(tweets$timestamp)
tweets$month   <- month(tweets$timestamp, label = T)
tweets$day     <- day(tweets$timestamp)
tweets$weekday <- wday(tweets$timestamp, label = T)
tweets$hour    <- hour(tweets$timestamp)

# remove Sep 2019 tweets so upcoming tweets per month plot
tweets <- tweets %>% filter(year  != 2019 | month != 'Sep')

################################################################################
# Export wrangled data
write.csv(tweets,'./_data/manipulated/tweets_sample_wrangled.csv', row.names = F)

#' 
#' ## Data Overview Plots
#' 
#' **Tweets per Region not used in presentation**
#' 
## ----high level data exploration, message=FALSE, warning=FALSE-------------------------------------------------
# import wrangled tweets
tweets <- read_csv('./_data/manipulated/tweets_sample_wrangled.csv')

# Ordinal factors
tweets$month <- factor(tweets$month,
                       levels = c('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                                  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'))
tweets$weekday <- factor(tweets$weekday,
                         levels = c('Mon', 'Tue', 'Wed', 'Thu', 'Fri', 
                                    'Sat', 'Sun'))
tweets$year <- factor(tweets$year,
                         levels = c('2019', '2020'))

################################################################################
# plot tweets per month
tweets_per_month <-
  tweets %>% 
  group_by(month, year) %>% 
  summarize(count = n()) %>% 
  ggplot(., aes(x = month, y = count, fill = year)) +
  geom_bar(stat = 'identity') +
  scale_fill_manual(values=c("#2E86C1", "#201449")) +
  geom_text(aes(label=count), position = "stack", vjust=-0.7, size=3) +
  theme(legend.background = element_rect(fill="transparent", colour=NA),
        panel.grid.major  = element_blank(), 
        panel.grid.minor  = element_blank(), 
        panel.background  = element_rect(fill="transparent", colour=NA),
        plot.background   = element_rect(fill="transparent", colour=NA),
        axis.line   = element_line(colour = "black"),
        axis.text   = element_text(face="bold", color="#000000", size=10),
        axis.text.x = element_text(angle = 45, hjust = 1),
        axis.title  = element_text(face="bold", color="#000000", size=12),
        plot.title  = element_text(face="bold", color="#000000", size=16)) +
  labs(title = "Tweets per Month",
       x    = "Month",
       y    = "Count",
       fill = "Year") +
  theme(plot.title = element_text(hjust = 0.5))

# save plot
ggsave("./_images/tweets_per_month.png", tweets_per_month, bg = "transparent")


################################################################################
# plot tweets per region
tweets_per_region <-
  tweets %>% 
  group_by(region, team) %>% 
  summarize(count = n()) %>% 
  arrange(desc(count)) %>% 
  ggplot(., aes(x = reorder(region, -count), y = count), color="black") +
  geom_bar(stat = 'identity', fill = '#FFFFFF', color = "black") +
  #scale_fill_manual(values = c('#E03A3E', '#007A33', '#FFFFFF', '#1D1160',
  #                             '#CE1141', '#860038', '#00538C', '#0E2240',
  #                             '#C8102E', '#FFC72C', '#CE1141', '#002D62',
  #                             '#C8102E', '#552583', '#5D76A9', '#98002E',
  #                             '#00471B', '#0C2340', '#236192', '#F58426',
  #                             '#007AC1', '#0077C0', '#006BB6', '#1D1160',
  #                             '#E03A3E', '#5A2D81', '#E03A3E', '#5A2D81',
  #                             '#C4CED4', '#CE1141', '#002B5C', '#002B5C')) +
  geom_text(aes(label=count), position = "stack", vjust=-0.7, size=3) +
  theme(legend.background = element_rect(fill="transparent", colour=NA),
        panel.grid.major  = element_blank(), 
        panel.grid.minor  = element_blank(), 
        panel.background  = element_rect(fill="transparent", colour=NA),
        plot.background   = element_rect(fill="transparent", colour=NA),
        axis.line   = element_line(colour = "black"),
        axis.text   = element_text(face="bold", color="#000000", size=10),
        axis.text.x = element_text(angle = 45, hjust = 1),
        axis.title  = element_text(face="bold", color="#000000", size=12),
        plot.title  = element_text(face="bold", color="#000000", size=16)) +
  labs(title = "Tweets per Region",
       x    = "Region",
       y    = "Count",
       fill = "Teams") +
  theme(plot.title = element_text(hjust = 0.5))

# save plot
ggsave("./_images/tweets_per_region.png", tweets_per_region, bg = "transparent")

#' 
#' 
#' # Corpus Preprocessing
#' 
#' ## Define Stop Words
#' 
## ----stop words, message=FALSE, warning=FALSE------------------------------------------------------------------
nbaStopwords = c('nba','teams','fans','live','games','points','pacers', 'pts',
                  'year','back','coach','tonight','city','time','today',
                  'season','win','state','basketball','team','game','sports',
                  'play', 'player', 'players', 'played', 'playoff', 'playing',
                  'won', 'fan', 'lead', 'series', 'playoffs', 'star', 'home',
                  'center', 'championship', 'jersey', 'point', 'draft', 'loss',
                  'quarter', 'lost', 'highlights', 'winning', 'reb', 'tickets',
                  'allstar', 'national', 'arena', 'rankings', 'rookie', 'wins',
                  'round', 'rebounds', 'told', 'ball', 'swingman')

# print team names for nba_stopwords
#team_names <- as.character(unique(unlist(tweets$team)))
#team_names <- tryTolower(team_names)
#team_names <- scan(text = team_names, what = "")
#team_names <- paste0(team_names, sep = "'", collapse=",'")
#team_names

teamStopwords <- c('la','clippers','denver','nuggets','boston','celtics',
                    'brooklyn','nets','chicago','bulls','portland','trail',
                    'blazers','philadelphia','sixers','milwaukee','bucks','san',
                    'antonio','spurs','la','lakers','sacramento','kings',
                    'miami','heat','indiana','pacers','toronto','raptors',
                    'atlanta','hawks','golden','state','warriors','utah',
                    'jazz','dallas','mavericks','houston','rockets','orlando',
                    'magic','detroit','pistons','charlotte','hornets',
                    'minnesota','timberwolves','cleveland','cavaliers',
                    'new','york','knicks','memphis','grizzlies','phoenix',
                    'suns','new','orleans','pelicans','oklahoma','city',
                    'thunder','washington','wizards', 'los', 'angeles')

abbreviationStopwords = c('lol', 'smh', 'rofl', 'lmao', 'lmfao', 'wtf', 'btw', 
                           'nbd','nvm', 'lmk', 'kk', 'obvi', 'obv', 'srsly', 
                           'rly', 'tmi', 'ty', 'tyvm', 'yw', 'fomo', 'ftw', 
                           'icymi', 'icyww', 'ntw', 'omg', 'omfg', 'idk', 'idc', 
                           'jell', 'iirc', 'ffs', 'fml', 'idgaf', 'stfu', 'tf',
                           'omw', 'rn', 'ttyl', 'tyt', 'bball')
# from https://stylecaster.com/social-media-acronyms-abbreviations-what-they-mean/

# These are stopwords that I've identified after making visualizations
iterativeStopwords <- c('amp', 'years', 'beat', 'ufc', 'day', 'night',
                        'league', 'finals', 'watch', 'espn', 'guard', 'trade',
                        'pick', 'free', 'ago', 'head', 'big', 'center',
                        'love', 'ufa', 'make', 'itus', 'ers', 'theu', 'man',
                        'conference', 'forward', 'history', 'donut', 'ium', 
                        'made', 'great', 'deal', 'harden', 'owner', 'full',
                        'news', 'ast', 'thu', 'left', 'breaking', 'bubble',
                        'uff', 'power', 'usa', 'assistant', 'contract', 
                        'starting', 'video', 'sources', 'good', 'ufb', 'le',
                        'ad', 'de', 'uf', 'nbachallengefr', 'hu', 'makes', 'ua',
                        'ufd', 'gt', 'ufecu', 'check', 'nwt', 'blanku', 
                        'grizzliesfr', 'stream', 'top', 'final', 'record',
                        'people', 'week', 'young', 'edition', 'gagnez',
                        'concours', 'maillot', 'ownsu', 'green', 'closet',
                        'closet', 'red', 'blue', 'yellow', 'white', 'size',
                        'medium', 'xl', 'xxl', 'xlarge', 'million', 'air',
                        'large', 'small', 'color', 'retweet', 'black')

customStopwords <- c(
  stopwords('english'),
  stopwords('SMART'),
  nbaStopwords,
  teamStopwords,
  abbreviationStopwords,
  iterativeStopwords)

#' 
#' ## Preprocessing Functions
#' 
## ----define text processing functions, message=FALSE, warning=FALSE--------------------------------------------
################################################################################
tryTolower <- function(text_column) {
  #' Returns NA instead of tolower error
  y = NA
  # tryCatch error
  try_error = tryCatch(tolower(text_column), error = function(e) e)
  # if not an error
  if (!inherits(try_error, 'error'))
    y = tolower(text_column)
  return(y)
}

################################################################################
basicSubs <- function(text_column) {
  #' Run a variety of text cleaning functions
  #' 
  #' Remove URLs, RTs, and non-ASCII text (i.e emojis)
  #' Remove punctuation
  #' Lower all text (case wise)
  text_column <- gsub('http\\S+\\s*', '', text_column)
  text_column <- gsub('(RT|via)((?:\\b\\W*@\\w+)+)', '', text_column)
  text_column <- gsub("[^\x01-\x7F]", '', text_column)
  text_column <- str_replace_all(text_column, "[[:punct:]]", " ")
  text_column <- tryTolower(text_column)
  return(text_column)
}

################################################################################
cleanCorpus <- function(corpus, customStopwords) {
  #' Run a variety of corpus cleaning functions
  #'
  #' Functions that run:
  #' - Remove numbers
  #' - Remove punctuation
  #' - Strip white space
  #' - Remove stopwords
#  corpus <- tm_map(corpus, content_transformer(replace_contraction))
  corpus <- tm_map(corpus, removeNumbers)
  corpus <- tm_map(corpus, stripWhitespace)
  corpus <- tm_map(corpus, removePunctuation)
#  corpus <- tm_map(corpus, content_transformer(tryTolower))
  corpus <- tm_map(corpus, removeWords, customStopwords)
  return(corpus)
}

################################################################################
# correct spelling function
#correct_spelling <- function(text_column) {
#  check <- check_spelling(text_column)
#  splitted <- strsplit(text_column, split=' ')
#  for (i in 1:length(check$row)) {
#    splitted[[check$row[i]]][as.numeric(check$word.no[i])] = check$suggestion[i]  
#    }
#  df <- unlist(lapply(splitted, function(x) paste(x, collapse = ' ')))   
#  return(df)
#}
# Did not include this function because the trade off in terms of accuracy is too high


################################################################################
cleanMatrix <- function(pth, columnName, collapse = F, customStopwords, 
                        type, wgt){

  print(type)
  
  if(grepl('.csv', pth, ignore.case = T)==T){
    print('reading in csv')
    text      <- read.csv(pth)
    text      <- text[,columnName]
  }
  if(grepl('.fst', pth)==T){
    print('reading in fst')
    text      <- fst::read_fst(pth)
    text      <- text[,columnName]
  } 
  if(grepl('csv|fst', pth, ignore.case = T)==F){
    stop('the specified path is not a csv or fst')
  }
 
  
  if(collapse == T){
    text <- paste(text, collapse = ' ')
  }
  
  print('cleaning text')
  txtCorpus <- VCorpus(VectorSource(text))
  txtCorpus <- cleanCorpus(txtCorpus, customStopwords)
  
  if(type =='TDM'){
    if(wgt == 'weightTfIdf'){
      termMatrix    <- TermDocumentMatrix(txtCorpus, 
                                      control = list(weighting = weightTfIdf))
    } else {
      termMatrix   <- TermDocumentMatrix(txtCorpus)
      }
    
    response  <- as.matrix(termMatrix)
  } 
  if(type =='DTM'){
    if(wgt == 'weightTfIdf'){
      termMatrix   <- DocumentTermMatrix(txtCorpus, 
                                      control = list(weighting = weightTfIdf))
    } else {
      termMatrix    <- DocumentTermMatrix(txtCorpus)
    }
    response  <- as.matrix(termMatrix)
  if(grepl('dtm|tdm', type, ignore.case=T) == F){
    stop('type needs to be either TDM or DTM')
  }
  
 
  }
  print('complete!')
  return(response)
}

################################################################################
bigramTokens <- function(x) {
  unlist(lapply(NLP::ngrams(words(x), 2), paste, collapse = " "), use.names = F)
}

#' 
#' 
#' ## Corpus & TDM
#' 
## ----create, clean & export corpus, message=FALSE, warning=FALSE-----------------------------------------------
# import wrangled tweets sample
tweets <- read_csv('./_data/manipulated/tweets_sample_wrangled.csv')

# Partially text column & save partially cleaned data
tweets$text  <- basicSubs(tweets$text)
partially_cleaned_tweets <- tweets

# Export partially cleaned tweets as csv
write.csv(partially_cleaned_tweets,'./_data/manipulated/partially_cleaned_tweets.csv', 
          row.names = F)

# Create a volatile corpus
tweetCorpus <- VCorpus(DataframeSource(tweets))

# Clean the corpus
tweetCorpus <- cleanCorpus(tweetCorpus, customStopwords)

# Save corpus as dataframe
cleaned_corpora <-
  data.frame(text = unlist(sapply(tweetCorpus, `[`,"content")),
             stringsAsFactors=F)

# Export corpus as dataframe in csv format
write.csv(cleaned_corpora,'./_data/manipulated/cleaned_corpora.csv', 
          row.names = F)

# Convert corpus into Term Document Matrix
tweetTDM   <- TermDocumentMatrix(tweetCorpus)
tweetTDMm  <- as.matrix(tweetTDM)

#' 
#' ## Bigram TDM
#' 
## ----create bigram df, corpus, & TDM---------------------------------------------------------------------------
# Reduce size in order to process bigram TDM
bigram_tweets <- slice_sample(tweets, prop = 0.1)

# Create a volatile bigram corpus
bigramCorpus <- VCorpus(DataframeSource(bigram_tweets))

# Clean the bigram corpus
bigramCorpus <- cleanCorpus(bigramCorpus, customStopwords)

# Create a bigram TDM
bigramTDM  <- TermDocumentMatrix(bigramCorpus, control=list(tokenize=bigramTokens))
bigramTDMm <- as.matrix(bigramTDM)

#' 
#' 
#' # Visualizations
#' 
#' ## Share of Brand
#' 
## ----share of brand, message=FALSE, warning=FALSE--------------------------------------------------------------
# Import cleaned corpora
#cleaned_corpora <- read_csv('./_data/manipulated/cleaned_corpora.csv')

# calculate frequency per brand
adidas       <- sum(stri_count(cleaned_corpora$text, fixed ='adidas'))
nike         <- sum(stri_count(cleaned_corpora$text, fixed ='nike'))
under_armour <- sum(stri_count(cleaned_corpora$text, fixed ='armour'))
reebok       <- sum(stri_count(cleaned_corpora$text, fixed ='reebok'))
puma         <- sum(stri_count(cleaned_corpora$text, fixed ='puma'))

# create data frame of brand & frequencies
brandFreq <- data.frame(terms = c('Adidas','Nike', 
                                  'Under Armour', 'Reebok', 'Puma'),
                        freq  = c(adidas, nike, under_armour,
                                  reebok, puma))

# plot share of brand
mentions_per_brand <-
  ggplot(brandFreq, aes(x = reorder(terms, freq), y = freq, fill=freq)) + 
    geom_bar(stat = "identity") + coord_flip() +
    theme_gdocs() + 
    geom_text(aes(label=freq), position = "stack", hjust = -0.1, size = 4) +
    theme(legend.position  = "none", 
          panel.grid.major = element_blank(), 
          panel.grid.minor = element_blank(), 
          panel.background = element_rect(fill="transparent", colour=NA),
          plot.background  = element_rect(fill="transparent", colour=NA),
          axis.line  = element_line(colour = "black"),
          axis.text  = element_text(face="bold", color="#000000", size=10),
          axis.title = element_text(face="bold", color="#000000", size=12),
          plot.title = element_text(face="bold", color="#000000", size=16)) +
    expand_limits(y = 200) +
    labs(title = "Mentions per Brand",
         x = "Brand",
         y = "Frequency") +
    theme(plot.title = element_text(hjust = 0.5))

# save image
ggsave("./_images/mentions_per_brand.png", mentions_per_brand, bg = "transparent")

#' 
#' ## Word Frequency
#' 
#' **Unigram & Bigram top names plots not used in presentation**
#' 
#' ### Unigram
#' 
## ----unigram frequencies, message=FALSE, warning=FALSE---------------------------------------------------------
# Frequency Data Frame
tweetSums <- rowSums(tweetTDMm)
tweetFreq <- data.frame(word=names(tweetSums),frequency=tweetSums)
rownames(tweetFreq) <- NULL

# Top Names
unigram_topNames      <- subset(tweetFreq, tweetFreq$frequency > 500)
unigram_topNames$word <- stri_trans_totitle(unigram_topNames$word)
unigram_topNames      <- unigram_topNames[order(unigram_topNames$frequency, 
                                                decreasing=F),]
unigram_topNames$word <- factor(unigram_topNames$word, 
                                levels=unique(as.character(unigram_topNames$word))) 

# Plot top names as bar plot
unigrams_top_names<-
  ggplot(unigram_topNames, aes(x=word, y=frequency, fill=frequency)) + 
  geom_bar(stat="identity") + 
  coord_flip() + theme_gdocs() +
  geom_text(aes(label=frequency), colour="black",hjust=-0.25, size=3.3) +
  theme_gdocs() + 
  theme(legend.position  = "none", 
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(), 
        panel.background = element_rect(fill="transparent", colour=NA),
        plot.background  = element_rect(fill="transparent", colour=NA),
        axis.line  = element_line(colour = "black"),
        axis.text  = element_text(face="bold", color="#000000", size=10),
        axis.title = element_text(face="bold", color="#000000", size=13),
        plot.title = element_text(face="bold", color="#000000", size=16)) +
  expand_limits(y = 1200) +
  labs(title = "Top Names of the 2019-20 NBA Season",
       x = "Names",
       y = "Frequency") +
  theme(plot.title   = element_text(hjust = 0.3, vjust = 1),
        axis.title.y = element_text(hjust = 1, vjust = 1.2))

# save image
ggsave("./_images/top_names_unigrams.png", unigrams_top_names, bg = "transparent")

#' 
#' ### Bigram
#' 
## ----bigram frequencies, message=FALSE, warning=FALSE----------------------------------------------------------
# Frequency Data Frame
bigramSums <- rowSums(bigramTDMm)
bigramFreq <- data.frame(word=names(bigramSums),frequency=bigramSums)
rownames(bigramFreq) <- NULL

# Top Names
bigram_topNames      <- subset(bigramFreq, bigramFreq$frequency > 18)
bigram_topNames$word <- stri_trans_totitle(bigram_topNames$word)
bigram_topNames      <- bigram_topNames[order(bigram_topNames$frequency, decreasing=F),]
bigram_topNames$word <- factor(bigram_topNames$word, 
                               levels=unique(as.character(bigram_topNames$word))) 

# Plot top names as bar plot
bigrams_top_names <-
  ggplot(bigram_topNames, aes(x=word, y=frequency, fill = frequency)) + 
  geom_bar(stat="identity") + 
  coord_flip() + theme_gdocs() +
  geom_text(aes(label=frequency), colour="black",hjust=-0.25, size=3.3) +
  theme_gdocs() + 
  theme(legend.position  = "none", 
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(), 
        panel.background = element_rect(fill="transparent", colour=NA),
        plot.background  = element_rect(fill="transparent", colour=NA),
        axis.line  = element_line(colour = "black"),
        axis.text  = element_text(face="bold", color="#000000", size=10),
        axis.title = element_text(face="bold", color="#000000", size=13),
        plot.title = element_text(face="bold", color="#000000", size=16)) +
  expand_limits(y = 60) +
  labs(title = "Top Names of the 2019-20 NBA Season",
       x = "Names",
       y = "Frequency") +
  theme(plot.title   = element_text(hjust = -0.5, vjust = 1),
        axis.title.y = element_text(hjust = 1, vjust = 1.2))

# save image
ggsave("./_images/top_names_bigrams.png", bigrams_top_names, bg = "transparent")

#' 
#' 
#' ## Word Clouds
#' 
## ----word clouds, message=FALSE, warning=FALSE-----------------------------------------------------------------
#cleaned_corpora <- read_csv('./_data/manipulated/cleaned_corpora.csv')

# worldcloud of words associated with Nike
nike_wordcloud<- 
  word_associate(cleaned_corpora$text, 
                 match.string = 'nike', 
                 stopwords    = c(customStopwords),
                 min.freq     = 5,
                 wordcloud    = T,
                 caps         = T,
                 cloud.colors = c('black','darkblue'))

# wordcloud of words associated with Adidas
adidas_wordcloud<- 
  word_associate(cleaned_corpora$text, 
                 match.string = 'adidas', 
                 stopwords    = c(customStopwords),
                 min.freq     = 3,
                 wordcloud    = T,
                 caps         = T,
                 cloud.colors = c('black','darkred'))

# General word cloud of cleaned corpus
wordcloud(words        = tweetFreq$word, 
          freq         = tweetFreq$frequency, 
          min.freq     = 7,
          random.order = F, 
          rot.per      = 0.35, 
          colors       = c('black', 'darkred','darkblue'),
          use.r.layout = T)

#' 
#' ## Word Associations
#' 
## ----word associations, message=FALSE, warning=FALSE-----------------------------------------------------------
################################################################################
# Nike associations
nikeAssociations <- findAssocs(tweetTDM, 'nike', 0.15)

# Organize the word associations
nikeAssocDF <- data.frame(terms=names(nikeAssociations[[1]]),
                       value=unlist(nikeAssociations))
nikeAssocDF$terms <- factor(nikeAssocDF$terms, levels=nikeAssocDF$terms)
rownames(nikeAssocDF) <- NULL

# Make a dot plot
nikeAssocPlot <-
  ggplot(nikeAssocDF, aes(y=terms)) +
  geom_point(aes(x=value), data=nikeAssocDF, col='#00008b') +
  theme_gdocs() + 
  geom_text(aes(x=value,label=value), colour="darkblue",hjust=-0.5, vjust ="inward" , size=3) +
  labs(title = "Nike Associations",
       x = 'Association Level',
       y = 'Terms') +
  theme(plot.title = element_text(hjust = 0.5)) +
  theme(legend.position = "none", 
        panel.background = element_rect(fill="transparent", colour=NA),
        plot.background  = element_rect(fill="transparent", colour=NA),
        axis.text  = element_text(face="bold", color="#000000", size=10),
        axis.title = element_text(face="bold", color="#000000", size=12),
        plot.title = element_text(face="bold", color="#000000", size=16)) +
  expand_limits(x = 0.3)

# save image
ggsave("./_images/associations_nike.png", nikeAssocPlot, bg = "transparent")

################################################################################
# Adidas associations
adidasAssociations <- findAssocs(tweetTDM, 'adidas', 0.15)

# Organize the word associations
adidasAssocDF <- data.frame(terms=names(adidasAssociations[[1]]),
                       value=unlist(adidasAssociations))
adidasAssocDF$terms <- factor(adidasAssocDF$terms, levels=adidasAssocDF$terms)
rownames(adidasAssocDF) <- NULL

# Make a dot plot
adidasAssocPlot <-
  ggplot(adidasAssocDF, aes(y = terms)) +
  geom_point(aes(x = value), data = adidasAssocDF, col = '#8b0000') +
  theme_gdocs() + 
  geom_text(aes(x=value,label=value), 
            colour = "darkred", hjust = -0.5, vjust = "inward", size = 3) +
  labs(title = "Adidas Associations",
       x = 'Association Level',
       y = 'Terms') +
  theme(plot.title = element_text(hjust = 0.5)) +
  theme(legend.position = "none", 
          panel.background = element_rect(fill="transparent", colour=NA),
          plot.background = element_rect(fill="transparent", colour=NA),
          axis.text  = element_text(face="bold", color="#000000", size=10),
          axis.title = element_text(face="bold", color="#000000", size=12),
          plot.title = element_text(face="bold", color="#000000", size=16)) +
  expand_limits(x = 0.35)

# save image
ggsave("./_images/associations_adidas.png", adidasAssocPlot, bg = "transparent")

#' 
#' ## Dendograms 
#' 
#' **Not used in Presentation**
#' 
## ----NOT USED dendrogram, message=FALSE, warning=FALSE---------------------------------------------------------
# Reduce corpus by removing documents with more than 99.5% 0 terms
reducedTDM <- removeSparseTerms(tweetTDM, sparse=0.993)
reducedTDM <- as.data.frame(as.matrix(reducedTDM))

# Plot hierarchical dendogram
hierarchical_cluster <- hclust(dist(reducedTDM))
ggdendrogram(hierarchical_cluster, yaxt='n', rotate = F) +
  labs(title = "NBA Dendogram",
       x = 'Terms',
       y = 'Frequency') +
  theme(plot.title = element_text(hjust = 0.5)) +
  theme(legend.position    = "none", 
          panel.grid.major = element_blank(), 
          panel.grid.minor = element_blank(), 
          panel.background = element_rect(fill="transparent", colour=NA),
          plot.background  = element_rect(fill="transparent", colour=NA),
          axis.text  = element_text(face="bold", color="#000000", size=10),
          axis.title = element_text(face="bold", color="#000000", size=12),
          plot.title = element_text(face="bold", color="#000000", size=16)) 
  
  
# Create function to color clusters of dendogram
dend_change <- function(n) {
  if (is.leaf(n)) {
    a <- attributes(n)
    labCol <- labelColors[clusMember[which(
      names(clusMember) == a$label)]]
    attr(n, 'nodePar') <- c(a$nodePar, lab.col =
                              labCol)
    }
  n
}

# Plot a Hierarchical dendogram with colored clusters 
hierarchical_cluster_dendogram <- as.dendrogram(hierarchical_cluster)
clusMember <- cutree(hierarchical_cluster, 4)
labelColors <- c('darkgrey', 'darkred', 'black', '#bada55')
clusDendro <- dendrapply(hierarchical_cluster_dendogram, dend_change)
plot(clusDendro, main = "NBA Dendogram",type = "triangle",yaxt='n')


# Plot circular dendogram
hierarchical_cluster_dendogram <- 
  color_labels(hierarchical_cluster_dendogram, 4, 
               col = c('#bada55','darkgrey', "black", 'darkred'))
hierarchical_cluster_dendogram <-
  color_branches(hierarchical_cluster_dendogram, 4, 
                 col = c('#bada55','darkgrey', "black", 'darkred')) 
circlize_dendrogram(hierarchical_cluster_dendogram, 
                    labels_track_height = 0.4, dend_track_height = 0.3)


#' 
#' ## Pyramid Plot
#' 
## ----adidas vs nike, message=FALSE, warning=FALSE--------------------------------------------------------------
# Import cleaned tweets
#partially_cleaned_tweets <- 
#  read_csv('./_data/manipulated/partially_cleaned_tweets.csv')

# Create data frames containing 'nike' and 'adidas'
nike_df <- partially_cleaned_tweets[
  str_detect(partially_cleaned_tweets$text, "nike"), ]

adidas_df <- partially_cleaned_tweets[
  str_detect(partially_cleaned_tweets$text, "adidas"), ]


# Export above dataframes
write.csv(nike_df,'./_data/manipulated/nike.csv', 
          row.names = F)
write.csv(adidas_df,'./_data/manipulated/adidas.csv', 
          row.names = F)

# Read in data, clean & organize
textA <- cleanMatrix(pth             = './_data/manipulated/nike.csv',
                     columnName      = 'text',
                     collapse        = T, 
                     customStopwords = c(customStopwords, 'nike'),
                     type = 'TDM', 
                     wgt = 'weightTf') # weightTfIdf or weightTf

textB <- cleanMatrix(pth        = './_data/manipulated/adidas.csv',
                     columnName = 'text',
                     collapse   = T,
                     customStopwords = c(customStopwords, 'adidas'),
                     type = 'TDM', 
                     wgt = 'weightTf')

# Create merged data set
pyramid_df         <- merge(textA, textB, by ='row.names')
names(pyramid_df)  <- c('terms', 'nike', 'adidas')

# Calculate the absolute differences among in common terms
pyramid_df$diff <- abs(pyramid_df$nike - pyramid_df$adidas)

# Organize data frame for plotting
pyramid_df <- pyramid_df[order(pyramid_df$diff, decreasing=TRUE), ]
top15 <- pyramid_df[1:15, ]

# Pyarmid Plot
pyramid.plot(lx         = top15$nike, #left
             rx         = top15$adidas,    #right
             labels     = top15$terms,  #terms
             top.labels = c('', '', ''), #corpora
             gap        = 7, # space for terms to be read
             main       = 'Words in Common', # title
             unit       = 'Word Frequency',
             lxcol      = 'darkblue',
             rxcol      = 'darkred') 

#' 
