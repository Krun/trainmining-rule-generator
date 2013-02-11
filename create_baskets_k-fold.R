create_k_basket_files <- function(target,name,k,path="baskets/",days=1) {
  dir.create(path, showWarnings = FALSE)
  path <- paste(path,name,"/",sep="")
  dir.create(path, showWarnings = FALSE)
  cat("CREATING K BASKET FILES FOR",name,"IN",path,"\n")
  cat("Grouping",days,"day(s)\n")
  
  prep <- data.frame(ERROR = target$ADDITIONAL_TEXT)
  prep$ERROR <- as.factor(prep$ERROR)
  
  prep$sequenceID <- as.factor(target$DVNI_INSTALLATIONCODE)
  prep$eventID <- as.factor(target$DVNS_ERRORTIME)
  prep$eventID <- strptime(prep$eventID, "%Y-%m-%d %H:%M:%S")
  prep$eventID <- as.numeric(prep$eventID)
  prep <- prep[complete.cases(prep),]
  prep$eventID <- prep$eventID - min(prep$eventID)
  prep$eventID <- as.numeric(prep$eventID) %/% (60*60*24*days) #Pasamos de segundos a dias.
  prep$eventID <- as.numeric(as.character(prep$eventID))
  

  prep <- prep[order(prep$eventID, prep$sequenceID), ]
  prep <- prep[!duplicated(prep),]
  rownames(prep) <- NULL
  
  prep$kIndex <- ((as.numeric(rownames(prep)) / max(as.numeric(rownames(prep))))*k ) %/% 1
  prep$kIndex[prep$kIndex == k] = (k-1) #Evitamos que quede un último grupo con un elemento
  
  
  splits <- split(prep, prep$kIndex, drop=TRUE)
  
  for (i in 1:length(splits)){
    cat("Creating basket set",i,"\n")
    test_set <- splits[[i]]
    bfile <- paste(path,name,"_",i,"_test.txt",sep="")
    write_basket_file(test_set,bfile)
    learning_set <- splits[-i]
    learning_set <- do.call("rbind",learning_set)
    bfile <- paste(path,name,"_",i,"_learn.txt",sep="")
    write_basket_file(learning_set,bfile)
  }
}

write_basket_file <- function(target, bfile) {
  
  prep_split <- split(target, target$sequenceID, drop=TRUE) 
  cat(file=bfile)
  for(i in 1:length(prep_split)){
    sameseq <- prep_split[[i]]
    seqnum <- as.numeric(sameseq$sequenceID[1])
    sameseq$sequenceID <- NULL
    eventsplit <- split(sameseq, sameseq$eventID)
    for (j in 1:length(eventsplit)){
      time <- as.numeric(eventsplit[[j]]$eventID[1])
      items <- as.character(eventsplit[[j]]$ERROR)
      size <- length(items)
      if(size > 0){
        cat(file=bfile, seqnum, time, size, items, "\n", append=TRUE)
      }
    }
  }
}

create_basket_file <-function(target, bfile) {
  #prep <- data.frame(ERROR = paste(antequera$ADDITIONAL_TEXT,gsub(" ","_",antequera$ADDITIONAL_INFOS),sep='#'))
  prep <- data.frame(ERROR = target$ADDITIONAL_TEXT)
  prep$ERROR <- as.factor(prep$ERROR)
  
  prep$sequenceID <- as.factor(target$DVNI_INSTALLATIONCODE)
  prep$eventID <- as.factor(target$DVNS_ERRORTIME)
  prep$eventID <- strptime(prep$eventID, "%Y-%m-%d %H:%M:%S")
  prep$eventID <- as.numeric(prep$eventID)
  prep <- prep[complete.cases(prep),]
  prep$eventID <- prep$eventID - min(prep$eventID)
  prep$eventID <- as.numeric(prep$eventID) %/% (60*60*24) #Pasamos de segundos a dias.
  prep$eventID <- as.factor(prep$eventID)
  
  prep <- prep[order(prep$sequenceID, prep$eventID), ]
  prep <- prep[!duplicated(prep),]
  
  prep_split <- split(prep, prep$sequenceID) 
  
  
  cat(file=bfile)
  for(i in 1:length(prep_split)){
    sameseq <- prep_split[[i]]
    seqnum <- as.numeric(sameseq$sequenceID[1])
    sameseq$sequenceID <- NULL
    eventsplit <- split(sameseq, sameseq$eventID)
    for (j in 1:length(eventsplit)){
      time <- as.numeric(eventsplit[[j]]$eventID[1])
      items <- as.character(eventsplit[[j]]$ERROR)
      size <- length(items)
      if(size > 0){
        cat(file=bfile, seqnum, time, size, items, "\n", append=TRUE)
      }
    }
  }
}