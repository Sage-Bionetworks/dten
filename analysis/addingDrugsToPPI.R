
##drug-target vs protein interaction network
require(dten)

dg<-dten::loadDrugGraph()
ppi<-dten::buildNetwork(dg)
dummies<-dten::getDrugs(dg)

##fig 3
get.shortest.path<-function(){
  require(igraph)
  prots.only<-setdiff(names(igraph::V(ppi)),names(igraph::V(dg)))
  drugs<-intersect(dummies,names(igraph::V(ppi)))
  dvals<-igraph::distances(ppi,v=V(ppi)[prots.only], to=V(ppi)[drugs])
}


