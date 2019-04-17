##dten-specific functions


#'
#\code{getNetFeatures} Gets summary stats about network
#' @param pcsf.network
#' @keywords
#' @export
#' @import igraph
#' @examples
#' @return list of parameters
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
