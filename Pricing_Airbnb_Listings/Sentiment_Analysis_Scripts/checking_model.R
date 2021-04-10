# read file with monkeylearn sentiment analysis results
monkeylearn <- read_csv("reviews_sentiment_analysis.csv", n_max = 300)
  
# select needed columns
sentiments <- select(sentiments, id, sentiment)

# join tibbles
monkeylearn <- left_join(monkeylearn, sentiments, by = "id")

# make a new column
monkeylearn$Decision <- ""

# set the threshold
upper_threshold <- -1e-3
lower_threshold <- -0.012

# translate the score into a decision
for (i in 1:nrow(monkeylearn)) {
  if (monkeylearn[[i, 9]] > upper_threshold) {
    monkeylearn[[i, 10]] <- "Positive"
  }
  else if (monkeylearn[[i, 9]] < lower_threshold) {
    monkeylearn[[i, 10]] <- "Negative"
  }
  else {
    monkeylearn[[i, 10]] <- "Neutral"
  }
}

# monkeylearn <- monkeylearn %>% 
#   select(monkeylearn$Decision != "")

# calculate accuracy
(accuracy <- sum(monkeylearn$Decision == monkeylearn$Classification) / nrow(monkeylearn))

# quantities of positive classified cases
sum(monkeylearn$Classification == "Positive")
sum(monkeylearn$Decision == "Positive")

# quantities of negative classified cases
sum(monkeylearn$Classification == "Negative")
sum(monkeylearn$Decision == "Negative")

# quantities of neutral classified cases
sum(monkeylearn$Classification == "Neutral")
sum(monkeylearn$Decision == "Neutral")

