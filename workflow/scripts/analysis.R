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
      if(!('Cloramphenicols' %in% classres)) {
        classres <- c(classres,'Cloramphenicols')
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
