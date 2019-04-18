##dten-specific functions



getNetFeatures<-function(pcsf.network){
  require(igraph)
  drug.res <- igraph::V(pcsf.network)$name[which(igraph::V(pcsf.network)$type=='Compound')]
  steiner <- igraph::V(pcsf.network)$name[which(igraph::V(pcsf.network)$type=='Steiner')]
  prize.res <- igraph::V(pcsf.network)$name[which(igraph::V(pcsf.network)$type=='Terminal')]
  return(list(compounds=drug.res,steiner=steiner,terminals=prize.res))  
  
}


findDistinctDrugs<-function(){
  
  
}

findDistinctGenes<-function(){
  
}

#'
#\code{getNetSummaries} Gets summary stats about network
#' @param list of objects from the network calls
#' @keywords
#' @export
#' @import igraph
#' @examples
#' @return list of parameters
getNetSummaries<-function(netlist){
  netnames<-lapply(netlist,function(x) x$Condition)
  nets<-lapply(netlist,function(x) x$subnet)
  enrichs<-lapply(netlist,function(x) x$enrichment)
  
}
