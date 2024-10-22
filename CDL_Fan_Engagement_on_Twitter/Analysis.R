#' ---
#' title: "Text Analysis: Call of Duty League"
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
#' # Outline of Chunks:
#' 
#' - Chunk 01: Import functions, packages and set options.
#' - Chunk 02: Import team follower time line data and filter to CDL related documents
#' - Chunk 03: Process text column of data set in the form of simple substitutions
#' - Chunk 04: Create & clean corpus
#' - Chunk 05: Create unigram & bigram TDM
#' - Chunk 06: Plot number of followers per team
#' - Chunk 07: Plot polarity distribution
#' - Chunk 08: Plot sentiment radar chart
#' - Chunk 09: Plot mentions per team (Frequency)
#' - Chunk 10: Plot pyramid plot between Optic & Empire
#' - Chunk 11: Plot associations dot plot (CDL)
#' - Chunk 12: Plot associations dot plot (Teams)
#' 
## ----options & functions & packages, message=FALSE, warning=FALSE, include=FALSE-------------------------------
# load Packages
lapply(c('lubridate', "plyr", "stringi", "ggdendro", 'dendextend', 'pbapply',
         'circlize', "qdap", "tm", "docstring", "ggthemes", 'magrittr',
         'ggplot2', 'dplyr', 'readr', 'stringr', 'tidyr', 'ggalt', 'scales',
         'plotrix', 'wordcloud', 'lexicon', 'radarchart', 'tidytext',
         'fst', 'mgsub', 'reshape2', 'viridisLite', 'progress_bar'),
       require, character.only = TRUE)

# load supporting functions & stopwords
source('./supportingFunctions.R')

# set options
options(stringsAsFactors = FALSE)
Sys.setlocale('LC_ALL', 'C')

# set working directory
#setwd('~/Documents/Github/hult_NLP/personal/case_COD') # Desktop
#setwd('~/Library/Mobile Documents/com~apple~CloudDocs/Documents/GitHub/hult_NLP/personal/case_COD') # Laptop

#' 
## ----import & filter team follower data, message=FALSE, warning=FALSE------------------------------------------
set.seed(123)

#### Optic Chicago ####

# Create a list of files for player followers for Optic Chicago
followersOptic <- 
  list.files(path       = "./_data/teamFollowerTimelines/", 
             pattern    = "(OpTicCHI).*\\.fst$",
             full.names = TRUE)

# Create a data frame of player followers for Optic Chicago
followersOptic <- ldply(followersOptic, read_fst)

# Reorganize & rename column names to match requirement of VCorpus()
followersOptic <- 
  followersOptic[, c('status_id', 'text', 'user_id', 'screen_name',
                      'created_at', 'hashtags', 'team')]

names(followersOptic)[1] <- "doc_id"

# take sample of 50%
followersOptic <- slice_sample(followersOptic, prop = 0.5)

#### Dallas Empire ####

# Create a list of files for player followers for Optic Chicago
followersDallas <- 
  list.files(path       = "./_data/teamFollowerTimelines/", 
             pattern    = "(dallasempire).*\\.fst$",
             full.names = TRUE)

# Create a data frame of player followers for Optic Chicago
followersDallas <- ldply(followersDallas, read_fst)

# Reorganize & rename column names to match requirement of VCorpus()
followersDallas <- 
  followersDallas[, c('status_id', 'text', 'user_id', 'screen_name',
                       'created_at', 'hashtags', 'team')]

names(followersDallas)[1] <- "doc_id"

# take sample of 50%
followersDallas <- slice_sample(followersDallas, prop = 0.5)

#### Minnesota Rokkr ####

# Create a list of files for player followers for Optic Chicago
followersRokkr <- 
  list.files(path       = "./_data/teamFollowerTimelines/", 
             pattern    = "(rokkr).*\\.fst$",
             full.names = TRUE)

# Create a data frame of player followers for Optic Chicago
followersRokkr <- ldply(followersRokkr, read_fst)

# Reorganize & rename column names to match requirement of VCorpus()
followersRokkr <- 
  followersRokkr[, c('status_id', 'text', 'user_id', 'screen_name',
                       'created_at', 'hashtags', 'team')]

names(followersRokkr)[1] <- "doc_id"

# take sample of 50%
followersRokkr <- slice_sample(followersRokkr, prop = 0.5)

#### LA Guerrillas ####

# Create a list of files for player followers for Optic Chicago
followersGuerillas <- 
  list.files(path       = "./_data/teamFollowerTimelines/", 
             pattern    = "(Guerrillas).*\\.fst$",
             full.names = TRUE)

# Create a data frame of player followers for Optic Chicago
followersGuerillas <- ldply(followersGuerillas, read_fst)

# Reorganize & rename column names to match requirement of VCorpus()
followersGuerillas <- 
  followersGuerillas[, c('status_id', 'text', 'user_id', 'screen_name',
                       'created_at', 'hashtags', 'team')]

names(followersGuerillas)[1] <- "doc_id"

# take sample of 50%
followersGuerillas <- slice_sample(followersGuerillas, prop = 0.5)

#### Team Followers ####

# Aggregate above data sets into one
teamFollowers <- 
  bind_rows(followersDallas, followersGuerillas, followersOptic, followersRokkr)

#### Filter ####
# Filter to CoD, CDL, Team specific tweets
teamFollowers <- 
  filter(teamFollowers, 
  grepl('\bcod|\bcall|\bduty|\bcallofduty|\bmw|modernwarfare|war|/boptic|empire|
        warfare|cdl|game|gaming|gamer|\bftw|\bgg|codleague|championship|rokkr|
        guerillas',
        text, ignore.case = T))

# Filter dates to 2020 (CDL began in Jan 2020) 
teamFollowers$year <- year(teamFollowers$created_at)
teamFollowers <- filter(teamFollowers, year == 2020)

# Export data
write.csv(teamFollowers,
          './_data/_manipulated/teamFollowers.csv', 
          row.names = F)

# Clean Environment
rm(followersDallas, followersGuerillas, followersOptic, followersRokkr)

#' 
## ----process text column (gsub & emoji), message=FALSE, warning=FALSE------------------------------------------
set.seed(123)

# Import data
teamFollowers <- read_csv('./_data/_manipulated/teamFollowers.csv')

# SAMPLE FOR TESTING
#teamFollowers <- slice_sample(teamFollowers, prop = 0.05)

# Partially clean text column
teamFollowers$text <- basicSubs(teamFollowers$text)

# Substitute emojis
emojis             <- read_csv('./_data/emojis.csv')
teamFollowers$text <- pbsapply(as.character(teamFollowers$text), 
                               mgsub, emojis$emoji, emojis$name)
rm(emojis)

# Export partially cleaned tweets as csv
write.csv(teamFollowers,'./_data/_manipulated/teamFollowersSubbed.csv', 
          row.names = F)

#' 
## ----process & clean corpus, message=FALSE, warning=FALSE------------------------------------------------------
# Import partially cleaned tweets
teamFollowers <- read_csv( './_data/_manipulated/teamFollowersSubbed.csv')

##### Stop Words #####
#source('./supportingStopwords.R')

# Add stop words for abbreviations
stopsAbbreviations = c('lol', 'smh', 'rofl', 'lmao', 'lmfao', 'wtf', 'btw', 
                        'nbd','nvm', 'lmk', 'kk', 'obvi', 'obv', 'srsly', 
                        'rly', 'tmi', 'ty', 'tyvm', 'yw', 'fomo', 'ftw', 
                        'icymi', 'icyww', 'ntw', 'omg', 'omfg', 'idk', 'idc', 
                        'jell', 'iirc', 'ffs', 'fml', 'idgaf', 'stfu', 'tf',
                        'omw', 'rn', 'ttyl', 'tyt', 'bball')

# Add stop words found through iterations
stopsIterative <- 
  c('amp', 'years', 'beat', 'day', 'night', 'rt', 'pst', 'ive', 'link',
    'league', 'finals', 'watch', 'guard', 'trade', 'win', 'index pointing',
    'pick', 'free', 'ago', 'head', 'big', 'center', 'luck', 'backhand index',
    'make', 'itus', 'ers', 'theu', 'man', 'chance', 'person', 'click link',
    'conference', 'forward', 'history', 'donut', 'ium', 'pm pst',
    'made', 'great', 'deal', 'harden', 'owner', 'full', 'jan pm', 'includes',
    'news', 'ast', 'thu', 'left', 'breaking', 'bubble',
    'uff', 'power', 'usa', 'assistant', 'contract', 'arrowufef', 'tonight',
    'starting', 'video', 'sources', 'good', 'ufb', 'le',
    'ad', 'de', 'uf', 'hu', 'makes', 'ua', 'back', 'time',
    'ufd', 'gt', 'ufecu', 'check', 'nwt', 'blanku', 'retweets',
    'stream', 'top', 'final', 'record', 'team', 'youtube',
    'people', 'week', 'young', 'edition', 'gagnez', 'giving',
    'concours', 'maillot', 'ownsu', 'green', 'closet', 
    'closet', 'red', 'blue', 'yellow', 'white', 'size', '<+>',
    'million', 'air', 'color', 'retweet', 'black', 'game',
    '<+><+>', 'notifications', 'ends', 'ufuf', 'iull', 'ucufef',
    'winner', 'gaming', 'friend', 'iud', 'winners', 'friends',
    'ufac', 'cash', 'uffuff', 'hcz', 'uufef', 'ufe', 'ufc', 'circle', 'purple',
    'canut', 'rts', 'est', 'rts', 'canut', 'ubufef', 'ufa', 'entries', 'today',
    'endsarsuauauffufec', 'fov', 'ufufuf', 'ium', 'thatus', 'random', 'set',
    'heartufefchristmas', 'ufaeuf', 'uaufef', 'christmas', 'coldwar', 'war',
    'thisufufuffeuduufef', 'chair', 'uecuecuecuec', 'car', 'items', 'included',
    'uecuecuecuecuecuecuecuecuec', 'blackopscoldwar', 'tweet', 'holidays',
    'follow', 'enter', 'war', 'giveaway', 'cold', 'warzone', 'face', 'games',
    'call', 'tag', 'reply', 'give', 'live', 'play', 'cod', 'ops',
    'callofduty', 'year', 'lucky', 'duty', 'dont', 'button', 'season', 
    'playing', 'copy', 'jan', 'player', 'players', 'series',
    'modern', 'warfare', 'modernwarfare', 'setup', 'greenwall', 'post',
    'click', 'brand', 'crate', 'filled', 'warm', 'entrance', 'deserve', 
    'christmaswere', 'exclusive')

# Aggregate all the above into a single vector 
stopWords <- c(
  stopsAbbreviations,
  stopsIterative,
  stopwords('english'),
  stopwords('SMART'))


##### Create & Clean Corpus #####
corpus <- VCorpus(DataframeSource(teamFollowers))

# Clean the corpus
corpus <- cleanCorpus(corpus, stopWords)

# Save corpus as dataframe
cleanedCorpusDF <-
  data.frame(text = unlist(sapply(corpus, `[`,"content")),
             stringsAsFactors=F)

# Export cleaned corpus as dataframe in csv format
write.csv(cleanedCorpusDF,'./_data/_manipulated/cleanedCorpus.csv', 
          row.names = F)

# Clean environment
rm(stopsAbbreviations, stopsIterative)

#' 
## ----create TDM (unigram & bigram), message=FALSE, warning=FALSE-----------------------------------------------
# Import cleaned tweets
#cleanedCorpusDF <- read_csv( './_data/_manipulated/cleanedCorpus.csv')
#corpus <- VCorpus(VectorSource(cleanedCorpus))

# Convert corpus into UNIGRAM Term Document Matrix
TDM   <- TermDocumentMatrix(corpus)
TDMm  <- as.matrix(TDM)

# BIGRAM Term Document Matrix
biTDM  <- TermDocumentMatrix(corpus, control=list(tokenize=bigramTokens))
biTDMm <- as.matrix(biTDM)

#' 
## ----followers per team, message=FALSE, warning=FALSE----------------------------------------------------------
# Create data frame that holds teams and number of followers per team
number_of_followers <- 
  data.frame(Teams = c('Atlanta Faze', 'Dallas Empire', 'Florida Mutineers',
                       'London Royal Ravens', 'LA Guerrillas', 'LA Thieves',
                       'Minnesota Rokkr', 'NY Subliners', 'Optic Chicago',
                       'Paris Legion', 'Seattle Surge', 'Toronto Ultra'),
             Followers = c(76700, 92300, 53000, 56900, 33800, 100600, 58400,
                           58000, 211700, 34900, 53700, 58400))

# Create bar plot of number of flowers per team
followers_per_team <-
  number_of_followers %>% 
  arrange(desc(Followers)) %>% 
  ggplot(., aes(x = reorder(Teams, -Followers), y = Followers, 
                fill = Followers), color="black") +
  geom_bar(stat = 'identity', color = "black") +
  geom_text(aes(label=Followers), position = "stack", vjust=-0.7, size=3) +
  theme(legend.position  = "none",
        panel.grid.major  = element_blank(), 
        panel.grid.minor  = element_blank(), 
        panel.background  = element_rect(fill="transparent", colour=NA),
        plot.background   = element_rect(fill="transparent", colour=NA),
        axis.line   = element_line(colour = "black"),
        axis.text   = element_text(face="bold", color="#000000", size=10),
        axis.text.x = element_text(angle = 30, hjust = 1),
        axis.title  = element_text(face="bold", color="#000000", size=12),
        plot.title  = element_text(face="bold", color="#000000", size=16)) +
  labs(title = "Followers per Team",
       x    = "Teams",
       y    = "Followers",
       fill = "Teams") +
  expand_limits(y = 220000) +
  theme(plot.title = element_text(hjust = 0.5),
        axis.title.x = element_text(vjust = -1),
        axis.title.y = element_text(vjust = 2)) +
  scale_y_continuous(label=comma) +
  scale_fill_gradient2()

# save image
ggsave("./_images/plots/followers_per_team.png", 
       followers_per_team, bg = "transparent")

################################################################################
# Clear environment of what's no longer needed
rm(number_of_followers, followers_per_team)

#' 
## ----polarity distribution, message=FALSE, warning=FALSE-------------------------------------------------------
#Import cleaned tweets
#cleanedCorpusDF <- read_csv( './_data/_manipulated/cleanedCorpus.csv')

# Calculate polarity for partially cleaned tweets
cleanedCorpusPolarity <- polarity(cleanedCorpusDF$text)

# Append polarity scores to cleaned tweet data set
cleanedCorpusDF$polarity <- scale(cleanedCorpusPolarity$all$polarity)

write.csv(cleanedCorpusDF,'./_data/_manipulated/cleanedCorpusPolarity.csv', 
          row.names = F)

# Plot distribution of polarity
polarity_distribution <-
  ggplot(cleanedCorpusDF, aes(x=polarity, y=..density..)) +
    theme_gdocs() +
    geom_histogram(binwidth=0.5, fill="mediumpurple4", colour="grey60", size=.2) +
    geom_density(size=.75) +
    theme(panel.grid.major = element_blank(), 
          panel.grid.minor = element_blank(), 
          panel.background = element_rect(fill="transparent", colour=NA),
          plot.background  = element_rect(fill="transparent", colour=NA),
          axis.line  = element_line(colour = "black"),
          axis.text  = element_text(face="bold", color="#000000", size=10),
          axis.title = element_text(face="bold", color="#000000", size=12),
          plot.title = element_text(face="bold", color="#000000", size=16)) +
    labs(title = "Polarity Distribution",
         x = "Polarity",
         y = "Density") +
    theme(plot.title = element_text(hjust = 0.5))

# save image
ggsave("./_images/plots/polarity_distribution.png", polarity_distribution, bg = "transparent")

#' 
## ----sentiment radar chart, message=FALSE, warning=FALSE-------------------------------------------------------
# Create DTM & tidy it 
DTM      <- removeSparseTerms(DocumentTermMatrix(corpus),0.99)
tidyCorp <- tidy(DTM)

# Instantiate Emotions data frame
nrc <- nrc_emotions

# Find columns with value > 0
terms <- subset(nrc, rowSums(nrc[,2:9])!=0)
sent  <- apply(terms[,2:ncol(terms)], 1, function(x)which(x>0)) 

# Reshape
nrcLex <- list()
for(i in 1:length(sent)){
  x <- sent[[i]]
  x <- data.frame(term      = terms[i,1],
                  sentiment = names(sent[[i]]))
  nrcLex[[i]] <- x
}
nrcLex <- do.call(rbind, nrcLex)

# Perform Inner Join
nrcSent <- inner_join(tidyCorp,nrcLex, by=c('term' = 'term'))

# Aggreggate based on count and sentiment
emos <- aggregate(count ~ sentiment + document, nrcSent, sum)
emos$document <- NULL
emos <- 
  emos %>% 
  group_by(sentiment) %>% 
  summarise(sum(count))

# Plot radar chart
chartJSRadar(scores = emos, labelSize = 13, showLegend = F,
             height = 500)

#' 
## ----mentions per team, message=FALSE, warning=FALSE-----------------------------------------------------------
# Import cleaned corpus
teamFollowers <- read_csv('./_data/_manipulated/teamFollowersSubbed.csv')

# calculate frequency per team
optic        <- sum(stri_count(teamFollowers$text, fixed ='optic'))
empire       <- sum(stri_count(teamFollowers$text, fixed ='empire'))
rokkr        <- sum(stri_count(teamFollowers$text, fixed ='rokkr'))
guerrillas   <- sum(stri_count(teamFollowers$text, fixed ='guerrillas'))

# create data frame of brand & frequencies
teamFreq <- data.frame(terms = c('OpTic','Empire', 
                                 'Rokkr', 'Guerrillas'),
                       freq  = c(optic, empire, rokkr, guerrillas))

# plot share of teams
mentions_per_team <-
  ggplot(teamFreq, aes(x = reorder(terms, freq), y = freq, fill=freq)) + 
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
    expand_limits(y = 390) +
    labs(title = "Mentions per Tean",
         x = "Team",
         y = "Mentions") +
    theme(plot.title = element_text(hjust = 0.5))

# save image
ggsave("./_images/plots/mentions_per_team.png", mentions_per_team, bg = "transparent")

# clean environment
rm(optic, empire, rokkr, guerrillas, teamFreq, mentions_per_team, teamFollowers)

#' 
## ----pyramid plot, message=FALSE, warning=FALSE----------------------------------------------------------------

## OPTIC vs EMPIRE

# Import cleaned tweets
partially_cleaned_tweets <- 
  read_csv('./_data/_manipulated/teamFollowersSubbed.csv')

# Create data frames containing 'nike' and 'adidas'
optic_df <- partially_cleaned_tweets[
  str_detect(partially_cleaned_tweets$text, "optic|chicago"), ]

empire_df <- partially_cleaned_tweets[
  str_detect(partially_cleaned_tweets$text, "dallas|empire"), ]


# Export above dataframes
write.csv(optic_df,'./_data/_manipulated/optic.csv', 
          row.names = F)
write.csv(empire_df,'./_data/_manipulated/empire.csv', 
          row.names = F)

# Read in data, clean & organize into TDMs
textA <- cleanMatrix(pth             = './_data/_manipulated/optic.csv',
                     columnName      = 'text',
                     collapse        = T, 
                     customStopwords = c(stopWords, 'optic|chicago|opticchi',
                                         'launch', 'brand','gonna','huntsmen',
                                         'bethehunter', 'cdlplayoffs'),
                     type = 'TDM', 
                     wgt = 'weightTf') # weightTfIdf or weightTf

textB <- cleanMatrix(pth        = './_data/_manipulated/empire.csv',
                     columnName = 'text',
                     collapse   = T,
                     customStopwords = c(stopWords, 'dallas|empire|dallasempire',
                                         'lets', 'series', 'hastr', 'scuf',
                                         'cdl', 'post', 'fire', 'pieces'),
                     type = 'TDM', 
                     wgt = 'weightTf')

# Create merged data set of two sets of documents
pyramid_df         <- merge(textA, textB, by ='row.names')
names(pyramid_df)  <- c('terms', 'optic', 'empire')

# Calculate the absolute differences among the common terms
pyramid_df$diff <- abs(pyramid_df$optic - pyramid_df$empire)

# Organize data frame for plotting
pyramid_df <- pyramid_df[order(pyramid_df$diff, decreasing=TRUE), ]
top15 <- pyramid_df[1:10, ]

# Pyarmid Plot
pyramid.plot(lx         = top15$optic, #left
             rx         = top15$empire,    #right
             labels     = top15$terms,  #terms
             top.labels = c('', '', ''), #corpora
             gap        = 20, # space for terms to be read
             main       = 'Words in Common', # title
             unit       = 'Word Frequency',
             lxcol      = 'darkblue',
             rxcol      = 'darkred') 

#' 
## ----cdl associations, message=FALSE, warning=FALSE------------------------------------------------------------
# CDL associations
cdlAssociations <- findAssocs(TDM, 'cdl', 0.25)

# Organize the word associations
cdlAssocDF <- data.frame(terms=names(cdlAssociations[[1]]),
                         value=unlist(cdlAssociations))
cdlAssocDF$terms <- factor(cdlAssocDF$terms, levels=cdlAssocDF$terms)
rownames(cdlAssocDF) <- NULL

# Make a dot plot
cdlAssocPlot <-
  ggplot(cdlAssocDF, aes(y=terms)) +
  geom_point(aes(x=value), data=cdlAssocDF, col='#00008b') +
  theme_gdocs() + 
  geom_text(aes(x=value,label=value), colour="darkblue",hjust=-0.5, vjust ="inward" , size=3) +
  labs(title = "CDL Associations",
       x = 'Association Level',
       y = 'Terms') +
  theme(plot.title = element_text(hjust = 0.5)) +
  theme(legend.position = "none", 
        panel.background = element_rect(fill="transparent", colour=NA),
        plot.background  = element_rect(fill="transparent", colour=NA),
        axis.text  = element_text(face="bold", color="#000000", size=10),
        axis.title = element_text(face="bold", color="#000000", size=12),
        plot.title = element_text(face="bold", color="#000000", size=16)) +
  expand_limits(x = 0.4)

# save image
ggsave("./_images/plots/associations_cdl.png", cdlAssocPlot, bg = "transparent")

# Clean environment
rm(cdlAssocDF, cdlAssocPlot, cdlAssociations)

#' 
## ----team associations, message=FALSE, warning=FALSE-----------------------------------------------------------
#Credit to Max Lembke's code from the NBA_case assignment

# Renaming
tdm <- TDM

# Terms of interest 
toi1 <- "empire" 
toi2 <- "optic"
toi3 <- "rokkr"
toi4 <- "guerrillas"

# Lower correlation limit 
corlimit <- 0.30

# Computing association and storing 
corr1 <-  findAssocs(tdm, toi1, corlimit)[[1]]
corr1 <- cbind(read.table(text = names(corr1), stringsAsFactors = FALSE), corr1)
corr2 <- findAssocs(tdm, toi2, corlimit)[[1]]
corr2 <- cbind(read.table(text = names(corr2), stringsAsFactors = FALSE), corr2)
corr3 <- findAssocs(tdm, toi3, corlimit)[[1]]
corr3 <- cbind(read.table(text = names(corr3), stringsAsFactors = FALSE), corr3)
corr4 <- findAssocs(tdm, toi4, corlimit)[[1]]
corr4 <- cbind(read.table(text = names(corr4), stringsAsFactors = FALSE), corr4)

# Merging stored results 
two_terms_corrs_1 <- full_join(corr1, corr2)
two_terms_corrs_2 <- full_join(corr3, corr4)
two_terms_corrs <- full_join(two_terms_corrs_1,two_terms_corrs_2)

# Gathering for plot
two_terms_corrs_gathered <- gather(two_terms_corrs, term, correlation, corr1:corr4)

# Renaming corr back with terms 
two_terms_corrs_gathered$term <- ifelse(two_terms_corrs_gathered$term  == "corr1", toi1, two_terms_corrs_gathered$term)
two_terms_corrs_gathered$term <- ifelse(two_terms_corrs_gathered$term  == "corr2", toi2, two_terms_corrs_gathered$term)
two_terms_corrs_gathered$term <- ifelse(two_terms_corrs_gathered$term  == "corr3", toi3, two_terms_corrs_gathered$term)
two_terms_corrs_gathered$term <- ifelse(two_terms_corrs_gathered$term  == "corr4", toi4, two_terms_corrs_gathered$term)

# Removing outliers 
two_terms_corrs_gathered <- two_terms_corrs_gathered[-c(28, 88), ]


# Plotting 
team_associations <- 
  ggplot(two_terms_corrs_gathered, 
         aes(x = V1, y = correlation, colour =  term ) ) +
    geom_point(size = 3) +
    theme_bw() +
    theme(axis.text.x       = element_text(angle = 45, hjust = 1),
          axis.line         = element_line(colour = "black"),
          axis.text         = element_text(color="#000000", size=9),
          axis.title        = element_text(face="bold", color="#000000", size=12), 
          legend.background = element_rect(fill="transparent", colour=NA),
          legend.title      = element_blank(),
          panel.grid.minor  = element_blank(), 
          panel.background  = element_rect(fill="transparent", colour=NA),
          plot.background   = element_rect(fill="transparent", colour=NA)) +
    labs(x = "Words",
         y = "Association Level") +
    scale_color_manual(labels = c("Empire", "Guerrilas", "OpTic", "Rokkr"), 
                       values = c("goldenrod4", "black", "darkgreen", "mediumpurple4"))

# Save plot 
ggsave("./_images/plots/associations_team.png", team_associations, bg = "transparent")

# Clean environment
rm(corr1, corr2, corr3, corr4, tdm, toi1, toi2, toi3, toi4, corlimit, team_associations,
   two_terms_corrs, two_terms_corrs_1, two_terms_corrs_2, two_terms_corrs_gathered)

#' 
#' --------------------------------------------------------------------------------
#' 
## ----NOT USED top unigrams (bar plot & wordcloud), message=FALSE, warning=FALSE--------------------------------
# Create frequency data frame
tweetSums <- rowSums(TDMm)
tweetFreq <- data.frame(word=names(tweetSums),frequency=tweetSums)
rownames(tweetFreq) <- NULL

# Instantiate variable that holds top frequency terms
#topWords      <- subset(tweetFreq, between(tweetFreq$frequency, 150, 200))
topWords      <- subset(tweetFreq, tweetFreq$frequency > 100)
# Title-ize words for pretty plots
topWords$word <- stri_trans_totitle(topWords$word)
# Order by highest frequency
topWords      <- topWords[order(topWords$frequency, 
                                decreasing=F),]
# Factorize terms
topWords$word <- factor(topWords$word, 
                        levels=unique(as.character(topWords$word)))

# Plot frequency bar plot
ggplot(topWords, aes(x=word, y=frequency, fill=frequency)) + 
  geom_bar(stat="identity") + 
  coord_flip() + 
  geom_text(aes(label=frequency), colour="black",hjust=-0.25, size=3.3) + 
  theme(legend.position  = "none", 
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(), 
        panel.background = element_rect(fill="transparent", colour=NA),
        plot.background  = element_rect(fill="transparent", colour=NA),
        axis.line  = element_line(colour = "black"),
        axis.text  = element_text(face="bold", color="#000000", size=10),
        axis.title = element_text(face="bold", color="#000000", size=13),
        plot.title = element_text(face="bold", color="#000000", size=16)) +
  labs(title = "Most Frequent Words",
       x = "Words",
       y = "Frequency") +
  theme(plot.title   = element_text(hjust = 0.3, vjust = 1),
        axis.title.y = element_text(hjust = 1, vjust = 1.2))


# Plot word cloud
wordcloud(words        = tweetFreq$word, 
          freq         = tweetFreq$frequency, 
          min.freq     = 50,
          random.order = F, 
          rot.per      = 0.35, 
          colors       = c('black', 'darkblue', 'darkred'),
          use.r.layout = T)

#' 
## ----NOT USED top bigrams (bar plot & wordcloud), message=FALSE, warning=FALSE---------------------------------
# Create frequency data frame
tweetSums <- rowSums(biTDMm)
tweetFreq <- data.frame(word=names(tweetSums),frequency=tweetSums)
rownames(tweetFreq) <- NULL

# Instantiate variable that holds top frequency terms
#topWords      <- subset(tweetFreq, between(tweetFreq$frequency, 150, 200))
topWords      <- subset(tweetFreq, tweetFreq$frequency > 80)
# Title-ize words for pretty plots
topWords$word <- stri_trans_totitle(topWords$word)
# Order by highest frequency
topWords      <- topWords[order(topWords$frequency, 
                                decreasing=F),]
# Factorize terms
topWords$word <- factor(topWords$word, 
                        levels=unique(as.character(topWords$word)))

# Plot frequency bar plot
ggplot(topWords, aes(x=word, y=frequency, fill=frequency)) + 
  geom_bar(stat="identity") + 
  coord_flip() + 
  geom_text(aes(label=frequency), colour="black",hjust=-0.25, size=3.3) + 
  theme(legend.position  = "none", 
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(), 
        panel.background = element_rect(fill="transparent", colour=NA),
        plot.background  = element_rect(fill="transparent", colour=NA),
        axis.line  = element_line(colour = "black"),
        axis.text  = element_text(face="bold", color="#000000", size=10),
        axis.title = element_text(face="bold", color="#000000", size=13),
        plot.title = element_text(face="bold", color="#000000", size=16)) +
  labs(title = "Most Frequent Words",
       x = "Words",
       y = "Frequency") +
  expand_limits(y = 200)+
  theme(plot.title   = element_text(hjust = 0.3, vjust = 1),
        axis.title.y = element_text(hjust = 1, vjust = 1.2))


# Plot word cloud
wordcloud(words        = tweetFreq$word, 
          freq         = tweetFreq$frequency, 
          min.freq     = 35,
          random.order = F, 
          rot.per      = 0.35, 
          colors       = c('black', 'darkblue', 'darkred'),
          use.r.layout = T)

#' 
## ----NOT USED polarity word cloud, message=FALSE, warning=FALSE------------------------------------------------
# Import polarized tweets
cleanedCorpusDF <- read_csv( './_data/_manipulated/cleanedCorpusPolarity.csv')

# Subset tweet data set into positive and negative data sets
positive_tweets <- subset(cleanedCorpusDF$text, 
                          cleanedCorpusDF$polarity > 0)

negative_tweets <- subset(cleanedCorpusDF$text, 
                          cleanedCorpusDF$polarity < 0)

# Collapse the above subsets into two distinct documents
positive_terms <- paste(positive_tweets, collapse = " ")
negative_terms <- paste(negative_tweets, collapse = " ")

# Combine the above documents into a single character vector
all_terms <- c(positive_terms,negative_terms)

# Create a corpus of two documents containing all positive & negative tweets
all_corpus <- VCorpus(VectorSource(all_terms))

# Clean the corpus
all_corpus <- 
  cleanCorpus(all_corpus, c(stopWords, 'fun', 'happyweure', 'work',
                            'weure', 'merry', 'ready', 'love', 'miss',
                            'entry', 'announce', 'tomorrows', 'special'))

# Create Term Document Matrix
polarity_TDM   <- TermDocumentMatrix(all_corpus)
polarity_TDMm  <- as.matrix(polarity_TDM)
colnames(polarity_TDMm) <- c('Positive', 'Negative')

# Plot polarity comparison cloud 
comparison.cloud(term.matrix = polarity_TDMm,
                 max.words   = 25,
                 colors      = c('darkgreen', 'darkred'))

#' 
#' 
