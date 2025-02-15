#' title: Document Classification Model
#" subtitle: Informing Government Policy Decisions
#' author: Jack Daoud

  
# Setup


# load Packages
lapply(c('plyr', "stringi", 'text2vec', 'glmnet', "qdap", "tm", "ggthemes", 
         'magrittr', 'ggplot2', 'dplyr', 'readr', 'stringr', 'tidyr',
         'wordcloud', 'tidytext', 'mgsub', 'reshape2', 'caret', 'text2vec',
         'RTextTools', 'yardstick'),
       require, character.only = TRUE)

# load supporting functions & stopwords
source('./_other/supportingFunctions.R')

# set options
options(stringsAsFactors = FALSE)
Sys.setlocale('LC_ALL', 'C')

# set working directory
#setwd('~/Documents/Github/hult_NLP/personal/HW/HW2')


# Sample


# Load data
trainingTXT <- read.csv('./_data/student_tm_case_training_data.csv')
testTXT     <- read.csv('./_data/student_tm_case_score_data.csv')

# Adjust column names for corpus processing
names(trainingTXT)[1:2] <- c("doc_id", "text")
names(testTXT)[1:2]     <- c("doc_id", "text")

# Split training set into train/validate sets
### SAMPLE : Patritioning
idx          <- createDataPartition(trainingTXT$label,p=.7,list=F)
trainTXT     <- trainingTXT[idx,]
validateTXT  <- trainingTXT[-idx,]


# Explore


# Partially text column & save partially cleaned data
trainingTXT$text  <- basicSubs(trainingTXT$text)

# Create a volatile corpus
trainingCorpus <- VCorpus(DataframeSource(trainingTXT))

# Instantiate stopwords
stopWords <- c(stopwords('SMART'), stopwords('english'))

# Clean the corpus
trainingCorpus <- cleanCorpus(trainingCorpus, stopWords)

# Convert to Document Term Matrix
TDM  <- TermDocumentMatrix(trainingCorpus)
TDMm <- as.matrix(TDM)

# Frequency Data Frame
tweetSums <- rowSums(TDMm)
tweetFreq <- data.frame(word=names(tweetSums),frequency=tweetSums)
rownames(tweetFreq) <- NULL



# Are the labels balanced or unbalanced?
classification <- as.data.frame(ifelse(trainingTXT$label == 1, "Yes", "No"))
names(classification)[1] <- "label"  
classification$label <- as.factor(classification$label)

classification %>% 
  group_by(label) %>% 
  summarise(count = n()) %>% 
  ggplot(., aes(x = label, y = count, fill = count)) +
  geom_bar(stat = 'identity') +
  theme(legend.position  = "none",
        panel.grid.major  = element_blank(), 
        panel.grid.minor  = element_blank(), 
        panel.background  = element_rect(fill="transparent", colour=NA),
        plot.background   = element_rect(fill="transparent", colour=NA),
        axis.line   = element_line(colour = "black"),
        axis.text   = element_text(face="bold", color="#000000", size=10),
        axis.title  = element_text(face="bold", color="#000000", size=12),
        plot.title  = element_text(face="bold", color="#000000", size=16, hjust = 0.5)) +
  geom_text(aes(label=count), position = "stack", vjust=-0.7, size=4) +
  expand_limits(y = 1600) +
  labs(title = "Political or Civil Tweets",
       x    = "Label",
       y    = "Count")

rm(classification)



# Renaming
tdm <- TDM

# Terms of interest 
toi1 <- "police" 
toi2 <- "cnn"
toi3 <- "civil"
toi4 <- "blm"

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
  scale_color_manual(labels = c("Police", "CNN", "Civil", "BLM"), 
                     values = c("darkblue", "darkred", "darkgreen", "black"))

# Clean environment
rm(corr1, corr2, corr3, corr4, tdm, toi1, toi2, toi3, toi4, corlimit,
   two_terms_corrs, two_terms_corrs_1, two_terms_corrs_2, two_terms_corrs_gathered)



wordcloud(words        = tweetFreq$word, 
          freq         = tweetFreq$frequency, 
          min.freq     = 20,
          random.order = F, 
          rot.per      = 0.35, 
          colors       = c('black', 'darkred','darkblue'),
          use.r.layout = T)

# Clean environment
rm(tweetFreq, tweetSums, trainingCorpus, TDM, TDMm)


# Modify


# Instantiate stopwords
stopWords <- c(stopwords('SMART'), stopwords('english'))

######################### Training Set Modification ######################### 

# Initial iterator to make vocabulary
trainIterMaker <- itoken(trainTXT$text,
                         preprocess_function = list(toLower),
                         progressbar         = T)

trainTextVocab <- create_vocabulary(trainIterMaker, stopwords = stopWords)

# Prune vocab to make DTM smaller
trainPrunedtextVocab <- prune_vocabulary(trainTextVocab,
                                         term_count_min =  10,
                                         doc_proportion_max = 0.5,
                                         doc_proportion_min = 0.001)

# Using the pruned vocabulary to declare the DTM vectors
trainVectorizer <- vocab_vectorizer(trainPrunedtextVocab)

# Take the vocabulary lexicon and the pruned text function to make a DTM
trainDTM  <- create_dtm(trainIterMaker, trainVectorizer)

######################### Validation Set Modification ######################### 

# Initial iterator to make vocabulary
validateIterMaker <- itoken(validateTXT$text,
                            preprocess_function = list(toLower),
                            progressbar         = T)

# Take the vocabulary lexicon and the pruned text function to make a DTM
validateDTM  <- create_dtm(validateIterMaker, trainVectorizer)

######################### Complete Model Modification ######################### 
# To apply the same method and build a complete model to score unseen data

# Initial iterator to make vocabulary
#trainIterMaker <- itoken(trainingTXT$text,
#                         preprocess_function = list(toLower),
#                         progressbar         = T)

#trainTextVocab <- create_vocabulary(trainIterMaker, stopwords = stopWords)

# Prune vocab to make DTM smaller
#trainPrunedtextVocab <- prune_vocabulary(trainTextVocab,
#                                         term_count_min =  10,
#                                         doc_proportion_max = 0.5,
#                                         doc_proportion_min = 0.001)

# Using the pruned vocabulary to declare the DTM vectors
#trainVectorizer <- vocab_vectorizer(trainPrunedtextVocab)

# Initial iterator to make vocabulary
#testIterMaker <- itoken(testTXT$text,
#                        preprocess_function = list(toLower),
#                        progressbar         = T)

# Take the vocabulary lexicon and the pruned text function to make a DTM
#testDTM <- create_dtm(testIterMaker, trainVectorizer)

# Take the vocabulary lexicon and the pruned text function to make a DTM
#testDTM <- create_dtm(testIterMaker, trainVectorizer)


# Model


######################### Training Set Model ######################### 
trainTextFit <- cv.glmnet(trainDTM,
                          y            = as.factor(trainTXT$label),
                          alpha        = 0.9,
                          family       = 'binomial',
                          type.measure = 'auc',
                          nfolds       = 5,
                          intercept    = F)

# Make training predictions
trainingPreds <- predict(trainTextFit, trainDTM, type = 'class')

# Make validation predictions
validationPreds <- predict(trainTextFit, validateDTM, type = 'class')


# Assess


# Print confusion matrix
confusionMatrix(as.factor(trainingPreds),
                as.factor(trainTXT$label))



# Print confusion matrix
confusionMatrix(as.factor(validationPreds),
                as.factor(validateTXT$label))



# Check for best terms by coefficient
bestTerms <- subset(as.matrix(coefficients(trainTextFit)), 
                    as.matrix(coefficients(trainTextFit)) !=0)

# Melt for plotting sake & remove empty column
bestTerms    <- melt(bestTerms, 'word')
bestTerms[2] <- NULL

# Plot positive coefficients & the words
bestTerms %>% 
  filter(value > 0) %>% 
  arrange(desc(value)) %>% 
  ggplot(., aes(x = reorder(word, -value), y = value, fill = value)) +
  geom_bar(stat = 'identity') +
  theme(axis.text.x       = element_text(angle = 45, hjust = 1),
        axis.line         = element_line(colour = "black"),
        axis.text         = element_text(color="#000000", size=9),
        axis.title        = element_text(face="bold", color="#000000", size=12),
        plot.title        = element_text(face="bold", color="#000000", size=16, hjust = 0.5),
        legend.position   = "none",
        panel.grid.minor  = element_blank(), 
        panel.background  = element_rect(fill="transparent", colour=NA),
        plot.background   = element_rect(fill="transparent", colour=NA)) +
  labs(x = "Words",
       y = "Coefficient",
       title =  'Words that are positively correlated with Political tweets')

bestTerms %>% 
  filter(value < 0) %>% 
  arrange(desc(value)) %>% 
  ggplot(., aes(x = reorder(word, -value), y = value, fill = value)) +
  geom_bar(stat = 'identity') +
  theme(axis.text.x       = element_text(angle = 45, hjust = 1),
        axis.line         = element_line(colour = "black"),
        axis.text         = element_text(color="#000000", size=9),
        axis.title        = element_text(face="bold", color="#000000", size=12),
        plot.title        = element_text(face="bold", color="#000000", size=16, hjust = 0.5),
        legend.position   = "none",
        panel.grid.minor  = element_blank(), 
        panel.background  = element_rect(fill="transparent", colour=NA),
        plot.background   = element_rect(fill="transparent", colour=NA)) +
  labs(x = "Words",
       y = "Coefficient",
       title =  'Words that are negatively correlated with Political tweets')

# Clean environment
rm(testTXT, trainDTM, trainingPreds, trainPrunedtextVocab, trainTextFit,
   trainTextVocab, trainTXT, validateDTM, validatePrunedtextVocab, bestTerms,
   validateTextFit, validateTextVocab, validateTXT, validationPreds, trainingTXT)


# Final Model & Scoring



# Import original train & test sets
trainTXT <- read.csv('./_data/student_tm_case_training_data.csv')
testTXT  <- read.csv('./_data/student_tm_case_score_data.csv')

# Adjust column names for corpus processing
names(trainTXT)[1:2] <- c("doc_id", "text")
names(testTXT)[1:2]  <- c("doc_id", "text")

stopWords <- c(stopwords('SMART'), stopwords('english'))

# Clean, extract text and get into correct objects
cleanTrain <- cleanCorpus(VCorpus(VectorSource(trainTXT$text)), stopWords)
cleanTrain <- data.frame(text = unlist(sapply(cleanTrain, `[`, "content")),
                         stringsAsFactors=F)

cleanTest <- cleanCorpus(VCorpus(VectorSource(testTXT$text)), stopWords)
cleanTest <- data.frame(text = unlist(sapply(cleanTest, `[`, "content")),
                        stringsAsFactors=F)

# Combine the matrices to the original to get the tokens joined
allDTM        <- c(cleanTrain[,1], cleanTest[,1])
allDTMm       <- create_matrix(allDTM, language="english")
containerTest <- create_container(matrix    = allDTMm,
                                  labels    = as.factor(trainTXT$label), 
                                  trainSize = 1:nrow(cleanTrain),
                                  testSize  = (nrow(cleanTrain)+1):3000,
                                  virgin    = T)

# Train model
testFit <- train_models(containerTest, algorithms = "GLMNET")

# Save model
saveRDS(testFit, './_model/testFit.rds')

# Import model
testFit <- readRDS('./_model/testFit.rds')

# Classify unseen tweets using our model
resultsTest <- classify_models(containerTest, testFit)

# Create DF of Unseen Tweets + Label + Probability
scoredData <- cbind(testTXT, resultsTest)

# Write as CSV
write.csv(scoredData, './Daoud_TM_scores.csv', row.names = F)

