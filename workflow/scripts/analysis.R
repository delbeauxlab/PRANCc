dframe1 <- read.csv(file.choose())
for(i in 1:ncol(dframe1)) {
  for(k in ncol(i$AMR.Gene.symbol)) {
    
  }
}

for(i in 1:ncol(dframe1)) {
  for(k in 1:nrow(dframe$AMR.Gene.symbol)) {
    print(dframe1$AMR.Gene.symbol[k])
  }
}

nrow(dframe1)

m <- dframe1$AMR.Gene.symbol
n <- as.list(strsplit(m[[5]], ','))

# this is how to create a character vector similar to a python list
# run after gsubs
n <- unlist(strsplit(dframe1$AMR.Gene.symbol[[5]], ','))
n <- unlist(dframe1$AMR.Gene.symbol[[5]])
n[2]
typeof(n)

# strip [,],' out of text in column $AMR.Gene.symbol
dframe1$AMR.Gene.symbol <- gsub("\\[|\\]|\\'",'',dframe1$AMR.Gene.symbol)

dframe1$AMR.Gene.symbol[[5]]

k <- unlist(strsplit(dframe1$AMR.Gene.symbol[[5]], ','))
for (i in 1:length(k)) {
  n <- unlist(strsplit(dframe1$AMR.Gene.symbol[[5]], ','))
  print(n[i])
}

summary(n)

strsplit(m[1], ',')

summary(list(m))


for (k in 1:5) {
  print(m[k])
}



for (k in 1:5) {
  print(dframe1$AMR.Gene.symbol[2][k])
}

