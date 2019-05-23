#!/usr/bin/env Rscript


##run meta-network comparisons
suppressPackageStartupMessages(require(optparse))
suppressPackageStartupMessages(require(dten))
require(methods)

getArgs<-function(){

  option_list <- list(
    make_option(c("-i", "--input"), dest='input',help='Comma-delimited list of RDS files containing PCSF and enrichment output'),
    make_option(c("-o", "--output"), default="test", dest='output',help = "Prefix to add to output files"),
    make_option(c('-p',"--project"),dest='project',default=NULL,help='Synapse id of project'),
    make_option(c('-f',"--folder"),dest='folder',default=NULL,help='Synapse id of folder to store network')
  )

  args=parse_args(OptionParser(option_list = option_list))

  return(args)
}

getTableInstance<-function(parentId,name){
  require(synapser)
  synapser::synLogin()
  clist=as.list(synGetChildren(parentId))
  tab.names=unlist(lapply(clist,function(x){
          if(x$type=='org.sagebionetworks.repo.model.table.TableEntity'){
          return(x$name)}}))
  tab.ids=unlist(lapply(clist,function(x){
    if(x$type=='org.sagebionetworks.repo.model.table.TableEntity'){
      return(x$id)}}))
  if(name%in%tab.names)
    return(tab.ids[match(name,tab.names)])
  else
    return(NULL)
  }


buildDtenTable<-function(tabname,parent,values){
    col=lapply(names(values),function(x){
        if(is.numeric(values[[x]])||x=='Adjusted.P.Value')
            synapser::Column(name=x,columnType="DOUBLE")
        else if(x%in%c("Genes","DrugsByBetweenness"))
            synapser::Column(name=x,columnType='LARGETEXT')
        else if(x%in%c("network"))
            synapser::Column(name=x,columnType='ENTITYID')
        else
            synapser::Column(name=x,columnType='STRING',maximumSize=256)
    })
    return(synapser::Table(synapser::Schema(name=tabname,parent=parent,columns=col),values))

    }

storeTab <-function(values,tabname,synid){
    library(synapser)
    synLogin()
    tabid=getTableInstance(synid,tabname)
    print(tabid)
    values<-as.data.frame(values)
    if(is.null(tabid)){
                                        #print(dim(values))
        tab<-buildDtenTable(tabname=tabname,parent=synid,values=values)
    }else{
        tab <-synapser::Table(tabid,values)
    }
    synapser::synStore(tab)


    }

writeTab<-function(name,dat){
  if(file.exists(name)){
    tab<-read.table(name,sep='\t')
    tab<-rbind(tab,dat)
  }else{
    tab<-dat
  }
  write.table(tab,file=name,sep='\t')

}

storeNets<-function(nets,folderid){
  library(synapser)
  synLogin()
  ids<-lapply(nets,function(n){
      fname=paste(n$condition,'mu',n$params$mu,'beta',n$params$b,'w',n$params$w,'networks.rds',sep='_')
      saveRDS(n,file=fname)
      res=synStore(File(fname,parentId=folderid))
      res$properties$id
  })
  names(ids)<-lapply(nets,function(x) x$condition)
  ids
 }

main<-function(){

    args<-getArgs()

  all.nets<-lapply(unlist(strsplit(args$input,split=',')),readRDS)
  print(paste("Loaded",length(all.nets),'networks'))

     synids<-storeNets(all.nets,args$folder)
    summary<-dten::getNetSummaries(all.nets,synids)


  nfile=paste(gsub(" ","",args$output),'nodeOutput.tsv',sep='')
  tfile=paste(gsub(" ","",args$output),'termOutput.tsv',sep='')
  writeTab(nfile,summary$nodes)
  writeTab(tfile,summary$terms)

  if(!is.null(args$project)){
    n.tabname=paste(args$output,'DTEN Node results')
    t.tabname=paste(args$output,'DTEN Term results')
    storeTab(values=summary$nodes,tabname=n.tabname,synid=args$project)
    storeTab(values=summary$terms,tabname=t.tabname,synid=args$project)
  }
}

main()
