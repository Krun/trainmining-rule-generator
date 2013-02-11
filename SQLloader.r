library(DBI)
library(RMySQL)
drv <- dbDriver("MySQL")

if(!exists("antequera")){
  dbantequera <- dbConnect(drv,dbname="BDAlcatel_Antequera_dbo","root","root")
  antequera <- dbGetQuery(dbantequera,"select * from ER_ERRORS JOIN ERS_ERRORS_SAM_ENCE using(DVNI_ERRORNUMBER) JOIN IG_INSTALLATIONGENERAL using(DVNI_INSTALLATIONCODE) WHERE DVNI_ERRORCATEGORY != '-1'")
  dbDisconnect(dbantequera)
  rm(dbantequera)
  write.table(antequera, file="Datos/current/antequera.csv",col.names=TRUE,sep=";")
}

# if(!exists("sevilla")){ 
#   dbsevilla <- dbConnect(drv,dbname="BDAlcatel_Sevilla_dbo","root","root")
#   sevilla <- dbGetQuery(dbsevilla,"select * from ER_ERRORS JOIN ERS_ERRORS_SAM_ENCE using(DVNI_ERRORNUMBER) WHERE DVNI_ERRORCATEGORY != '-1'")
#   dbDisconnect(dbsevilla)
#   rm(dbsevilla)
   write.table(sevilla, file="Datos/current/sevilla.csv",col.names=TRUE,sep=";")
#   
# }
# 
# if(!exists("camas")||!exists("errortext")) {
#   dbcamas <- dbConnect(drv,dbname="BDAlcatel_Camas_dbo","root","root")
#   camas <- dbGetQuery(dbcamas,"select * from ER_ERRORS JOIN ERS_ERRORS_SAM_ENCE using(DVNI_ERRORNUMBER) WHERE DVNI_ERRORCATEGORY != '-1'")
#   errortext <- dbGetQuery(dbcamas,"select * from ER_MESSAGES WHERE ID_LANGUAGE = 1")
#   dbDisconnect(dbcamas)
#   rm(dbcamas)
#   write.table(camas, file="Datos/camas.csv",col.names=TRUE,sep=";")
#   
# }
# 
 if (!exists("errortext")) {
   dbcamas <- dbConnect(drv,dbname="BDAlcatel_Camas_dbo","root","root")
   errortext <- dbGetQuery(dbcamas,"select * from ER_MESSAGES WHERE ID_LANGUAGE = 1")
   dbDisconnect(dbcamas)
   rm(dbcamas)
   write.table(errortext, file="Datos/errortext.csv",col.names=TRUE,sep=";")
}
# 
# if(!exists("segovia")) {
#   dbsegovia <- dbConnect(drv,dbname="BDAlcatel_segovia_dbo","root","root")
#   segovia <- dbGetQuery(dbsegovia,"select * from ER_ERRORS JOIN ERH_ERRORS_HSL1 using(DVNI_ERRORNUMBER) WHERE DVNI_ERRORCATEGORY != '-1'")
#   dbDisconnect(dbsegovia)
#   rm(dbsegovia)
   write.table(segovia, file="Datos/current/segovia.csv",col.names=TRUE,sep=";")
# }

rm(drv)

sevilla[sevilla$EVENT_TYPE == "FieldElementFailure",]$EVENT_TYPE = "fieldElementFailure"