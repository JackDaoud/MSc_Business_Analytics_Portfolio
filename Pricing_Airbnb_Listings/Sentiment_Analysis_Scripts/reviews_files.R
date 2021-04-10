library(data.table)
library(tidyverse)


df2 <- read_csv("./Data/Original Data/listing_reviewsNYC.csv") #, n_max = 2)

if (!dir.exists("reviews")) {
  dir.create("reviews")
}

for (i in 1:nrow(df2)) {
  fwrite(as.list(df2[[i, "comments"]]), 
         paste("reviews/", as.character(df2[[i,2]]), ".txt", sep = ""), 
         col.names = FALSE, 
         row.names = FALSE)
}
