dframe1 <- read.csv(file.choose())
getwd()
dframe1 <- read.csv(file='PRACS/statsdata.csv')
                    
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

# want to create a dataframe that has rows of each country, columns of the
# count of entries per country, and then the count of each amr gene
# Country | Count | pena1234 | porb5678 | mtR1111
# Australia | 3  | 2        | 1        | 0
regionamr <- data.frame()
columns <- c('Country','Count')
colnames(regionamr) <- columns
countries <- c()
amrs <- c()
{
  i = 1
  j = 1
  k = 1
  l = 1
}
for(i in 1:nrow(dframe1)) {
  if(!(dframe1$Country[[i]] == '')) {
    if(!(dframe1$Country[[i]] %in% countries)) {
      countries <- c(countries,dframe1$Country[[i]])
    }
  }
  amrlist <- unlist(strsplit(dframe1$AMR.Gene.symbol[[i]], ','))
  if(length(amrlist)) {
    for(j in 1:length(amrlist)) {
      if(!(amrlist[j] %in% amrs)) {
        amrs <- c(amrs,amrlist[j])
      }
    }
  }
}
empty_matrix <- matrix(0,nrow=length(countries),ncol=(length(amrs)+1))
regionamr <- data.frame(empty_matrix, row.names=countries)
colnames(regionamr) <- c('Count', amrs)
for(k in 1:nrow(dframe1)) {
  if(!(dframe1$Country[k] == '')) {
    regionamr[dframe1$Country[k],'Count'] <- regionamr[dframe1$Country[k],'Count'] + 1
    amrlist <- unlist(strsplit(dframe1$AMR.Gene.symbol[[k]], ','))
    if(length(amrlist)) {
      for(l in 1:length(amrlist)) {
        regionamr[dframe1$Country[k],amrlist[l]] <- regionamr[dframe1$Country[k],amrlist[l]] + 1
      }
    }
  }
}
regionamr['Australia','penA_A510V'] <- regionamr['Australia','penA_A510V'] + 1

library(ggplot2)
ggplot(regionamr) + geom_bar(position="dodge", stat="identity")
plotcountries <- c()
plotamrs <- rep(amrs,length(countries))
length(plotamrs)
values <- c()
for(n in 1:length(countries)) {
  plotcountries <- c(plotcountries,rep(countries[n],length(amrs)))
}
for(n in 1:nrow(regionamr)) {
  for(m in 2:ncol(regionamr)) {
    values <- c(values,regionamr[n,m])
  }
}
length(plotcountries)
length(plotamrs)
length(values)
plotdata <- data.frame(plotcountries,plotamrs,values)
ggplot(plotdata, aes(fill=plotamrs, y=values, x=plotcountries)) + 
  geom_bar(position='dodge', stat='identity')
regionamrmatrix<- as.matrix(regionamr)
regionamrmatrix <- regionamrmatrix[,colnames(regionamrmatrix)!='Count']
heatmap(regionamrmatrix)
heatmap(regionamrmatrix,scale='row')
#learn shinyapp for regional heatmap
