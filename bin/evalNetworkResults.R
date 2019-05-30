#!/usr/bin/env Rscript


##eval network results
suppressPackageStartupMessages(require(optparse))
suppressPackageStartupMessages(require(dten))
suppressPackageStartupMessages(require(methods))
#args=list(nodetableid='syn18820883',termtableid='syn18820885',weight=95)
getArgs<-function(){

  option_list <- list(
    make_option(c("-n", "--nodetableid"), dest='nodetableid',help='Synapse id of table'),
    make_option(c('-t',"--termtableid"),dest='termtableid',help='Synapse id of enrichment term table'),
    make_option(c("-o", "--output"), default="test", dest='output',help = "Prefix to add to output files"),
    make_option(c('-w','--weight'),dest='weight',help='Weight threshold for evaluating nodes/drugs of interest'),
 #   make_option(c('-p',"--project"),dest='project',default=NULL,help='Synapse id of project to store table'),
    make_option(c('-f',"--folder"),dest='folder',default=NULL,help='Synapse id of folder to store new network')
  )

  args=parse_args(OptionParser(option_list = option_list))

  return(args)
}

getMeanWeights<-function(tab){
  require(tidyverse)
  res=tab%>%group_by(Condition,Node,nodeType)%>%
    summarize(meanWeight=mean(NodeWeight))%>%
    arrange(desc(meanWeight))
  res
}

getTermCounts<-function(tab){
  require(tidyverse)
  tcounts<-tab%>%group_by(Condition,Term)%>%summarize(Terms=n())
  return(tcounts)
}

buildRepresentativeNetwork<-function(nets,node.tab,nodelist,eweight){
    require(igraph)
    require(synapser)
    
  #load nets
  all.nets<-lapply(nets,function(x) readRDS(synapser::synGet(x)$path))
  
  #get union of networks
  combined.graph<-do.call(rbind,lapply(all.nets,function(x) igraph::as_data_frame(x$network)))
  merged.graph<-combined.graph%>%group_by(from,to)%>%summarize(totWeight=sum(weight))%>%distinct()
  weight.graph<-subset(merged.graph,totWeight>eweight)
#  weight.graph=merged.graph  
  #filter for nodes that are selected?
  #nodelist<-intersect(node.tab$Node,union(weight.graph$from,weight.graph$to))
  vals=intersect(which(weight.graph$from%in%nodelist),which(weight.graph$to%in%nodelist))
  red.graph<-weight.graph[vals,]%>%rename(weight='totWeight')
  #red.graph<-weight.graph%>%rename(weight='totWeight')
  
  new.graph <- igraph::graph_from_data_frame(red.graph,directed=FALSE,vertices=subset(node.tab,Node%in%union(red.graph$from,red.graph$to)))
#  inds=match(node.tab$Node,names(igraph::V(graph = new.graph)))
#  w.graph=igraph::set_vertex_attr(new.graph,name='weight',index=igraph::V(new.graph),value=node.tab$meanWeight[inds])
 # w.graph=igraph::set_vertex_attr(w.graph,name='type',index=igraph::V(w.graph),value=node.tab$nodeType[inds])
 list(network=new.graph,tab=red.graph)
    }

getSubnetByNode<-function(nodename){

}

saveToNdex<-function(network,name,collection){
  require(ndexr)
  require(RCy3)
  ndexcon <- ndex_connect()
  
 net.suid <- RCy3::createNetworkFromIgraph(network, name,collection)
 # user <- "sara.gosline"  #replace with your info
#  pass <- "nedexpass"  #replace with your info
#  exportNetworkToNDEx(user, pass, isPublic=TRUE, network=net.suid)
  
}
main<-function(){

    args<-getArgs()
                                        #first rank nodes by codition, gene vs. compound

    require(synapser)
    synLogin()
    require(tidyverse)
    tab<-synTableQuery(paste("select * from",args$nodetableid))$asDataFrame()
    mweights<-getMeanWeights(tab)
    
    ttab<-synTableQuery(paste("select * from",args$termtableid))$asDataFrame()
    tcounts<-getTermCounts(ttab)
    
    ##plot summary statistics as histogram to evaluate distribution
    p=ggplot(mweights)+geom_histogram(mapping=aes(x=meanWeight,fill=Condition),position='dodge')+ggtitle(paste('Node Weights Across Parameters\n',args$output))
    pname=paste(gsub(' ','',args$output),'nodeDistribution.png')
    ggsave(pname)
    #===================
    
    tname=paste(gsub(' ','',args$output),'TermDistribution.png')
    p2=ggplot(tcounts)+geom_histogram(mapping=aes(x=Terms,fill=Condition),position='dodge')+ggtitle(paste('Unique EnrichmentTerms\n',args$output))
    ggsave(tname)
    
    eweight=200
    #get node weights
    all.conditions<-unique(mweights$Condition)
    
    sums<-lapply(all.conditions,function(cond){
      dis.net<-mweights%>%subset(Condition==cond)
      nodes=dis.net$Node#subset(dis.net,meanWeight>args$weight)$Node
      
      nets<-subset(tab,Condition==cond)%>%subset(Node%in%nodes)%>%select(network)%>%unique()
 #     print(paste("Found",length(nets$network),'networks for',cond,'from',nrow(stab),'nodes above threshold'))
      comb<-buildRepresentativeNetwork(nets$network,dis.net[,-1],nodelist=nodes,eweight)
      print(paste('found network with',length(igraph::V(comb$network)),'nodes and',length(igraph::E(comb$network)),'edges'))
      saveToNdex(comb$network,name=cond,collection='DTEN Networks')
      df=data.frame(condition=cond,comb$tab)
      df
    })
    res=do.call(rbind,sums)
    write.table(res,paste(args$output,'allNetworkResults.tsv',sep=''),sep='\t')
    write.table(mweights,paste(args$output,'allNodeResults.tsv',sep=''),sep='\t')
    #  names(sums)<-all.conditions
}

main()
