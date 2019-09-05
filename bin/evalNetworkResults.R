#!/usr/bin/env Rscript


##eval network results
suppressPackageStartupMessages(require(optparse))
suppressPackageStartupMessages(require(dten))
suppressPackageStartupMessages(require(methods))

cur.node.res<-'syn20609193'
cur.term.res<-'syn20609194'

#args=list(nodetableid='syn18820883',termtableid='syn18820885',weight=95)
getArgs<-function(){

  option_list <- list(
    make_option(c("-i", "--nodetableid"), dest='nodetableid',help='Synapse id of table',default=cur.node.res),
    make_option(c('-t',"--termtableid"),dest='termtableid',help='Synapse id of enrichment term table',default=cur.term.res),
    make_option(c("-o", "--output"), default="test", dest='output',help = "Prefix to add to output files"),
    make_option(c('-w','--weight'),dest='weight',default=0.0,help='Weight threshold for evaluating nodes/drugs of interest'),
    make_option(c('-n','--node'),dest='nodename',default='',help='Name of node to center upon'),
    make_option(c('-s','--stats',dest='stats',default=FALSE,action='store_true',help='Only generate stats')),
 #   make_option(c('-p',"--project"),dest='project',default=NULL,help='Synapse id of project to store table'),
    make_option(c('-f',"--folder"),dest='folder',default=NULL,help='Synapse id of folder to store new network')
  )

  args=parse_args(OptionParser(option_list = option_list))

  return(args)
}


####################Summary statistics
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

#####################################network manipulation

##builds representative network from list of networks stored by synId
buildRepresentativeNetwork<-function(nets,node.vals,eweight=0.0){
    require(igraph)
    require(synapser)
    synLogin()
  #load nets
  all.nets<-lapply(nets,function(x) readRDS(synapser::synGet(x)$path))
  
  combined.graph<-do.call(rbind,lapply(all.nets,function(x) igraph::as_data_frame(x$network)))
  
  all.nodes<-do.call(rbind,lapply(all.nets,function(x) data.frame(Node=names(V(x$network)),Type=V(x$network)$type,Weight=V(x$network)$prize)))
  
  merged.graph<-combined.graph%>%
      group_by(from,to)%>%
      summarize(totWeight=sum(weight))%>%
      distinct()
  
  merged.nodes<-all.nodes%>%
    group_by(Node)%>%
    summarize(meanWeight=mean(Weight))%>%
    distinct()
  merged.nodes$nodeType='Gene'
  merged.nodes$nodeType[which(merged.nodes$Node%in%subset(all.nodes,Type=='Compound')$Node)]<-'Compound'
  weight.graph<-subset(merged.graph,totWeight>eweight)
#  weight.graph=merged.graph  
  #filter for nodes that are selected?
 # vals=intersect(which(weight.graph$from%in%node.vals$Node),which(weight.graph$to%in%node.vals$Node))
#  red.graph<-weight.graph[vals,]%>%rename(weight='totWeight')
  

#  red.verts<-subset(node.vals,Node%in%union(red.graph$from,red.graph$to))%>%
#        select(Node,NodeWeight,nodeType)%>%
#        group_by(Node,nodeType)%>%
#        summarize(meanWeight=mean(NodeWeight))
    
  new.graph <- igraph::graph_from_data_frame(weight.graph,directed=FALSE,vertices=merged.nodes)
  
  list(network=new.graph,tab=weight.graph)
}

##gets a subnet (without drugs) x steps away from node of interest
getSubnetByNode<-function(nodename,rep.graph,name,order=2){
  full.net<-rep.graph$network
  all.drugs<-V(full.net)[which(V(full.net)$nodeType=='Compound')]$name
  if(!nodename%in%all.drugs)
    return("Drug not in network")
  other.drugs<-setdiff(all.drugs,nodename)
  red.graph<-delete_vertices(full.net,other.drugs)
  print(paste("Reduced graph of",length(V(full.net)),'nodes to',length(V(red.graph)),'nodes after removing',length(other.drugs),'drugs'))
  res.net=make_ego_graph(red.graph,nodes=nodename,order=order)[[1]]
  
  saveToNdex(res.net,paste(name,'pathOf',order,sep='_'))
  
}

###ultimately will plot to NDEX for now will just open cytoscpae
saveToNdex<-function(network,name,collection='DTEN Networks'){
  require(ndexr)
  require(RCy3)
#  ndexcon <- ndex_connect()
  
 net.suid <- RCy3::createNetworkFromIgraph(network, name,collection)
 net.suid
 # user <- "sara.gosline"  #replace with your info
#  pass <- "nedexpass"  #replace with your info
#  exportNetworkToNDEx(user, pass, isPublic=TRUE, network=net.suid)
  
}


####plot nets by drug
plotNetsByDrugInCondition<-function(all.conditions,all.nodes,tab.id,order=2){
  tab<-synTableQuery(paste("select * from",tab.id))$asDataFrame()
  
  sums<-lapply(all.conditions,function(cond){
    #get networks in that condition
    cond.tab<-subset(tab,Condition==cond)
    nets<-unique(cond.tab$network)
    #get nodes that are in that network
    sel.nodes<-intersect(cond.tab$Node,all.nodes)
    
    if(length(sel.nodes)>0){
      #build a representative network
      comb<-buildRepresentativeNetwork(nets,tab)
      print(paste('found',cond,'network with',length(igraph::V(comb$network)),'nodes and',length(igraph::E(comb$network)),'edges'))
      res=lapply(sel.nodes,function(n){
        print(n)
        getSubnetByNode(n,comb,name=paste(cond,n,sep='_'),order=order)
      })
    }
  })
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
    
    if(length(args$stats)>0 && args$stats){
      ##plot summary statistics as histogram to evaluate distribution
      p=ggplot(mweights)+geom_histogram(mapping=aes(x=meanWeight,fill=Condition),position='dodge')+ggtitle(paste('Node Weights Across Parameters\n',args$output))
      pname=paste(gsub(' ','',args$output),'nodeDistribution.png')
      ggsave(pname)
      #===================
    
      tname=paste(gsub(' ','',args$output),'TermDistribution.png')
      p2=ggplot(tcounts)+geom_histogram(mapping=aes(x=Terms,fill=Condition),position='dodge')+ggtitle(paste('Unique EnrichmentTerms\n',args$output))
      ggsave(tname)
    }else if(args$nodename==''){
    eweight=200
    #get node weights
    all.conditions<-unique(mweights$Condition)
    
    sums<-lapply(all.conditions,function(cond){
      dis.net<-mweights%>%subset(Condition==cond)
      nodes=dis.net$Node#subset(dis.net,meanWeight>args$weight)$Node
      
      nets<-subset(tab,Condition==cond)%>%subset(Node%in%nodes)%>%select(network)%>%unique()
 #     print(paste("Found",length(nets$network),'networks for',cond,'from',nrow(stab),'nodes above threshold'))
      comb<-buildRepresentativeNetwork(nets$network,dis.net[,-1],eweight)
      print(paste('found network with',length(igraph::V(comb$network)),'nodes and',length(igraph::E(comb$network)),'edges'))
      saveToNdex(comb$network,name=cond,collection='DTEN Networks')
      df=data.frame(condition=cond,comb$tab)
      df
    })
    res=do.call(rbind,sums)
    write.table(res,paste(args$output,'allNetworkResults.tsv',sep=''),sep='\t')
    write.table(mweights,paste(args$output,'allNodeResults.tsv',sep=''),sep='\t')
    }
    else{
      all.conditions<-unique(mweights$Condition)
      all.nodes=unlist(strsplit(args$nodename,split=','))
      plotNetsByDrugInCondition(all.conditions,all.nodes,args$nodename)
    }
    #  names(sums)<-all.conditions
}

#main()
