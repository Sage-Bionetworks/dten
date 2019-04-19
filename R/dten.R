##dten-specific functions




findDistinctDrugs<-function(nets){
  drugs<-lapply(nets,function(pcsf.res){
    drug.res <- igraph::V(pcsf.res)$name[which(igraph::V(pcsf.res)$type=='Compound')]
  })
  
  unique.drugs<-lapply(1:length(drugs),function(x)
    setdiff(drugs[[x]],unique(unlist(drugs[-x]))))
  unique.drugs
}

findDistinctGenes<-function(nets){
  genes<-lapply(nets,function(pcsf.res){
    gene.res <- igraph::V(pcsf.res)$name[which(igraph::V(pcsf.res)$type!='Compound')]
  })
  u.genes<-lapply(1:length(genes),function(x)
    setdiff(genes[[x]],unique(genes[-x])))
  u.genes
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
  
  distinct.genes<-findDistinctGenes(nets)
  distinct.drugs<-findDistinctDrugs(nets)
  
  
  
}
