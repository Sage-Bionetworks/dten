#!/usr/bin/env Rscript
library(synapser)
require(optparse)
require(dten)
getArgs<-function(){

  option_list <- list(
    make_option(c("-s", "--store"), dest='input',help='R data file comprised of dten output to be stored'),
    make_option(c('-r',"--retrieve"),dest='params',help='Comma delimited set of file parameters to retrieve'),
    make_option(c("-p", "--parentid"), dest='parentId',help = "Synapse id of folder where file will be stored"),
    make_option(c('-c','--condition'),dest='condition',help='Condition of interest to find differentially regulated proteins, to store in table'),
    make_option(c('-t','--tableid'),dest='table',help='Synapse table to add/retrieve results')
  )

  args=parse_args(OptionParser(option_list = option_list))

  return(args)
}


makeTable<-function(projectId){
  cols <- list(
    Column(name = "Condition", columnType = "STRING", maximumSize = 100),
    Column(name = "PCSF Result",columnType = "Entity"),
    Column(name = 'mu',columnType="DOUBLE"),
    Column(name = 'beta',columnType='DOUBLE'),
    Column(name = 'w',columnType='DOUBLE'))
    
  schema <- Schema(name = "DTEN Results", columns = cols, parent = projectId)
  
  table <- Table(schema, genes)
  synStore(table)
}

storeNetWithStats<-function(condition, netfile,params, parentId,tableid){
  #should we store nodenames? or just process them offline? 
  #  nodenames<-dten::getNetFeatures(readRDS(netfile))
    
}


getNetsByParams<-function(mu,beta,w,synid){
  query=paste("SELECT Condition, `PCSF Result` FROM",synid,"where mu =",mu," AND w=",w,"AND beta=",beta)
  
}

main<-function(){
    args<-getArgs()
}

main()
