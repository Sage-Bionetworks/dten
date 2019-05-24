#!/usr/bin/env Rscript


##eval network results
suppressPackageStartupMessages(require(optparse))
suppressPackageStartupMessages(require(dten))
suppressPackageStartupMessages(require(methods))

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

buildRepresentativeNetwork<-function(nets,nodelist){
    require(networkx)
  
  #load nets
  #get union of networks
  #filter for nodes that are selected?
  #reweight
  #return
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
    
    #get node weights
    all.conditions<-unique(mweights$Condition)
    sums<-lapply(all.conditions,function(cond){
      stab<-mweights%>%subset(Condition==cond)%>%subset(meanWeight>args$weight)
      nets<-subset(tab,Condition==cond)%>%subset(Node%in%stab$Node)%>%select(network)%>%unique()
      print(paste("Found",length(nets),'for',cond,'from',nrow(stab),'nodes above threshold'))
      net<-buildRepresentativeNetwork(nets,stab)
    })


}

main()
