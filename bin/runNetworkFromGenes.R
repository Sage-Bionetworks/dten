#!/usr/bin/env Rscript

require(optparse)
require(dten)
getArgs<-function(){
  require(optparse)
  option_list <- list(
    make_option(c("-i", "--input"), dest='input',help='Tab-delimited file of protein names and weights'),
    make_option(c("-m", "--mu"), default=5e-04,dest='mu', help="Probability the cell types are unknown"),
    make_option(c("-o", "--output"), default="testout", dest='output',help = "Prefix to add to output files"),
    make_option(c('-b','--beta'), default=1, dest='beta',help="How much to weight terminals"),
    make_option(c('-w','--w'),default=2, dest='w',help="Omega value to control how many trees are created in forest")
  )
  
  args=parse_args(OptionParser(option_list = option_list))
  
  return(args)
}
  
getNetwork<-function(prot.table,w,b,mu){
  dg<-dten::loadDrugGraph()
  ppi<-dten::buildNetwork(dg)
  prots<-tab$vals%>%setNames(tab$gene)
  dummies<-dten::getDrugs(dg)

  pcsf.res<-dten::runPcsfWithParams(ppi,prots, dummies, w=2, b=1, mu=5e-04,doRand=TRUE)

  pcsf.res <-dten::renameDrugIds(pcsf.res,dummies)

  #dump to R
  write_rds(pcsf.res,path='pcsfGraph.rds')
}
