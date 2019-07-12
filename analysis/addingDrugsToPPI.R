
##drug-target vs protein interaction network
require(dten)

dg<-dten::loadDrugGraph()
ppi<-dten::buildNetwork(dg)
alt.ppi<-ppi
edge_attr(alt.ppi)$weight<-1-edge_attri(ppi)$weight
dummies<-dten::getDrugs(dg)

expr.id='syn18523913'
prot.id='syn20503291'
this.script='https://raw.githubusercontent.com/Sage-Bionetworks/dten/master/analysis/addingDrugsToPPI.R'
genes<-read.csv(synGet(expr.id)$path)$gene%>%unique()
prots<-read.table(synGet(prot.id)$path)$gene%>%unique()

##fig 3
get.shortest.path<-function(){
  require(igraph)
  prots.only<-setdiff(names(igraph::V(alt.ppi)),names(igraph::V(dg)))
  drugs<-intersect(dummies,names(igraph::V(alt.ppi)))
  dvals<-igraph::distances(ppi,v=V(ppi)[prots.only], to=V(ppi)[drugs],algorithm='unweighted')
  wvals<-igraph::distances(alt.ppi,v=V(alt.ppi)[prots.only], to=V(alt.ppi)[drugs])
  
  minds<-apply(dvals,1,min)
  minws<-apply(wvals,1,min)
  df<-data.frame(ShortestPath=as.factor(minds),Weighted=minws,genes=rownames(dvals))
  df$data=rep('None',nrow(df))
  df$data[which(df$genes%in%genes)]<-'gene'
  df$data[which(df$genes%in%prots)]<-'protein'
  
  ggplot(subset(df,ShortestPath%in%c(1,2,3,4)))+geom_bar(aes(x=ShortestPath,fill=data),position='dodge')+ggtitle('Shortest path to drug compounds')
  ggsave('shortestPathinDrugPPI.png')
  synStore(File('shortestPathinDrugPPI.png',parentId='syn20503265'))
  
  ggplot(subset(df,ShortestPath%in%c(1,2,3,4)))+geom_violin(aes(x=ShortestPath,y=Weighted,col=data),position='dodge')+ggtitle('Weighted shortest path to drug compound')
  ggsave('weightedShortestPath.png')
  synStore(File('weightedShortestPath.png',parentId='syn20503265'),used=c(expr.id,),executed=this.script)
  }


