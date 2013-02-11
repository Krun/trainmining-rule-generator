k_average <- function(name, k, path="/opt/adri/r-output/sequences/") {
  i = 1
  cat("Loading validation file",i,"\n")
  av <- read.csv(paste(path,name,"_eval_",i,".txt", sep=""),sep=" ",header = FALSE)
  colnames(av)<-c("rule",paste("precision",i,sep=""),paste("recall",i,sep=""),"r")
  av$r <- NULL
  for (i in 2:k) {
    cat("Loading validation file",i,"\n")
    av = tryCatch({
      s <- read.csv(paste(path,name,"_eval_",i,".txt", sep=""),sep=" ",header = FALSE)
      colnames(s)<-c("rule",paste("precision",i,sep=""),paste("recall",i,sep=""),"r")
      s$r <- NULL
      cat("Merging validation file",i,"\n")
      av <- merge(av,s,by=c("rule"),all = TRUE)
    }, warning = function(w) {
      cat("Failed\n")
      cat(w)
    }, error = function(e) {
      #if file is empty or fails to read, we add columns of NA
      cat("Nothing in file",i,"\n")
      nxt <- length(av) +1
      av[,nxt] = NA
      colnames(av)[nxt] <- paste("precision",i,sep="")
      nxt <- nxt +1
      av[,nxt] = NA
      colnames(av)[nxt] <- paste("recall",i,sep="")
      return(av)
    })
  }
  av[is.na(av)] <- 0
  for (i in 1:k) {
    j <- 2*i
    av[,2] <- av[,2] + av[,j]
    av[,3] <- av[,3] + av[,j+1]
  }
  av[,2] <- av[,2]/k
  av[,3] <- av[,3]/k
  
  av <- av[,1:3]

  colnames(av) <- c("rule","precision","recall")
  
  av <- av[order(av$precision),]
  av <- av[nrow(av):1,]
  rownames(av) <- NULL
  
  filenamer <- paste(path,name,"_meanperformance.txt",sep="")
  
  cat("Average performance data saved to",filenamer,"\n")
  write.csv(av,file=filenamer)
  
  return(av)
  
}

auto_k_validate <- function(name, k, winmax=1, winmin=1, path="/opt/adri/r-output/sequences/", path_in="baskets/", minprec = 0.5) {
  cat("EXECUTING K-FOLD-CV FOR",name,"K=",k,"\n")
  cat("winmin =",winmin,"\n")
  cat("winmax =",winmax,"\n")
  for (i in 1:k){
    auto_validate(name,i,winmax,winmin,path,path_in,minprec)
  }
}

auto_validate <- function(name, i, winmax=1, winmin=1, path="/opt/adri/r-output/sequences/", path_in="baskets/", minprec = 0.5) {
  path_in <- paste(path_in,name,"/",sep="")
  s <- read.csv(paste(path,name,"_",i,".txt", sep=""))
  rules <- as.character(s$sequence)
  testset = load_baskets(filename=paste(path_in,name,"_",i,"_test.txt",sep=""))
  
  bfile = paste(path,name,"_eval_",i,".txt",sep="")
  cat(file=bfile)
  for (j in 1:length(rules)){
    orgrule = rules[[j]]
    rule = processrule(orgrule)
    if (single_consequent(rule)){
      cat("[Set",i,"] Rule",j,"is valid, evaluating\n")
      antecedent = rule[[1]]
      consequent = rule[[2]]
      prec <- precision(antecedent, consequent, testset, winmax, winmin)
      rec <- recall(antecedent, consequent, testset, winmax, winmin)
      if(is.nan(prec) | prec < minprec | is.nan(rec)) {
        next
      }
      cat("[Set",i,"] Rule",j,"is precise, writing to",bfile,"\n")
      cat(file=bfile, orgrule, prec, rec, "\n", append=TRUE)
    }
  }
  
}


single_consequent <- function(rule) {
  return (length(rule[[2]]) == 1)
}

precision <- function(antecedent,consequent,testset,winmax,winmin=1) {
  triggers <-get_triggers(antecedent,testset)
  success = 0;
  for(i in 1:nrow(triggers)){
    ins <- triggers[i,]$installation
    tim <- triggers[i,]$time
    valid <- subset(testset, time >= tim+winmin & time <= tim+winmax & installation == ins & event == consequent[[1]])
    success = success + (nrow(valid) >= 1)
  }
  return(success/nrow(triggers))
}

recall <- function(antecedent, consequent, testset, winmax, winmin=1) {
  triggers <-get_triggers(antecedent,testset)
  numtriggers <- nrow(triggers)
  precision <- precision(antecedent,consequent,testset,winmax,winmin)
  valid_predictions <- precision * numtriggers
  numconsequent <- nrow(testset[testset$event == consequent[[1]], ])
  
  recall <- valid_predictions/numconsequent
  return(recall)
}

get_consequents <- function(consequent,testset) {
  consequents <- testset[testset$event == consequent[[1]]]
  return(consequents)
}


get_triggers <- function(antecedent, testset) {
  triggers <- testset[testset$event == antecedent[[1]], ]
  triggers$event <- NULL
  if (length(antecedent) == 1){
    return(triggers)
  }
  #else, continue applying conditions to find triggers
  for(i in 2:length(antecedent)){
    triggersn <- testset[testset$event == antecedent[[i]], ]
    triggersn$event <- NULL
    triggers <- merge(triggers, triggersn, by=c("time","installation"))
  }
  return(triggers)
}



# success = 0;
# for(w in winmin:winmax){
#   disp <- testset
#   disp$time <- testset$time-w
#   disp <- disp[disp$event == consequent[[1]],]
#   valid <- merge(triggers,disp, by=c("time","installation"))
#   success = success + nrow(valid)
# }



processrule <- function(rule) {
  result = tryCatch({
    splitrule <- strsplit(rule,"{", fixed=TRUE)[[1]]
    antecedent <- strsplit(splitrule[[2]],"}", fixed=TRUE)[[1]][[1]]
    antecedent <- strsplit(antecedent,",",fixed=TRUE)[[1]]
    consequent <- strsplit(splitrule[[3]],"}", fixed=TRUE)[[1]][[1]]
    consequent <- strsplit(consequent,",",fixed=TRUE)[[1]]
    return(list(antecedent,consequent))
  }, warning = function(w) {
    return(c(c(),c()))
  }, error = function(e) {
    return(c(c(),c()))
  }, finally = {
    NULL
  })
}

load_baskets <- function(filename) {
  con <- file(filename, "rt") 
  baskets <- readLines(con, -1)
  close(con)
  df <- NULL
  for(i in 1:length(baskets)){
    line <- strsplit(baskets[[i]]," ",fixed=TRUE)
    line <- line[[1]]
    eventid <- line[[1]]
    sequenceid <- line[[2]]
    for(j in 4:length(line)){
      df <- rbind(df,data.frame(time = eventid, installation = sequenceid, event=line[[j]]))
    }
  }
  df$time <- as.numeric(df$time)
  df$installation <- as.numeric(df$installation)
  return(df)
}