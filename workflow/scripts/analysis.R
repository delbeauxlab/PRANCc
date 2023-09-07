# run at start of session to initialise dframe1 and edit data to be workable ####
# dframe1 <- read.csv(file.choose())
# getwd()
dframe1 <- read.csv(file='PRACS/statsdata.csv')

# this is how to create a character vector similar to a python list
# run after gsubs
#n <- unlist(strsplit(dframe1$AMR.Gene.symbol[[5]], ','))
#n <- unlist(dframe1$AMR.Gene.symbol[[5]])
#n[2]
#typeof(n)

# strip [,],'," out of text in column $AMR.Gene.symbol ####
dframe1$AMR.Gene.symbol <- gsub("\\[|\\]|\\'| |\\\\",'',dframe1$AMR.Gene.symbol)
dframe1$AMR.Gene.symbol <- gsub('\\"','',dframe1$AMR.Gene.symbol)

dframe1$AMR.Gene.symbol[[5]]

k <- unlist(strsplit(dframe1$AMR.Gene.symbol[[5]], ','))
for (i in 1:length(k)) {
  n <- unlist(strsplit(dframe1$AMR.Gene.symbol[[5]], ','))
  print(n[i])
}

# want to create a dataframe that has rows of each country, columns of the ####
# count of entries per country, and then the count of each amr gene
# Country | Count | pena1234 | porb5678 | mtR1111
# Australia | 3  | 2        | 1        | 0
# create empty data frame, countries vector, amrs vector
# note: amrs vector is still dirty. need to sanitise, remove quotes and 
# leading/trailing whitespace
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

# create a bar chart plot ####
# import ggplot2 library
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

# create a heatmap ####
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

# Triangle data ####
# want to analyse how well pathogen.watch amr prediction, ngstar rating
# and amrfinder++ detection agrees

# create method to categorise amrfinder++ genes to resistance classes

categorise_amr <- function(amr_str_list) {
  classres <- c()
  amr_list <- c()
  amr_list <- unlist(strsplit(amr_str_list,','))
  for(n in 1:length(amr_list)) {
    amr <- amr_list[n]
    if(length(amr) == 0 ) {
      next
    }
    if((is.na(amr))) {
      print(n)
      next
    }
    if((startsWith(amr,'penA')) | (startsWith(amr,'mtrR')) | 
      (startsWith(amr,'blaTEM')) | (amr == 'ponA_L421P') | 
      (startsWith(amr,'rpoD')) | (startsWith(amr,'rpoB')) |
      (amr == 'pbp2') | (amr == 'blaI') | (amr == 'blaZ') |
      (startsWith(amr,'porB')) | (amr == 'Ceftriaxone') | 
      (amr == 'Cefixime') | (amr == 'Penicillin')) {
      if(!('Beta-lactams' %in% classres)) {
        classres <- c(classres,'Beta-lactams')
      }
     }
    if((startsWith(amr,'porB')) | (startsWith(amr,'rpsJ')) |
      (startsWith(amr,'mtrR')) | (startsWith(amr,'tet')) |
      amr == 'Tetracycline') {
      if(!('Tetracyclines' %in% classres)) {
        classres <- c(classres,'Tetracyclines')
      }
    }
    if((startsWith(amr,'folP')) | (amr == 'sul2')) {
      if(!('Sulfonamides' %in% classres)) {
        classres <- c(classres,'Sulfonamides')
      }
    }
    if((startsWith(amr,'rpoB'))) {
      if(!('Ansamycins' %in% classres)) {
        classres <- c(classres,'Ansamycins')
      }
    }
    if((startsWith(amr,'gyrA')) | (startsWith(amr,'parC')) |
      (startsWith(amr,'parE')) | (startsWith(amr,'norM')) |
      (startsWith(amr,'gyrB')) | (amr == 'Ciprofloxacin')) {
      if(!('Fluroquinolones' %in% classres)) {
        classres <- c(classres,'Fluroquinolones')
      }
    }
    if((startsWith(amr,'rplD')) | (startsWith(amr,'mtrC')) |
      (startsWith(amr, 'erm')) | (startsWith(amr,'mph')) |
      (startsWith(amr,'rplV')) | (startsWith(amr,'msr')) |
      (startsWith(amr,'erm')) | (startsWith(amr,'23S')) |
      (startsWith(amr,'mtrR')) | (amr == 'Azithromycin')) {
      if(!('Macrolides' %in% classres)) {
        classres <- c(classres,'Macrolides')
      }
    }
    if((startsWith(amr,'aph')) | (startsWith(amr,'norM'))) {
      if(!('Aminoglycosides' %in% classres)) {
        classres <-c(classres,'Aminoglycosides')
      }
    }
    if((startsWith(amr,'catA'))) {
      if(!('Chloramphenicols' %in% classres)) {
        classres <- c(classres,'Chloramphenicols')
      }
    }
    if((startsWith(amr,'fosB'))) {
      if(!('Phosphonics' %in% classres)) {
        classres <- c(classres,'Phosphonics')
      }
    }
    if((startsWith(amr,'dfrA14'))) {
      if(!('Diaminopyrimidines' %in% classres)) {
        classres <- c(classres,'Diaminopyrimidines')
      }
    }
    if((startsWith(amr,'rpsE')) | (amr == 'Aminocyclitols')) {
      if(!('Aminocyclitols' %in% classres)) {
        classres <- c(classres,'Aminocyclitols')
      }
    }
  }
    return(classres)
}
# create method to create list of all found resistances in dframe1
main_res_list <- function(res_list_list) {
  res_type_list <- c()
  for(n in 1:length(res_list_list)) {
    if(!(res_list_list[n] == '')) {
      res_type_list <- c(res_type_list,categorise_amr(res_list_list[n]))
    }
  }
  return(unique(res_type_list))
}

#create method to categorise cas genes
categorise_cas <- function(cas_string_list) {
  return_list <- c()
  if(!(cas_string_list == '')){
    cas_type_list <- unlist(strsplit(cas_string_list, ','))
    for(n in 1:length(cas_type_list)) {
      cas_type <- strsplit(cas_type_list[n],'_')[[1]][1]
      if(!(cas_type %in% return_list))
        return_list <- c(return_list,cas_type)
    }
  }
  return(return_list)
}

# create method to create list of all found cas genes in dframe1
main_cas_list <- function(cas_list_list) {
  cas_type_list <- c()
  for(n in 1:length(cas_list_list)) {
    #cas_list <- categorise_cas(cas_list_list[n])
    cas_type_list <- c(cas_type_list,categorise_cas(cas_list_list[n]))
    cas_type_list <- unique(cas_type_list)
  }
  return(unique(cas_type_list))
}

dframe1$Genes <- gsub("\\[|\\]|\\'| |\\\\",'',dframe1$Genes)
dframe1$Genes <- gsub('\\"','',dframe1$Genes)
test_cas <- 'cas8c_blah, cas4, cas4_test, cas8_test'
test_list <- main_cas_list(dframe1$Genes)
test_list
# write a script that creates a list that counts whenever a resistance was found
# with a specific cas gene Resistance | Cas4 | Cas7 | Cas8c | Cas1 | DEDDh
#                          B-lactam   | 1   |  2   |   0   |  4 | 0
# want to normalise to 0-1 so will count all occurences of resistance as well
list_of_res <- main_res_list(dframe1$AMR.Gene.symbol)
list_of_res <- sort(list_of_res)
test_list <- sort(test_list)

amr_cas_matrix <- matrix(0,nrow=length(list_of_res),ncol=(length(test_list)+1))

amr_cas_counter <- data.frame(amr_cas_matrix, row.names=list_of_res)
colnames(amr_cas_counter) <- c(test_list,'Count')

amr_cas_counter <- data.frame(row.names = list_of_res)
colnames(amr_cas_counter) <- test_list

for(n in 1:nrow(dframe1)) {
  tempamrlist = c()
  tempcaslist = c()
  if(!(dframe1$AMR.Gene.symbol[n] == '') | (dframe1$Genes[n] == '')) {
    tempamrlist <- categorise_amr(dframe1$AMR.Gene.symbol[n])
    tempcaslist <- categorise_cas(dframe1$Genes[n])
    for(m in 1:length(tempamrlist)) {
      amr_cas_counter[tempamrlist[m],'Count'] <- amr_cas_counter[tempamrlist[m],'Count'] +1
      for(o in 1:length(tempcaslist)) {
        amr_cas_counter[tempamrlist[m],tempcaslist[o]] <- amr_cas_counter[tempamrlist[m],tempcaslist[o]] +1
      }
    }
  }
}
counter <- rep(0,ncol(amr_cas_counter))
for(n in 1:ncol(amr_cas_counter)) {
  for(m in 1:length(amr_cas_counter[,n])) {
    counter[n] <- counter[n] + amr_cas_counter[m,n]
    print(counter[n])
  }
}
amr_cas_float_matrix <- matrix(0.0,nrow=length(list_of_res),ncol=length(test_list))
for(n in 1:nrow(amr_cas_float_matrix)) {
  for(m in 1:ncol(amr_cas_float_matrix)) {
    amr_cas_float_matrix[n,m] <- amr_cas_counter[n,m] / sum(amr_cas_counter[m])
  }
}
sum(amr_cas_float_matrix[,3])
amr_cas_floater <- data.frame(amr_cas_float_matrix, row.names=list_of_res)
colnames(amr_cas_floater) <- c(test_list)

plotcas <- c()
for(n in 1:length(test_list)) {
  plotcas <- c(plotcas, rep(test_list[n],length(list_of_res)))
  print(test_list)
}
plotamr <- c()
plotamr <- rep(list_of_res,length(test_list))

length(plotamr)
length(plotcas)
plotvalues <- c()
for(n in 1:length(list_of_res)) {
  for(m in 1:length(test_list)) {
    plotvalues <- c(plotvalues,amr_cas_float_matrix[m,m])
  }
}
for(n in 1:nrow(floatdata)) {
  floatdata$plotvalues[n] <- amr_cas_floater[floatdata$plotamr[n],floatdata$plotcas[n]]
}
plotvalues <- floatdata$plotvalues
length(plotvalues)
floatdata = data.frame(plotcas,plotamr,plotvalues)
sum(floatdata$plotvalues[2-11])
library(ggplot2)
ggplot(floatdata,aes(fill=plotamr, y=plotvalues, x=plotcas)) + 
  geom_bar(position='stack', stat='identity') +
  ggtitle('Relative frequency of AMR presence by cas gene detection') +
  xlab('Cas gene class') + ylab('AMR frequency')
# create two functions, one to curate lists to comparable lists for ngstar and 
# one for comparing pathogetn watch to amrfinder++
# each consist of amr classes found in both tools

plotflip <- data.frame(floatdata$plotamr,floatdata$plotcas,floatdata$plotvalues)
ggplot(floatdata,aes(fill=plotcas, y=plotvalues, x=plotamr)) + 
  geom_bar(position='stack', stat='identity')
compare_ngstar <- function(amr_list) {
  complist <- c()
  for(amr in 1:length(amr_list)) {
    if((amr == 'β-lactams') | (amr == 'Tetracyclines') | 
       (amr == 'Fluroquinolones') | (amr == 'Macrolides')) {
      complist <- c(complist,amr)
    }
  }
  return(complist)
}

compare_pw_amrf <- function(amr_list) {
  complist <- c()
  for(amr in 1:length(amr_list)) {
    if((amr == 'β-lactams') | (amr == 'Tetracyclines') | 
       (amr == 'Fluroquinolones') | (amr == 'Macrolides') |
       (amr == 'Sulfonamides')) {
      complist <- c(complist,amr)
    }
  }
  return(complist)
}

amrdata <- c()
casdata <- c()
for(n in 1:nrow(dframe1)) {
  amrtemp <- unlist(strsplit(dframe1$AMR.Gene.symbol[[n]],','))
  for(m in 1:length(amrtemp)) {
    amrdata <- c(amrdata,amrtemp[m])
  }
  print(paste('Loop ', n, ' of ', nrow(dframe1)))
}
for(n in 1:nrow(dframe1)) {
  castemp <- unlist(strsplit(dframe1$Genes[[n]],','))
  for(m in 1:length(castemp)) {
    casdata <- c(casdata,castemp[m])
  }
  print(paste('Loop ', n, ' of ', nrow(dframe1)))
}
amrdata <- unique(amrdata)
write.csv(amrdata, file='~/amr.csv')
write.csv(unique(casdata),file='~/cas.csv')

# Sex Networks ####
# Create a list of all isolates and if data exists assign to sexual network 
# categories - MSM, MSTSM, MSWM, WSMW, WSW where the middle three are 
# 'crossover' categories. count number of resistance categories per category
# and create box plots. first box plot for overall resistances identified, then
# per resistance category?

metadatamaster <- read.csv(file.choose())
sexcolumns <- c('Sexual behaviour', 'Resistance count', 
                'Aminocyclitols', 'Aminoglycosides', 'Ansamycins', 
                'Beta-lactams', 'Chloramphenicols', 'Diaminopyrimidines',
                'Fluroquinolones', 'Macrolides', 'Phosphonics', 'Sulfonamides',
                'Tetracyclines')
sexrows <- c()
for(n in 1:nrow(metadatamaster)) {
  if(!(metadatamaster$Sexual.behaviour[n] == '')) {
    sexrows <- c(sexrows, metadatamaster$displayname[n])
  }
}
# create two matrices, one for numeric entries and one for text
# then combine them to create the right format for data frame
sex_matrix <- matrix(0,nrow=length(sexrows),ncol=(length(sexcolumns)-1))
sex_matrix_text <- matrix('',nrow=length(sexrows),ncol=1)
sex_matrix <- cbind(sex_matrix_text,sex_matrix)
# create the data frame
sexnetworks <- data.frame(sex_matrix,row.names=sexrows)
colnames(sexnetworks) <- sexcolumns
# now add in data to data frame
for(n in 1:nrow(metadatamaster)) {
  if(!(metadatamaster$Sexual.behaviour[n] == ''))
    sexnetworks[metadatamaster$displayname[n],'Sexual behaviour'] <- 
      metadatamaster$Sexual.behaviour[n]
}
# data cleanup
for(n in 1:nrow(sexnetworks)) {
  if(sexnetworks[n,'Sexual behaviour'] == 'Heterosexual') {
    print(sexrows[n])
  }
}
for(n in 1:nrow(metadatamaster)) {
    if(((metadatamaster$Sexual.behaviour[n] == 'Heterosexual') |
       (metadatamaster$Sexual.behaviour[n] == 'Women')) && 
      (metadatamaster$Host.sex[n] == 'male')) {
           sexnetworks[metadatamaster$displayname[n],'Sexual behaviour'] <- 'MSW'
    }
    if(((metadatamaster$Sexual.behaviour[n] == 'Heterosexual') |
        (metadatamaster$Sexual.behaviour[n] == 'Heterosexual men')) && 
       (metadatamaster$Host.sex[n] == 'female')) {
      sexnetworks[metadatamaster$displayname[n],'Sexual behaviour'] <- 'WSM'
    }
    if(((metadatamaster$Sexual.behaviour[n] == 'Bisexual') |
        (metadatamaster$Sexual.behaviour[n] == 'Bi-sexual') |
        (metadatamaster$Sexual.behaviour[n] == 'Bisexual MSM')) && 
       (metadatamaster$Host.sex[n] == 'male')) {
      sexnetworks[metadatamaster$displayname[n],'Sexual behaviour'] <- 'MSMW'
    }
    if(((metadatamaster$Sexual.behaviour[n] == 'Bisexual') |
        (metadatamaster$Sexual.behaviour[n] == 'Bi-sexual')) && 
       (metadatamaster$Host.sex[n] == 'female')) {
      sexnetworks[metadatamaster$displayname[n],'Sexual behaviour'] <- 'WSMW'
    }
    if(metadatamaster$Sexual.behaviour[n] == 'Bisexual MSM') {
      sexnetworks[metadatamaster$displayname[n],'Sexual behaviour'] <- 'MSMW'
    }
    if((metadatamaster$Sexual.behaviour[n] == 'Heterosexual') && 
       ((metadatamaster$Country[n] == 'UK') | 
        (metadatamaster$Country[n] == 'United Kingdom'))) {
      sexnetworks[metadatamaster$displayname[n],'Sexual behaviour'] <- 'MSW'
    }
    if(metadatamaster$Sexual.behaviour[n] == 'Heterosexual men') {
      sexnetworks[metadatamaster$displayname[n],'Sexual behaviour'] <- 'WSM'
    }
    if(metadatamaster$Sexual.behaviour[n] == 'WSM-E') {
      sexnetworks[metadatamaster$displayname[n],'Sexual behaviour'] <- 'WSM'
    }
}
for(n in 1:nrow(metadatamaster)) {
  if(metadatamaster$Sexual.behaviour[n] == 'Heterosexual') {
    print(paste(metadatamaster$displayname[n], metadatamaster$Country[n],
                sexnetworks[metadatamaster$displayname[n],'Sexual behaviour']))
  }
}
# do the count
for(n in 1:nrow(dframe1)) {
  if(dframe1$id[n] %in% rownames(sexnetworks)) {
    iamr <- categorise_amr(dframe1$AMR.Gene.symbol[n])
    sexnetworks[dframe1$id[n],'Resistance count'] <- sexnetworks[dframe1$id[n],'Resistance count'] + 1
    for(m in 1:length(iamr)) {
      print(paste(n,m,iamr[m]))
      sexnetworks[dframe1$id[n],iamr[m]] <- sexnetworks[dframe1$id[n],iamr[m]] + 1
      print(paste(n,m,iamr[m]))
    }
  }
}
typeof(sexnetworks[1,1])
for(column in 2:ncol(sexnetworks)) {
  sexnetworks[,column] <- as.integer(rep(0,nrow(sexnetworks)))
  print(typeof(sexnetworks[1,column]))
}

# want a dataset that looks like
# Sexual behaviour | total | amr
# MSM | 5 | 1 | 0 | 4 | 0
# WSW | 1 | 1 | 0 | 0 | 0
countsexmatrix <- matrix(as.numeric(0),nrow=length(c('MSW','MSM','MSMW','WSM','TSM','WSMW')),ncol=(length(colnames(sexnetworks))-1))
countsex <- data.frame(countsexmatrix, row.names=c('MSW','MSM','MSMW','WSM','TSM','WSMW'))
colnames(countsex) <- colnames(sexnetworks)[-1]
colnames(sexnetworks)
for(n in 1:nrow(dframe1)) {
  if(dframe1$id[n] %in% rownames(sexnetworks)) {
    if(sexnetworks$`Sexual behaviour`[n] %in% rownames(countsex)) {
      iamr <- categorise_amr(dframe1$AMR.Gene.symbol[n])
      countsex[sexnetworks$`Sexual behaviour`[n],'Resistance count'] <-
        countsex[sexnetworks$`Sexual behaviour`[n],'Resistance count'] + 1.0
      for(m in 1:length(iamr)) {
        #print(paste(n,m,iamr[m]))
        countsex[sexnetworks$`Sexual behaviour`[n],iamr[m]] <-
          countsex[sexnetworks$`Sexual behaviour`[n],iamr[m]] + 1.0
      }
    }
  }
}
boxplot(countsex$`Resistance count`)
rownames(countsex)
for(n in 1:ncol(countsex)) {
  countsex[,n] <- as.numeric(0)
}
tcountsex <- as.data.frame(t(countsex))
MSM <- tcountsex$MSM[-1]
MSW <- tcountsex$MSW[-1]
MSMW <- tcountsex$MSMW[-1]
WSM <- tcountsex$WSM[-1]
TSM <- tcountsex$TSM[-1]
WSMW <- tcountsex$WSMW[-1]

MSM_norm <- rnorm(200,mean=mean(MSM, na.rm=TRUE), sd=sd(MSM, na.rm=TRUE))
MSW_norm <- rnorm(200,mean=mean(MSW, na.rm=TRUE), sd=sd(MSW, na.rm=TRUE))
MSMW_norm <- rnorm(200,mean=mean(MSMW, na.rm=TRUE), sd=sd(MSMW, na.rm=TRUE))
WSM_norm <- rnorm(200,mean=mean(WSM, na.rm=TRUE), sd=sd(WSM, na.rm=TRUE))
TSM_norm <- rnorm(200,mean=mean(TSM, na.rm=TRUE), sd=sd(TSM, na.rm=TRUE))
WSMW_norm <- rnorm(200,mean=mean(WSMW, na.rm=TRUE), sd=sd(WSMW, na.rm=TRUE))

boxplot(MSM,MSM_norm,MSW,MSW_norm,MSMW,MSMW_norm,WSM,WSM_norm,TSM,TSM_norm,
        WSMW,WSMW_norm, main = 'Multiple boxplots', at = c(1,2,3,4,5,6,8,9,10,11,12,13),
        names = c('MSM','normal','MSW','normal','MSMW','normal','WSM','normal',
                  'TSM','normal','WSMW','normal'), las = 2, horizontal = TRUE)

for(n in 1:nrow(dframe1)) {
  if(dframe1$id[n] %in% rownames(sexnetworks)) {
    iamr <- categorise_amr(dframe1$AMR.Gene.symbol[n])
    sexnetworks[dframe1$id[n],'Resistance count'] <- sexnetworks[dframe1$id[n],'Resistance count'] + 1
    for(m in 1:length(iamr)) {
      print(paste(n,m,iamr[m]))
      sexnetworks[dframe1$id[n],iamr[m]] <- sexnetworks[dframe1$id[n],iamr[m]] + 1
      print(paste(n,m,iamr[m]))
    }
  }
}

set.seed(8)
y <- rnorm(200)
group <- sample(LETTERS[1:3], size = 200,
                replace = TRUE)
df <- data.frame(y, group)
group

sexdfggmatrix <- matrix(ncol=2, nrow=0)
sexdfggplot <- data.frame(matrix(ncol=2, nrow=0))

sexdfgggroup <- c()
sexdfggcounts <- c()
sexdfggamr <- c()


tcountsexmtotal <- tcountsex[-1,]

for(n in 1:nrow(tcountsexmtotal)) {
  for(m in 1:ncol(tcountsexmtotal)) {
    sexdfgggroup <- c(sexdfgggroup,colnames(tcountsexmtotal[m]))
    sexdfggcounts <- c(sexdfggcounts,as.numeric(tcountsexmtotal[n,m]))
    sexdfggamr <- c(sexdfggamr,rownames(tcountsexmtotal)[n])
  }
  sexdfggmatrix <- matrix(c(sexdfggcounts,sexdfgggroup,sexdfggamr),ncol=3,nrow=(length(sexdfgggroup)))
  sexdfggplot <- data.frame(sexdfggmatrix)
  colnames(sexdfggplot) <- c('y','group','resistance')
}

for(n in 2:nrow(tcountsex)) {
  for(m in 1:ncol(tcountsex)) {
    sexdfgggroup <- c(sexdfgggroup,colnames(tcountsex[m]))
    sexdfggcounts <- c(sexdfggcounts,as.numeric(tcountsex[n,m]))
    sexdfggamr <- c(sexdfggamr,rownames(tcountsex)[-1][n])
  }
  sexdfggmatrix <- matrix(c(sexdfggcounts,sexdfgggroup,sexdfggamr),ncol=3,nrow=(length(sexdfgggroup)))
  sexdfggplot <- data.frame(sexdfggmatrix)
  colnames(sexdfggplot) <- c('y','group','resistance')
}
length(sexdfgggroup)
length(sexdfggcounts)
length(sexdfggamr)



ggplot(sexdfggplot, aes(x = sexdfgggroup, y = sexdfggcounts)) + 
  geom_boxplot(outlier.shape = NA) +
  ylab('Number of resistance class genes found') +
  xlab('Sex Networks') + labs(color='Resistance class') +
  ggtitle('Resistances identified by Sex Networks in Neisseria gonorrhoeae') +
  geom_jitter(aes(colour=sexdfggamr), show.legend = T) +
  coord_flip() 

sexdfggcountsnorm <- c()
for(n in 1:nrow(tcountsexmtotal)) {
  for(m in 1:ncol(tcountsexmtotal)) {
    if(tcountsex['Resistance count',m] == 0) {
      sexdfggcountsnorm <- c(sexdfggcountsnorm, 0)
      print('skipped')
      next
    }
    sexdfggcountsnorm <- c(sexdfggcountsnorm,(as.numeric(tcountsexmtotal[n,m]) / tcountsex['Resistance count',m]))
    print(length(sexdfggcountsnorm))
  }
  #sexdfggcountssnorm <- sexdfggcountsnorm[1:66]
  sexdfggmatrixnorm <- matrix(c(sexdfggcountsnorm,sexdfgggroup,sexdfggamr),ncol=3,nrow=(length(sexdfgggroup)))
  sexdfggplotnorm <- data.frame(sexdfggmatrixnorm)
  colnames(sexdfggplotnorm) <- c('y','group','resistance')
}
length(sexdfggcounts)
sexdfggcountsnorm <- sexdfggcountsnorm[1:66]
length(sexdfggcountsnorm)
ggplot(sexdfggplot, aes(x = sexdfgggroup, y = sexdfggcountsnorm)) + 
  geom_boxplot(outlier.shape = NA) +
  ylab('Percentage of resistance class genes found') +
  xlab('Sex Networks') + labs(color='Resistance class') +
  ggtitle('Resistances identified by Sex Networks in Neisseria gonorrhoeae') +
  geom_jitter(aes(colour=sexdfggamr), show.legend = T) +
  coord_flip() 

ggplot(tcountsex, aes(x = rownames(tcountsex), y = MSM)) + 
  geom_boxplot() +
  geom_jitter() +
  coord_flip()


unique(sexnetworks$`Sexual behaviour`)
unique(metadatamaster$Sexual.behaviour)

rowsvector <- c()
for(n in 1:nrow(metadatamaster)) {
  if(metadatamaster$Sexual.behaviour[n] == 'Homosexual') {
    rowsvector <- c(rowsvector, metadatamaster$displayname[n])
  }
}
write.table(rowsvector, file=pipe('pbcopy'), sep='\t')

# resistance counts sex networks ####
# create horizontal bar graph of resistances normalised and grouped by sex networks

soft_categorise_amr <- function(amr_str_list) {
  returnlist <- c()
  templist <- c()
  if(amr_str_list == '') {
    return('')
    break
  }
  templist <- unlist(strsplit(amr_str_list,','))
  for(n in 1:length(templist)) {
    amr <- templist[n]
    if(length(amr) == 0 ) {
      next
    }
    if(startsWith(amr,'penA')) {
      returnlist <- c(returnlist,'penA variant')
    } else if(startsWith(amr,'blaTEM')) {
      returnlist <- c(returnlist,'blaTEM variant')
    } else {
      returnlist <- c(returnlist,amr)
    }
    returnlist <- unique(returnlist)
  }
  return(returnlist)
}

# create vectors to use to create matrix

unique(metadatamaster$Sexual.behaviour)
# count sexual behaviour categories in sexual behaviour
behlist <- unique(metadatamaster$Sexual.behaviour)
countbeh <- rep(as.integer(0),(length(behlist))) 
for(n in 1:nrow(metadatamaster)) {
  for(m in 1:length(behlist)) {
    if((metadatamaster$Sexual.behaviour[n]) == (behlist[m])) {
      countbeh[m] <- countbeh[m] + 1
    }
  }
}
for(l in 1:length(behlist)) {
  print(paste(behlist[l],countbeh[l],sep=', '))
}
# categorise sexual behaviour
categorise_behaviour <- function(n) {
  behcatlist <- c('MSM','MSMW','MSW','TSM','WSM','WSMW')
  returncat <- ''
  if(!(metadatamaster$Sexual.behaviour[n] == '')) {
    if(metadatamaster$Sexual.behaviour[n] %in% behcatlist) {
      returncat <- metadatamaster$Sexual.behaviour[n]
    } else if(metadatamaster$Sexual.behaviour[n] == 'Bisexual MSM') {
      returncat <- 'MSMW'
    } else if(metadatamaster$Sexual.behaviour[n] == 'WSM-E') {
      returncat <- 'WSM'
    } else if(metadatamaster$Sexual.behaviour[n] == 'Heterosexual men') {
      returncat <- 'WSM'
    } else if(!(metadatamaster$Host.sex[n] == '')) {
      if(metadatamaster$Sexual.behaviour[n] == 'Heterosexual') {
        if(metadatamaster$Host.sex[n] == 'male') {
          returncat <- 'MSW'
        } else if(metadatamaster$Host.sex[n] == 'female') {
          returncat <- 'WSM'
        }
      } else if(metadatamaster$Sexual.behaviour[n] == 'Women') {
        if(metadatamaster$Host.sex[n] == 'female') {
          returncat <- 'WSW'
        } else if(metadatamaster$Host.sex[n] == 'male') {
          returncat <- 'MSW'
        }
      } else if((metadatamaster$Sexual.behaviour[n] == 'Bisexual') |
                (metadatamaster$Sexual.behaviour[n] == 'Bi-sexual')) {
        if(metadatamaster$Host.sex[n] == 'female') {
          returncat <- 'WSMW'
        } else if(metadatamaster$Host.sex[n] == 'male' ) {
          returncat <- 'MSMW'
        }
      }
    }
  }
  return(returncat)
}
catbehlist <- c()
for(n in 1:nrow(metadatamaster)) {
  catbehlist <- c(catbehlist,categorise_behaviour(n))
}
# count categorised list
catbehlist <- unique(catbehlist)
catbehlist <- catbehlist[-1]
countcatbehlist <- rep(as.integer(0),(length(catbehlist))) 
for(n in 1:nrow(metadatamaster)) {
  for(m in 1:length(catbehlist)) {
    print(categorise_behaviour(n))
    if(!(categorise_behaviour(n) == '')) {
      if(((categorise_behaviour(n)) == (catbehlist[m]))) {
        countcatbehlist[m] <- countcatbehlist[m] + 1
      }
    }
  }
}

for(l in 1:length(catbehlist)) {
  print(paste(catbehlist[l],countcatbehlist[l],sep=', '))
}
countcatbehlist
dfcountcatbehlist <- data.frame(countcatbehlist)
rownames(dfcountcatbehlist) <- catbehlist
dfcountcatbehlist

# get list of all soft categorised amrs
softcatamrall <- c()
for(n in 1:nrow(metadatamaster)) {
  amrlist <- soft_categorise_amr(dframe1$AMR.Gene.symbol[n])
  if(length(amrlist) == 0) {
    next
  }
  for(m in 1:length(amrlist)) {
    if(amrlist[m] == '') {
      next
    }
    softcatamrall <- c(softcatamrall,amrlist[m])
    softcatamrall <- unique(softcatamrall)
  }
}

# now create base vectors to work from
# data frame should look like
# sexual behaviour | amr gene count | amr gene 2 count | amr gene n count

countmatrix <- matrix(0,nrow=length(catbehlist),ncol=length(softcatamrall))
colnames(countmatrix) <- softcatamrall
rownames(countmatrix) <- catbehlist
for(n in 1:nrow(metadatamaster)) {
  amrlist <- soft_categorise_amr(dframe1$AMR.Gene.symbol[n])
  beh <- categorise_behaviour(n)
  if(beh %in% catbehlist) {
    for(m in 1:length(amrlist)) {
      if(amrlist[m] %in% softcatamrall) {
        countmatrix[beh,amrlist[m]] <- countmatrix[beh,amrlist[m]] + 1
      }
    }
  }
}

# create ggplot vectors
countsnorm <- c()
countsbeh <- c()
countsamr <- c()
counts <- c()
for(r in 1:nrow(countmatrix)) {
  for(c in 1:ncol(countmatrix)) {
    countsnorm <- c(countsnorm, countmatrix[r,c] / sum(countmatrix[r,]))
    counts <- c(counts,countmatrix[r,c])
    countsbeh <- c(countsbeh,rownames(countmatrix)[r])
    countsamr <- c(countsamr,colnames(countmatrix)[c])
  }
  countsdfnorm <- data.frame(countsnorm,countsbeh,countsamr)
  colnames(sexdfggplotnorm) <- c('counts','behaviour','amrgene')
}
for(r in 1:nrow(countmatrix)) {
  print(sum(countmatrix[r,]))
}

library(ggplot2)
ggplot(countsdfnorm,aes(fill=countsamr, y=countsnorm, x=countsbeh)) + 
  geom_bar(position='stack', stat='identity') +
  ggtitle('Relative frequency of AMR gene by Sexual Orientation') +
  xlab('Sexual Behaviour') + ylab('AMR gene frequency') +
  labs(color='Gene') + coord_flip() + theme_minimal() + 
  scale_y_continuous(labels = scales::percent) + theme(legend.position = 'None')

# now redo box plot with accurate data
# two versions - one with amr genes, one with resistance category
dfboxplot <- data.frame(counts,countsbeh,countsamr)
# sexbyresistanceold 
ggplot(dfboxplot, aes(x = countsbeh, y = counts)) + 
  geom_boxplot(outlier.shape = NA) +
  ylab('Number of resistance class genes found') +
  xlab('Sex Networks') + labs(color='AMR gene') +
  ggtitle('Resistances identified by Sex Networks in Neisseria gonorrhoeae') +
  geom_jitter(aes(colour=countsamr), show.legend = T) +
  coord_flip() + theme_minimal()

# now with category
catamrall <- c()
for(n in 1:nrow(metadatamaster)) {
  amrlist <- categorise_amr(dframe1$AMR.Gene.symbol[n])
  if(length(amrlist) == 0) {
    next
  }
  for(m in 1:length(amrlist)) {
    if(amrlist[m] == '') {
      next
    }
    catamrall <- c(catamrall,amrlist[m])
    catamrall <- unique(catamrall)
  }
}
catcountmatrix <- matrix(0,nrow=length(catbehlist),ncol=length(catamrall))
colnames(catcountmatrix) <- catamrall
rownames(catcountmatrix) <- catbehlist
for(n in 1:nrow(metadatamaster)) {
  amrlist <- categorise_amr(dframe1$AMR.Gene.symbol[n])
  beh <- categorise_behaviour(n)
  if(beh %in% catbehlist) {
    if(length(amrlist) == 0 ) {
      next
    }
    for(m in 1:length(amrlist)) {
      print(amrlist)
      if(amrlist[m] %in% catamrall) {
        print(amrlist[m])
        catcountmatrix[beh,amrlist[m]] <- catcountmatrix[beh,amrlist[m]] + 1
      }
    }
  }
}
catcountsnorm <- c()
catcountsbeh <- c()
catcountsamr <- c()
catcounts <- c()
for(r in 1:nrow(catcountmatrix)) {
  for(c in 1:ncol(catcountmatrix)) {
    catcountsnorm <- c(catcountsnorm, catcountmatrix[r,c] / sum(catcountmatrix[r,]))
    catcounts <- c(catcounts,catcountmatrix[r,c])
    catcountsbeh <- c(catcountsbeh,rownames(catcountmatrix)[r])
    catcountsamr <- c(catcountsamr,colnames(catcountmatrix)[c])
  }
  catcountsdf <- data.frame(catcounts,catcountsbeh,catcountsamr)
  colnames(catcountsdf) <- c('counts','behaviour','amrgene')
}
# sexbyoldclass
ggplot(catcountsdf, aes(x = catcountsbeh, y = catcounts)) + 
  geom_boxplot(outlier.shape = NA) +
  ylab('Number of resistance class resistances found') +
  xlab('Sex Networks') + labs(color='AMR category') +
  ggtitle('Resistances identified by Sex Networks in Neisseria gonorrhoeae') +
  geom_jitter(aes(colour=catcountsamr), show.legend = T) +
  coord_flip() + theme_minimal() 

# heatmaps! ####
library(maps)
library(ggplot)
world_map <- map_data("world")
world_map <- subset(world_map, region != "Antarctica")
# create data frame for this dealy

# create list of countries
dframe1$Country[dframe1$Country == 'HongKong'] <- 'Hong Kong'
dframe1$Country[dframe1$Country == 'Viet Nam'] <- 'Vietnam'
countrylist <- c()
for(r in 1:nrow(dframe1)) {
  if(!(dframe1$Country[r] == '')) {
    countrylist <- c(countrylist,dframe1$Country[r])
    countrylist <- unique(countrylist)
  }
}
# reuse list of soft categorised amr genes (softcatamrall)
{heatmap_matrix <- matrix(0,nrow=length(countrylist),ncol=length(softcatamrall))
colnames(heatmap_matrix) <- softcatamrall
rownames(heatmap_matrix) <- countrylist

heatmap_case_by_country <- matrix(0,nrow=length(countrylist),ncol=1)
colnames(heatmap_case_by_country) <- c('Total cases')
rownames(heatmap_case_by_country) <- countrylist

# populate heatmap matrix
for(r in 1:nrow(dframe1)) {
  if(!(dframe1$Country[r] == '')) {
    heatmap_case_by_country[dframe1$Country[r],1] <-
      heatmap_case_by_country[dframe1$Country[r],1] + 1
    if(!(dframe1$AMR.Gene.symbol[r] == '')) {
      amrlist <- dframe1$AMR.Gene.symbol[r]
      for(n in 1:length(amrlist)) {
        amr <- soft_categorise_amr(amrlist[n])
        if(length(amr) == 0 ) {
          next
        }
        heatmap_matrix[dframe1$Country[r],amr] <-
          heatmap_matrix[dframe1$Country[r],amr] + 1
      }
    }
  }
  dfheatmap <- (heatmap_matrix)
  dfheatmapnorm <- dfheatmap
  for(l in 1:nrow(dfheatmap)) {
    dfheatmapnorm[l,] <- dfheatmapnorm[l,] / heatmap_case_by_country[l,1]
  }
}
}

# create vectors for ggplot (for penA variants)
# id | country | value
ggheatmap <- data.frame(c(rownames(dfheatmapnorm)), dfheatmapnorm[,1])
colnames(ggheatmap) <- c('Country', 'Cases')

ggplot(ggheatmap) + geom_map(dat = world_map, map = world_map, 
                             aes(map_id = region), fill = "white", 
                             color = "#7f7f7f", size = 0.25) +
  ggtitle("Percentage of N.g. isolates with penA variant genes") +
  geom_map(map = world_map, aes(map_id = ggheatmap$Country, fill = ggheatmap$Cases), size = 0.25) +
  scale_fill_gradient(low = "#fff7bc", high = "#cc4c02", name = "Percentage") +
  expand_limits(x = world_map$long, y = world_map$lat)

# stacked bar charts of amr and cas prevalence by country ####
# need list of all countries and all amrs and all cas genes
# countrylist, softcatamrall, main_cas_list()
caslistall <- main_cas_list(dframe1$Genes)
caslist

# because vectors are going to be different sizes, need to create paired 
# vectors of country + amr and country + cas
# but can create in same loop
{
  caslistall <- main_cas_list(dframe1$Genes)
  countryamr <- matrix(0,nrow=length(countrylist),ncol=length(softcatamrall))
  colnames(countryamr) <- softcatamrall
  rownames(countryamr) <- countrylist
  countrycas <- matrix(0,nrow=length(countrylist),ncol=length(caslistall))
  colnames(countrycas) <- caslistall
  rownames(countrycas) <- countrylist
  
  for(r in 1:nrow(dframe1)) {
    if(!(dframe1$Country[r] == '')) {
      if(!(dframe1$Genes[r] == '')) {
        caslist <- categorise_cas(dframe1$Genes[r])
        for(n in 1:length(caslist)) {
          cas <- caslist[n]
          if(cas %in% caslistall){
            countrycas[dframe1$Country[r],cas] <- 
              countrycas[dframe1$Country[r],cas] + 1
          }
        }
      }
      if(!(dframe1$AMR.Gene.symbol[r] == '')) {
        amrlist <- soft_categorise_amr(dframe1$AMR.Gene.symbol[r])
        for(m in 1:length(amrlist)) {
          amr <- amrlist[m]
          if(amr %in% softcatamrall) {
            countryamr[dframe1$Country[r],amr] <-
              countryamr[dframe1$Country[r],amr] + 1
          }
        }
      }
    }
  }
  # create normed vectors for ggplot
  countryamrnorm <- c()
  countryamramr <- c()
  countryamrcountry <- c()
  for(r in 1:nrow(countryamr)) {
    for(c in 1:ncol(countryamr)) {
      countryamrnorm <- c(countryamrnorm,(countryamr[r,c] / sum(countryamr[r,])))
      countryamramr <- c(countryamramr, colnames(countryamr)[c])
      countryamrcountry <- c(countryamrcountry, rownames(countryamr)[r])
    }
  }
  countrycasnorm <- c()
  countrycascas <- c()
  countrycascountry <- c()
  for(r in 1:nrow(countrycas)) {
    for(c in 1:ncol(countrycas)) {
      countrycasnorm <- c(countrycasnorm,(countrycas[r,c] / sum(countrycas[r,])))
      countrycascas <- c(countrycascas, colnames(countrycas)[c])
      countrycascountry <- c(countrycascountry, rownames(countrycas)[r])
    }
  }
  print(length(countrycasnorm))
  print(length(countrycascas))
  print(length(countrycascountry))
  dfcountrycas <- data.frame(countrycasnorm,countrycascas,countrycascountry)
  dfcountryamr <- data.frame(countryamrnorm,countryamramr,countryamrcountry)
}

ggplot(dfcountrycas,aes(fill=countrycascas, y=countrycasnorm, x=countrycascountry)) + 
  geom_bar(position='stack', stat='identity') +
  ggtitle('Relative frequency of Cas genes found by Country') +
  xlab('Country') + ylab('Cas Gene Frequency') +
  labs(color='Gene') + coord_flip() + theme_minimal() + 
  scale_y_continuous(labels = scales::percent)

ggplot(dfcountryamr,aes(fill=countryamramr, y=countryamrnorm, x=countryamrcountry)) + 
  geom_bar(position='stack', stat='identity') +
  ggtitle('Relative frequency of Resistance genes found by Country') +
  xlab('Country') + ylab('Resistance Gene Frequency') +
  labs(color='Gene') + coord_flip() + theme_minimal() + 
  scale_y_continuous(labels = scales::percent) + theme(legend.position = "none")

# new mechanism classes ####
# accepts a string of comma separated amr values (with no spaces)
mechanism_class <- function(amrlist) {
  mechanismclasslist <- c()
  if(!(amrlist == '' )) {
    amrlist <- unlist(strsplit(amrlist,','))
    for(m in 1:length(amrlist)) {
      amr <- amrlist[m]
      if(startsWith(amr,'penA')) {
        mechanismclasslist <- c(mechanismclasslist,'penA variant')
      }else if(startsWith(amr,'bla')) {
        mechanismclasslist <- c(mechanismclasslist,'bla variant')
      }else if(startsWith(amr,'par')) {
        mechanismclasslist <- c(mechanismclasslist,'parC/E variant')
      }else if(startsWith(amr,'por')) {
        mechanismclasslist <- c(mechanismclasslist,'Porins')
      }else if(startsWith(amr,'gyr')) {
        mechanismclasslist <- c(mechanismclasslist,'gyrA/B variant')
      }else if(startsWith(amr,'mtr')) {
        mechanismclasslist <- c(mechanismclasslist,'mtr variant')
      }else if(startsWith(amr,'rpoB')) {
        mechanismclasslist <- c(mechanismclasslist,'rpoB variant')
      }else if(startsWith(amr, 'rpsJ')) {
        mechanismclasslist <- c(mechanismclasslist,'rpsJ')
      }else if(startsWith(amr,'rpsE')) {
        mechanismclasslist <- c(mechanismclasslist,'rpsE')
      }else if(startsWith(amr,'rpoD')) {
        mechanismclasslist <- c(mechanismclasslist,'rpoD variant')
      }else if(startsWith(amr,'tet')) {
        mechanismclasslist <- c(mechanismclasslist,'tet variant')
      }else if(startsWith(amr,'msr')) {
        mechanismclasslist <- c(mechanismclasslist,'msr(E)')
      }else if(startsWith(amr,'aph')) {
        mechanismclasslist <- c(mechanismclasslist,'aph variant')
      }else if(startsWith(amr,'erm')) {
        mechanismclasslist <- c(mechanismclasslist,'erm variant')
      }else if(startsWith(amr,'rpl')) {
        mechanismclasslist <- c(mechanismclasslist,'rplD/V variant')
      }else if(startsWith(amr,'mph')) {
        mechanismclasslist <- c(mechanismclasslist,'mph(E)')
      }else if(startsWith(amr,'fosB')) {
        mechanismclasslist <- c(mechanismclasslist,'fosB')
      }else if(startsWith(amr,'sul2')) {
        mechanismclasslist <- c(mechanismclasslist,'sul2')
      }else if(startsWith(amr,'fosB')) {
        mechanismclasslist <- c(mechanismclasslist,'fosB')
      }else if(startsWith(amr,'dfr')) {
        mechanismclasslist <- c(mechanismclasslist,'dfrA14')
      }else if(startsWith(amr,'23S')) {
        mechanismclasslist <- c(mechanismclasslist,'23S_A2045G')
      }else if(startsWith(amr,'fosB')) {
        mechanismclasslist <- c(mechanismclasslist,'fosB')
      }else if(startsWith(amr,'folP')) {
        mechanismclasslist <- c(mechanismclasslist,'folP')
      }else if(startsWith(amr,'catA')) {
        mechanismclasslist <- c(mechanismclasslist,'catA')
      }else if(startsWith(amr,'qacC')) {
        mechanismclasslist <- c(mechanismclasslist,'qacC')
      }else if(startsWith(amr,'norM')) {
        mechanismclasslist <- c(mechanismclasslist,'norM')
      }else if((startsWith(amr,'ponA')) | (startsWith(amr,'pbp2'))) {
        mechanismclasslist <- c(mechanismclasslist,'PBP variant')
      }
    }
  }
  return(unique(mechanismclasslist))
}
# accepts a vector of strings of comma separated amr values (with no spaces)
mechanism_class_all <- function(amrlistlist) {
  mechclasslistall <- c()
  for(n in 1:length(amrlistlist)) {
    mechclasslistall <- unique(c(mechclasslistall, mechanism_class(amrlistlist[n])))
  }
  return(mechclasslistall)
}
mechanism_class_count <- function(amrlistlist,mechclasslistall) {
  dfcount <- data.frame(matrix(0,nrow=(length(mechclasslistall)),ncol=1))
  colnames(dfcount) <- c('Count')
  rownames(dfcount) <- mechclasslistall
  for(n in 1:length(amrlistlist)) {
    amrlist <- mechanism_class(amrlistlist[n])
    for(m in 1:length(amrlist)) {
      amr <- amrlist[m]
      dfcount[amr,'Count'] <- dfcount[amr,'Count'] + 1
    }
  }
  return(dfcount)
}
mechclasslist <- mechanism_class_all(dframe1$AMR.Gene.symbol)
mechclasslist
dfcount <- mechanism_class_count(dframe1$AMR.Gene.symbol,mechclasslist)

countrylist
# Sort countries into continents
categorise_continent <- function(country){
  returncontinent <- switch(country, 'Australia' = 'Oceania', 'New Zealand' = 'Oceania', 
                'Netherlands' = 'Europe', 'Estonia' = 'Europe', 'Latvia' = 'Europe', 
                'Switzerland' = 'Europe', 'Scotland' = 'Europe', 'Norway' = 'Europe',
                'Hungary' = 'Europe', 'Denmark' = 'Europe', 'Spain' = 'Europe', 
                'Belgium' = 'Europe', 'Malta' = 'Europe', 'Romania' = 'Europe',
                'Lithuania' = 'Europe', 'Poland' = 'Europe', 'Portugal' = 'Europe',
                'Czechia' = 'Europe', 'Cyprus' = 'Europe', 'Finland' = 'Europe',
                'Croatia' = 'Europe', 'Ukraine' = 'Europe', 'Turkey' = 'Asia',
                'Saudi Arabia' = 'Asia', 'Austria' = 'Europe', 'Slovakia' = 'Europe',
                'Germany' = 'Europe', 'Ireland' = 'Europe', 'Belarus' = 'Europe',
                'Russia' = 'Europe', 'Bulgaria' = 'Europe', 'Sweden' = 'Europe',
                'Italy' = 'Europe', 'Slovenia' = 'Europe', 'France' = 'Europe',
                'Greece' = 'Europe', 'Iceland' = 'Europe', 'Brazil' = 'AMR',
                'Japan' = 'Asia', 'China' = 'Asia', 'Guinea-Bissau' = 'Africa', 
                'India' = 'Asia', 'Chile' = 'AMR', 'Tanzania' = 'Africa',
                'Armenia' = 'Asia', 'Ecuador' = 'AMR', 'Vietnam' = 'Asia',
                'Philippines' = 'Asia', 'Korea' = 'Asia', 'Pakistan' = 'Asia', 
                'Gambia' = 'Africa', 'Caribbean' = 'North America', 'USA' = 'North America',
                'UK' = 'Europe', 'Suriname' = 'Africa', 'Angola' = 'Africa',
                'South Africa' = 'Africa', 'Argentina' = 'AMR', 'Thailand' = 'Asia',
                'Singapore' = 'Asia', 'Canada' = 'North America', 'Brazil' = 'AMR',
                'Guinea' = 'Africa', 'Kenya' = 'Africa', 'Hong Kong' = 'Asia', 'Bhutan' = 'Asia',
                'Ivory Coast' = 'Africa', 'Malaysia' = 'Asia', 'Indonesia' = 'Asia',
                'Morocco' = 'Africa', 'Uganda' = 'Africa')
  if(is.null(returncontinent) == TRUE) {
    return('')
  }else {
    return(returncontinent)
  }

}
categorise_who_region <- function(country){
  returncontinent <- switch(country, 'Australia' = 'WPR', 'New Zealand' = 'WPR', 
                            'Netherlands' = 'EUR', 'Estonia' = 'EUR', 'Latvia' = 'EUR', 
                            'Switzerland' = 'EUR', 'Scotland' = 'EUR', 'Norway' = 'EUR',
                            'Hungary' = 'EUR', 'Denmark' = 'EUR', 'Spain' = 'EUR', 
                            'Belgium' = 'EUR', 'Malta' = 'EUR', 'Romania' = 'EUR',
                            'Lithuania' = 'EUR', 'Poland' = 'EUR', 'Portugal' = 'EUR',
                            'Czechia' = 'EUR', 'Cyprus' = 'EUR', 'Finland' = 'EUR',
                            'Croatia' = 'EUR', 'Ukraine' = 'EUR', 'Turkey' = 'EUR',
                            'Saudi Arabia' = 'EMR', 'Austria' = 'EUR', 'Slovakia' = 'EUR',
                            'Germany' = 'EUR', 'Ireland' = 'EUR', 'Belarus' = 'EUR',
                            'Russia' = 'EUR', 'Bulgaria' = 'EUR', 'Sweden' = 'EUR',
                            'Italy' = 'EUR', 'Slovenia' = 'EUR', 'France' = 'EUR',
                            'Greece' = 'EUR', 'Iceland' = 'EUR', 'Brazil' = 'AMR',
                            'Japan' = 'WPR', 'China' = 'WPR', 'Guinea-Bissau' = 'AFR', 
                            'India' = 'SEAR', 'Chile' = 'AMR', 'Tanzania' = 'AFR',
                            'Armenia' = 'EUR', 'Ecuador' = 'AMR', 'Vietnam' = 'WPR',
                            'Philippines' = 'WPR', 'Korea' = 'WPR', 'Pakistan' = 'EMR', 
                            'Gambia' = 'AFR', 'Caribbean' = 'AMR', 'USA' = 'AMR',
                            'UK' = 'EUR', 'Suriname' = 'AMR', 'Angola' = 'AFR',
                            'South Africa' = 'AFR', 'Argentina' = 'AMR', 'Thailand' = 'SEAR',
                            'Singapore' = 'WPR', 'Canada' = 'AMR', 'Brazil' = 'AMR',
                            'Guinea' = 'AFR', 'Kenya' = 'AFR', 'Hong Kong' = 'WPR', 'Bhutan' = 'SEAR',
                            'Ivory Coast' = 'AFR', 'Malaysia' = 'WPR', 'Indonesia' = 'SEAR',
                            'Morocco' = 'EMR', 'Uganda' = 'AFR')
}
  if(is.null(returncontinent) == TRUE) {
    return('')
  }else {
    return(returncontinent)
  }
# redo country x resistance genes with continental groups so data is easier to read
# to do, will have to modify vectors and df
# as well as remake and repopulate them

continent <- c()
for(n in 1:length(countryamrcountry)) {
  continent <- c(continent, categorise_continent(countryamrcountry[n]))
}
newcontinent <- c()
for(n in 1:length(countryamrcountry)) {
  newcontinent <- c(newcontinent, categorise_who_region(countryamrcountry[n]))
}

dfcontinentamr <- data.frame(countryamrnorm,countryamramr,countryamrcountry,continent)

{
  caslistall <- main_cas_list(dframe1$Genes)
  countryamr <- matrix(0,nrow=length(countrylist),ncol=length(mechclasslist))
  colnames(countryamr) <- mechclasslist
  rownames(countryamr) <- countrylist
  countrycas <- matrix(0,nrow=length(countrylist),ncol=length(caslistall))
  colnames(countrycas) <- caslistall
  rownames(countrycas) <- countrylist
  
  for(r in 1:nrow(dframe1)) {
    if(!(dframe1$Country[r] == '')) {
      if(!(dframe1$Genes[r] == '')) {
        caslist <- categorise_cas(dframe1$Genes[r])
        for(n in 1:length(caslist)) {
          cas <- caslist[n]
          if(cas %in% caslistall){
            countrycas[dframe1$Country[r],cas] <- 
              countrycas[dframe1$Country[r],cas] + 1
          }
        }
      }
      if(!(dframe1$AMR.Gene.symbol[r] == '')) {
        amrlist <- mechanism_class(dframe1$AMR.Gene.symbol[r])
        for(m in 1:length(amrlist)) {
          amr <- amrlist[m]
          if(amr %in% mechclasslist) {
            countryamr[dframe1$Country[r],amr] <-
              countryamr[dframe1$Country[r],amr] + 1
          }
        }
      }
    }
  }
  # create normed vectors for ggplot
  countryamrnorm <- c()
  countryamramr <- c()
  countryamrcountry <- c()
  for(r in 1:nrow(countryamr)) {
    for(c in 1:ncol(countryamr)) {
      countryamrnorm <- c(countryamrnorm,(countryamr[r,c] / sum(countryamr[r,])))
      countryamramr <- c(countryamramr, colnames(countryamr)[c])
      countryamrcountry <- c(countryamrcountry, rownames(countryamr)[r])
    }
  }
  countrycasnorm <- c()
  countrycascas <- c()
  countrycascountry <- c()
  for(r in 1:nrow(countrycas)) {
    for(c in 1:ncol(countrycas)) {
      countrycasnorm <- c(countrycasnorm,(countrycas[r,c] / sum(countrycas[r,])))
      countrycascas <- c(countrycascas, colnames(countrycas)[c])
      countrycascountry <- c(countrycascountry, rownames(countrycas)[r])
    }
  }
  print(length(countrycasnorm))
  print(length(countrycascas))
  print(length(countrycascountry))
  dfcountrycas <- data.frame(countrycasnorm,countrycascas,countrycascountry)
  dfcountryamr <- data.frame(countryamrnorm,countryamramr,countryamrcountry)
}
## auto generate plots for each continent
# make continent list
allcontinents <- c()
for(r in 1:nrow(dframe1)) {
  if(categorise_continent(dframe1$Country[r]) == '' ) {next}
  allcontinents <- unique(c(allcontinents,categorise_continent(dframe1$Country[r])))
}
{
  filename <- ''
  tempcountryamr <- c()
  tempcountryamrnorm <- c()
  tempcountryamrcountry <- c()
  tempdataframe <- data.frame()
for(n in 1:length(allcontinents)) {
  filename <- paste0(allcontinents[n],'countryxamr.svg', sep = '_')
  #svg(filename=paste0('~','pracs','countryamr',filename, sep = '/'), width=1080)
    tempcountryamr <- dfcontinentamr$countryamramr[dfcontinentamr$continent == allcontinents[n]]
    tempcountryamrnorm <- dfcontinentamr$countryamrnorm[dfcontinentamr$continent == allcontinents[n]]
    tempcountryamrcountry <- dfcontinentamr$countryamrcountry[dfcontinentamr$continent == allcontinents[n]]
    tempdataframe <- data.frame(tempcountryamrnorm,tempcountryamr,tempcountryamrcountry)
    print(ggplot(tempdataframe,aes(fill=tempcountryamr, y=tempcountryamrnorm, x=tempcountryamrcountry)) + 
      geom_bar(position='stack', stat='identity',position_dodge2(width = 0.9, preserve = "single")) +
      #ggtitle('Relative frequency of Resistance genes found by Country') +
      xlab('Country') + ylab('Resistance Gene Frequency') +
      labs(color='Gene') + coord_flip() + theme_minimal() + 
      scale_y_continuous(labels = scales::percent) + theme(legend.position = "none"))
    #dev.off()
}
}
  
ggplot(dfcontinentamr,aes(fill=countryamramr, y=countryamrnorm, x=countryamrcountry)) + 
  geom_bar(position='stack', stat='identity') +
  ggtitle('Relative frequency of Resistance genes found by Country') +
  xlab('Country') + ylab('Resistance Gene Frequency') +
  labs(color='Gene') + coord_flip() + theme_minimal() + 
  scale_y_continuous(labels = scales::percent) + theme(legend.position = "none")


dframe1$Country[dframe1$Country == 'The Netherlands'] <- 'Netherlands'
dframe1$Country[dframe1$Country == 'United Kingdom'] <- 'UK'
dframe1$Country[dframe1$Country == 'Cabo Verde'] <- 'Brazil'
dframe1$Country[dframe1$Country == 'Brasil'] <- 'Brazil'
dfcontinentamr$continent[dfcontinentamr$continent == 'Oceania']

newdfcontinentamr <- data.frame(countryamrnorm,countryamramr,countryamrcountry,newcontinent)


testplot <- ggplot(newdfcontinentamr,aes(colour = countryamramr, fill = countryamramr, y = countryamrnorm,
               x = countryamrcountry)) + 
  geom_bar(position="stack", stat="identity",  width=.7) +
  theme_classic() + xlab('Country') + ylab('Resistance Gene Frequency') +
  theme(legend.position = 'None')  + labs(color='Gene') +
  facet_grid(.~newcontinent,scales = 'free',space = 'free',drop = F) + 
  scale_y_continuous(labels = scales::percent) + guides(x =  guide_axis(angle = 45))

## Function to extract legend
g_legend <- function(a.gplot){ 
  tmp <- ggplot_gtable(ggplot_build(a.gplot)) 
  leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box") 
  legend <- tmp$grobs[[leg]] 
  legend
} 

legend <- g_legend(geobycas) 
library(grid)
grid.newpage()
grid.draw(legend) 
testplot
sexbyresistanceold

# geography by cas plot
cascontinent <- c()
for(n in 1:length(countrycascountry)) {
  cascontinent <- c(cascontinent, categorise_who_region(countrycascountry[n]))
}
dfgeobycas <- data.frame(countrycasnorm,countrycascas,countrycascountry,cascontinent)
geobycas <- ggplot(dfgeobycas,aes(colour = countrycascas, fill = countrycascas, y = countrycasnorm,
                                         x = countrycascountry)) + 
  geom_bar(position="stack", stat="identity",  width=.7) +
  theme_classic() + xlab('Country') + ylab('Resistance Gene Frequency') +
   labs(color='Gene') +
  facet_grid(.~cascontinent,scales = 'free',space = 'free',drop = F) + 
  scale_y_continuous(labels = scales::percent) + guides(x =  guide_axis(angle = 90))
geobycas

# sex networks by new amr cat
# list all new amr cats - mechclasslist
# list all sex networks - catbehlist
# make matrix
sexbyamrmatrix <- matrix(0,nrow=length(catbehlist),ncol=length(mechclasslist))
rownames(sexbyamrmatrix) <- catbehlist
colnames(sexbyamrmatrix) <- mechclasslist
for(r in 1:nrow(countmatrix)) {
  for(c in 1:ncol(countmatrix)) {
    sexbyamrmatrix[rownames(countmatrix)[r],mechanism_class(colnames(countmatrix)[c])] <-
      sexbyamrmatrix[rownames(countmatrix)[r],mechanism_class(colnames(countmatrix)[c])] +
      countmatrix[r,c]
  }
}

sexbyamrcount <- c()
sexbyamramr <- c()
sexbyamrbeh <- c()
for(r in 1:nrow(sexbyamrmatrix)) {
  for(c in 1:ncol(sexbyamrmatrix)) {
    sexbyamrcount <- c(sexbyamrcount,sexbyamrmatrix[r,c])
    sexbyamrbeh <- c(sexbyamrbeh,rownames(sexbyamrmatrix)[r])
    sexbyamramr <- c(sexbyamramr,colnames(sexbyamrmatrix)[c])
  }
}
colnames(sexbyamrmatrix)
dfsexbyamr <- data.frame(sexbyamrcount,sexbyamramr,sexbyamrbeh)

ggplot(dfsexbyamr, aes(x = sexbyamrbeh, y = sexbyamrcount)) + 
  geom_boxplot(outlier.shape = NA) +
  ylab('Number of resistance class genes found') +
  xlab('Sex Networks') + labs(color='AMR gene') +
  ggtitle('Resistances identified by Sex Networks in Neisseria gonorrhoeae') +
  geom_jitter(aes(colour=sexbyamramr), show.legend = F) +
  coord_flip() + theme_minimal()

# now do sex by cas gene boxplot
# get list of cas genes - caslistall
# get list of behaviours - catbehlist
sexbycasmatrix <- matrix(0,nrow=length(catbehlist),ncol=length(caslistall))
rownames(sexbycasmatrix) <- catbehlist
colnames(sexbycasmatrix) <- caslistall

# make an easier single structure
Genes <- c()
Sexual.behaviour <- c()
AMR.Gene.symbol <- c()
for(m in 1:nrow(metadatamaster)) {
  for(d in 1:nrow(dframe1)) {
    if(metadatamaster$displayname[m] == dframe1$id[d]) {
      Genes <- c(Genes,metadatamaster$dframe1$Genes[d])
      Sexual.behaviour <- c(Sexual.behaviour,metadatamaster$Sexual.behaviour)
      AMR.Gene.symbol <- c(AMR.Gene.symbol,dframe1$AMR.Gene.symbol)
      print(paste(m,d))
    }
  }
}

dframesex1 <- data.frame(dframe1$id[-12115],dframe1$Country[-12115],dframe1$Genes[-12115],dframe1$AMR.Gene.symbol[-12115],
rep('',35311),rep('',35311))
rownames(dframesex1) <- dframe1$id[-12115]
colnames(dframesex1) <- c('id','Country','Genes','AMR.Gene.symbol','Host.sex','Sexual.behaviour')
for(r in 1:nrow(metadatamaster)) {
  dframesex1[metadatamaster$displayname[r],'Host.sex'] <- metadatamaster$Host.sex[r]
  dframesex1[metadatamaster$displayname[r],'Sexual.behaviour'] <- metadatamaster$Sexual.behaviour[r]
  dframesex1[paste(metadatamaster$displayname[r],'1',sep='_'),'Host.sex'] <- metadatamaster$Host.sex[r]
  dframesex1[paste(metadatamaster$displayname[r],'1',sep='_'),'Sexual.behaviour'] <- metadatamaster$Sexual.behaviour[r]
  print(r)
}
dframesex1['SAMN10921003_1',]

write.csv(dframesex1,file='~/PRACS/results/dframesex1.csv')
