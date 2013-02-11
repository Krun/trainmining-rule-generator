library(arules)
library(arulesSequences)

cspade_k_fold <- function(name,k,path_in="baskets/",path_out="/opt/adri/r-output/sequences/",params=list(support=0.3, mingap=1, maxgap=1, maxlen=2, maxsize=5)) {
  cat("EXECUTING CSPADE\n")
  path_in <- paste(path_in,name,"/",sep="")
  dir.create(path_out, showWarnings = FALSE)
  for (i in 1:k) {
    filename <- paste(path_in,name,"_",i,"_learn.txt",sep="")
    info <- c("sequenceID","eventID","SIZE")
    x <- read_baskets(con = filename, info = info)
    cat("Executing cSPADE for",name,i,"\n")
    s <- cspade(x, parameter=params)
    cat("Converting results to data frame\n")
    s <- as(s,"data.frame")
    cat("Done\n")
    filenamer <- paste(path_out,name,"_",i,".txt",sep="")
    cat("Writing data frame to",filenamer,"\n")
    write.csv(s,file=filenamer)
  }
  
}