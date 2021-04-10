# Create a list of lists that hold all stop word txt files
stopWords <- lapply(list.files(path       = './_data/stopwords/',
                               pattern    = '*.txt',
                               recursive  = T,
                               full.names = T),
                    read.delim, header = F)

# Unpack lists into unique vectors and split the string
stopsEngAdjectives <- unlist(strsplit(stopWords[[1]][[1]], ','))
stopsEngWords      <- unlist(strsplit(stopWords[[5]][[1]], ','))
stopsMySQL         <- unlist(strsplit(stopWords[[7]][[1]], ','))
stopsNonEnglish    <- unlist(strsplit(stopWords[[8]][[1]], ','))
stopsSMART         <- unlist(strsplit(stopWords[[10]][[1]], ','))
stopsTwitterTA     <- unlist(strsplit(stopWords[[13]][[1]], ','))


# Unpack large lists and store them in chunks of 500 within another list
stopsEngAdverbs        <- unlist(strsplit(stopWords[[2]][[1]], ','))
stopsEngAdverbs_chunks <- split(stopsEngAdverbs,
                                rep(1:ceiling(length(stopsEngAdverbs)/500),
                                    each=500)[1:length(stopsEngAdverbs)])
stopsEngVerbs          <- unlist(strsplit(stopWords[[4]][[1]], ','))
stopsEngVerbs_chunks   <- split(stopsEngVerbs,
                                rep(1:ceiling(length(stopsEngVerbs)/500),
                                    each=500)[1:length(stopsEngVerbs)])
stopsExtra             <- unlist(stopWords[[6]][[1]])
stopsExtra_chunks      <- split(stopsExtra,
                                rep(1:ceiling(length(stopsExtra)/500),
                                    each=500)[1:length(stopsExtra)])
stopsWords             <- unlist(stopWords[[11]][[1]])
stopsWords_chunks      <- split(stopsWords,
                                rep(1:ceiling(length(stopsWords)/500),
                                    each=500)[1:length(stopsWords)])

# Add stop words for abbreviations
stopsAbbreviations = c('lol', 'smh', 'rofl', 'lmao', 'lmfao', 'wtf', 'btw', 
                        'nbd','nvm', 'lmk', 'kk', 'obvi', 'obv', 'srsly', 
                        'rly', 'tmi', 'ty', 'tyvm', 'yw', 'fomo', 'ftw', 
                        'icymi', 'icyww', 'ntw', 'omg', 'omfg', 'idk', 'idc', 
                        'jell', 'iirc', 'ffs', 'fml', 'idgaf', 'stfu', 'tf',
                        'omw', 'rn', 'ttyl', 'tyt', 'bball')

stopsIterative <- 
  c('amp', 'years', 'beat', 'day', 'night',
    'league', 'finals', 'watch', 'guard', 'trade', 'win',
    'pick', 'free', 'ago', 'head', 'big', 'center', 'luck',
    'make', 'itus', 'ers', 'theu', 'man', 'chance', 'person',
    'conference', 'forward', 'history', 'donut', 'ium', 
    'made', 'great', 'deal', 'harden', 'owner', 'full',
    'news', 'ast', 'thu', 'left', 'breaking', 'bubble',
    'uff', 'power', 'usa', 'assistant', 'contract',
    'starting', 'video', 'sources', 'good', 'ufb', 'le',
    'ad', 'de', 'uf', 'hu', 'makes', 'ua', 'back', 'time',
    'ufd', 'gt', 'ufecu', 'check', 'nwt', 'blanku', 'retweets',
    'stream', 'top', 'final', 'record', 'team', 'youtube',
    'people', 'week', 'young', 'edition', 'gagnez', 'giving',
    'concours', 'maillot', 'ownsu', 'green', 'closet', 
    'closet', 'red', 'blue', 'yellow', 'white', 'size', '<+>',
    'million', 'air', 'color', 'retweet', 'black', 'game',
    '<+><+>', 'notifications', 'ends', 'ufuf', 'iull',
    'winner', 'gaming', 'friend', 'iud', 'winners', 'friends',
    'ufac', 'cash', 'uffuff', 'hcz', 'uufef', 'ufe', 'ufc',
    'canut', 'rts', 'est', 'rts', 'canut', 'ubufef', 'ufa',
    'endsarsuauauffufec', 'fov', 'ufufuf', 'ium', 'thatus',
    'heartufefchristmas', 'ufaeuf', 'uaufef', 'christmas',
    'thisufufuffeuduufef', 'chair', 'uecuecuecuec', 'car',
    'uecuecuecuecuecuecuecuecuec', 
    'follow', 'enter', 'war', 'giveaway', 'cold', 'warzone', 
    'face', 'games', 'call', 'tag', 'reply', 'give', 'live', 
    'play', 'cod', 'ops', 'cdl', 
    'callofduty', 'year', 'lucky', 'duty', 'dont', 'button', 'season', 
    'playing')

# Aggregate all the above into a single vector 
stopWords <- c(
  stopsEngAdjectives,
  stopsEngWords, 
  stopsMySQL, 
  stopsNonEnglish, 
  stopsSMART, 
  stopsTwitterTA,
  stopsIterative,
  stopwords('english'),
  stopwords('SMART'))

# Clear environment for clarity sake
rm(i, stopsEngAdjectives, stopsEngAdverbs, stopsEngPrepConj, stopsEngVerbs,
   stopsEngWords, stopsMySQL, stopsNonEnglish, stopsSMART, stopsTwitterTA,
   stopsWords, stopsExtra, stopsIterative, stopsAbbreviations)