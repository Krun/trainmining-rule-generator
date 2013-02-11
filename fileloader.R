if(!exists("antequera")){
  antequera_1 <- read.csv("Datos/antequera_1.csv", header = TRUE, sep=";")
  antequera_2 <- read.csv("Datos/antequera_2.csv", header = TRUE, sep=";")
  antequera_1 <- antequera_1[,c("DVNI_INSTALLATIONCODE", "DVNS_ERRORTIME", "DVNI_ERRORCATEGORY", "ADDITIONAL_TEXT", "ADDITIONAL_INFOS", "EVENT_TYPE")]
  names(antequera_2)[names(antequera_2)=="X.DVNI_INSTALLATIONCODE"] <- "DVNI_INSTALLATIONCODE"
  antequera <- rbind(antequera_1, antequera_2)
  rm(antequera_1)
  rm(antequera_2)
}


 if(!exists("segovia")) {
   segovia_1 <- read.csv("Datos/segovia_1.csv", header = TRUE, sep=";")
   segovia_2 <- read.csv("Datos/segovia_2.csv", header = TRUE, sep=";")
   segovia_1 <- segovia_1[,c("DVNI_INSTALLATIONCODE", "DVNS_ERRORTIME", "DVNI_ERRORCATEGORY", "ADDITIONAL_TEXT", "ADDITIONAL_INFOS", "EVENT_TYPE")]
   names(segovia_2)[names(segovia_2)=="X.DVNI_INSTALLATIONCODE"] <- "DVNI_INSTALLATIONCODE"
   segovia <- rbind(segovia_1, segovia_2)
   rm(segovia_1)
   rm(segovia_2)
 }
 
 if(!exists("sevilla")){
   sevilla <- read.csv("Datos/sevilla.csv", header = TRUE, sep=";")
   camas <- read.csv("Datos/camas.csv", header = TRUE, sep=";")
   sevilla <- rbind(sevilla,camas)
   sevilla[sevilla$EVENT_TYPE == "FieldElementFailure",]$EVENT_TYPE = "fieldElementFailure"
   sevilla$EVENT_TYPE <- droplevels(sevilla$EVENT_TYPE)
   
   sevilla <- sevilla[,c("DVNI_INSTALLATIONCODE", "DVNS_ERRORTIME", "DVNI_ERRORCATEGORY", "ADDITIONAL_TEXT", "ADDITIONAL_INFOS", "EVENT_TYPE")]
   rm(camas)
 }
 

if(!exists("albacete")) {
  albacete <- read.csv("Datos/albacete.csv", header = TRUE, sep=";")
  names(albacete)[names(albacete)=="X.DVNI_INSTALLATIONCODE"] <- "DVNI_INSTALLATIONCODE"
}


#antequera$DVNS_ERRORTIME <- as.POSIXlt(strptime(antequera$DVNS_ERRORTIME, "%Y-%m-%d %H:%M:%S"))
#segovia$DVNS_ERRORTIME <- as.POSIXlt(strptime(segovia$DVNS_ERRORTIME, "%Y-%m-%d %H:%M:%S"))
#sevilla$DVNS_ERRORTIME <- as.POSIXlt(strptime(sevilla$DVNS_ERRORTIME, "%Y-%m-%d %H:%M:%S"))
#camas$DVNS_ERRORTIME <- as.POSIXlt(strptime(camas$DVNS_ERRORTIME, "%Y-%m-%d %H:%M:%S"))
#sevilla_new_2009$DVNS_ERRORTIME <- as.POSIXlt(strptime(camas$DVNS_ERRORTIME, "%Y-%m-%d %H:%M:%S"))
#antequera_new$DVNS_ERRORTIME <- as.POSIXlt(strptime(camas$DVNS_ERRORTIME, "%Y-%m-%d %H:%M:%S"))
#albacete$DVNS_ERRORTIME <- as.POSIXlt(strptime(camas$DVNS_ERRORTIME, "%Y-%m-%d %H:%M:%S"))