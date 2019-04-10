source("./runPCSFWithDTEnetwork.R")

ppi<-buildNetwork(loadDrugGraph())
prots<-tab$vals%>%setNames(tab$gene)
