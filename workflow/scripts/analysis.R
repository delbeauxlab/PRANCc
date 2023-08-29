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
# create empty data frame, countries vector, amrs vector
regionamr <- data.frame()
countries <- c()
amrs <- c()

# loop over all entries in dframe1
for(i in 1:nrow(dframe1)) {
  # check if Country empty empty
  if(!(dframe1$Country[[i]] == '')) {
    # check if Country entry not already in countries vector
    if(!(dframe1$Country[[i]] %in% countries)) {
      # then add it in 
      countries <- c(countries,dframe1$Country[[i]])
    }
  }
  # create a vector of the entries in AMR.Gene.symbol to work with
  amrlist <- unlist(strsplit(dframe1$AMR.Gene.symbol[[i]], ','))
  # check there are actually entries in amrlist
  if(length(amrlist)) {
    # if so loop over amrlist
    for(j in 1:length(amrlist)) {
      # check if amr gene is already in amrs vector
      if(!(amrlist[j] %in% amrs)) {
        # if not, add it in
        amrs <- c(amrs,amrlist[j])
      }
    }
  }
}
# create an empty matrix to work with of width number of amrs found + 1
# and rows equal to the number of countries. start all entries off at 0
empty_matrix <- matrix(0,nrow=length(countries),ncol=(length(amrs)+1))
# create a data frame from that matrix, with row names of the countries
regionamr <- data.frame(empty_matrix, row.names=countries)
# name the columns after the amrs found, with the first entry being Count
colnames(regionamr) <- c('Count', amrs)
# loop over entries in dframe
for(k in 1:nrow(dframe1)) {
  # check if country recorded
  if(!(dframe1$Country[k] == '')) {
    # each time a country is found, add one to Count
    regionamr[dframe1$Country[k],'Count'] <- regionamr[dframe1$Country[k],'Count'] + 1
    # create amrlist vector
    amrlist <- unlist(strsplit(dframe1$AMR.Gene.symbol[[k]], ','))
    # check found amrs
    if(length(amrlist)) {
      # loop over list
      for(l in 1:length(amrlist)) {
        # for each amr in list, add one to the row/column corresponding to
        # country/amr
        regionamr[dframe1$Country[k],amrlist[l]] <- regionamr[dframe1$Country[k],amrlist[l]] + 1
      }
    }
  }
}

# create a bar chart plot
library(ggplot2)
# requires a data frame with three columns, countries, amrs, values
# requires one country entry PER AMR, and then the corresponding count value
# length will therefore be country * amr
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
# actually plot geom bar determines stacking/dodging
ggplot(plotdata, aes(fill=plotamrs, y=values, x=plotcountries)) + 
  geom_bar(position='dodge', stat='identity')

# create a heatmap
# cast regionamr dataframe to matrix
regionamrmatrix<- as.matrix(regionamr)
# strip out count - note, I think all this needs to be normalised by Count
# need to create bins for both region and amr
regionamrmatrix <- regionamrmatrix[,colnames(regionamrmatrix)!='Count']
# create heatmap
heatmap(regionamrmatrix)
# create heatmap and automatically scale by row
heatmap(regionamrmatrix,scale='row')
#learn shinyapp for regional heatmap
