source("bin/pcsf.R")
source("bin/dtex.R")

args=commandArgs()
dg<-loadDrugGraph()
ppi<-buildNetwork(dg)
prots<-tab$vals%>%setNames(tab$gene)
dummies<-getDrugs(dg)

pcsf.res<-runPcsfWithParams(ppi,prots, dummies, w=2, b=1, mu=5e-04,doRand=TRUE)

pcsf.res <-renameDrugIds(pcsf.res,dummies)

#dump to R
write_rds(pcsf.res,path='pcsfGraph.rds')
