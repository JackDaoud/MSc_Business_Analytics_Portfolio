# Supporting Functions 

################################################################################
bigramTokens <- function(x) {
  unlist(lapply(NLP::ngrams(words(x), 2), 
                paste, collapse = " "), use.names = F)
}

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
  text_column <- gsub('http\\S+\\s*', '', text_column)
  text_column <- gsub('(RT|via)((?:\\b\\W*@\\w+)+)', '', text_column)
  text_column <- gsub('[[:punct:]]', '', text_column)
  text_column <- tryTolower(text_column)
  return(text_column)
}

################################################################################
cleanCorpus<-function(corpus, stopWords){
  #corpus <- tm_map(corpus, content_transformer(qdap::replace_contraction)) 
  corpus <- tm_map(corpus, content_transformer(qdapRegex::rm_url))
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, removeNumbers)
  corpus <- tm_map(corpus, stripWhitespace)
  corpus <- tm_map(corpus, content_transformer(tryTolower))
  corpus <- tm_map(corpus, removeWords, stopWords)
  return(corpus)
}

################################################################################
cleanMatrix <- function(pth, columnName, collapse = F, customStopwords, 
                        type, wgt){

  print(type)
  
  if(grepl('.csv', pth, ignore.case = T)==T){
    print('Reading in csv')
    text      <- read.csv(pth)
    text      <- text[,columnName]
  }
  if(grepl('.fst', pth)==T){
    print('Reading in fst')
    text      <- fst::read_fst(pth)
    text      <- text[,columnName]
  } 
  if(grepl('csv|fst', pth, ignore.case = T)==F){
    stop('The specified path is not a csv or fst')
  }
 
  
  if(collapse == T){
    text <- paste(text, collapse = ' ')
  }
  
  print('Cleaning text...')
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
    stop('Type needs to be either TDM or DTM')
  }
  
 
  }
  print('Complete!')
  return(response)
}