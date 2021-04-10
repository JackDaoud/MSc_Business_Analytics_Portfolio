# load in the libraries we'll need
library(tidyverse)
library(tidytext)
# install.packages("textdata")
library(textdata)
# library(stringr)


# get a list of the files in the reviews directory
files <- list.files("reviews")
# summary(files)

# the function that takes the name of a file and returns the # of positive
# sentiment words, negative sentiment words, the difference 
GetSentiment <- function(file) {
  # get the file
  fileName <- paste("reviews/", file, sep = "")
  file_name <- as.numeric(strsplit(file, ".txt")[[1]][[1]])

  # read in the new file
  fileText <- read_file(fileName)
  # remove any dollar signs (they're special characters in R)
  fileText <- gsub("\\$", "", fileText) 
  
  # tokenize
  tokens <- tibble(text = fileText) %>% 
    unnest_tokens(word, text) %>% 
    add_row(word = "good") %>% # to have at least one positive word, otherwise the code throws an error
    add_row(word = "bad") # to have at least one negative word, otherwise the code throws an error
  
  # get the sentiment from the text: 
  sntmnt <- tokens %>%
    inner_join(get_sentiments("bing")) %>% # pull out only sentiment words ##241
    count(sentiment) %>% # count the # of positive & negative words
    spread(sentiment, n, fill = 0) %>% # made data wide rather than narrow
    # mutate(sentiment = positive - negative) %>% # # of positive words - # of negative words
    mutate(sentiment = (positive - negative) / nrow(tokens)) %>% # # of positive words - # of negative words
    mutate(id = file_name) #%>% # add the name of the file

  # return our sentiment dataframe
  return(sntmnt)
}


# file to put our output in
sentiments <- tibble()

# get the sentiments for each file in our datset
for(file in files){
  sentiments <- rbind(sentiments, GetSentiment(file))
}

