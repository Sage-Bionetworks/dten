##dten-specific functions



findDistinctDrugs<-function(nets){
  drugs<-lapply(nets,function(pcsf.res){
    drug.res <- igraph::V(pcsf.res)$name[which(igraph::V(pcsf.res)$type=='Compound')]
  })

  unique.drugs<-lapply(1:length(drugs),function(x)
      setdiff(drugs[[x]],unique(unlist(drugs[-x]))))
#  print(paste('found',length(unique.drugs),'unique compounds'))
  unique.drugs
}

findDistinctGenes<-function(nets){
  genes<-lapply(nets,function(pcsf.res){
    gene.res <- igraph::V(pcsf.res)$name[which(igraph::V(pcsf.res)$type!='Compound')]
  })
  u.genes<-lapply(1:length(genes),function(x)
      setdiff(genes[[x]],unique(genes[-x])))
#  print(paste('Found',length(u.genes),'distinct genes'))
  u.genes
}

findDistinctTerms<-function(enrichs){
  terms.only<-lapply(enrichs,function(x) unique(x$Term))
  dist.inds<-lapply(1:length(terms.only),function(x)
    setdiff(terms.only[[x]],unlist(terms.only[-x])))

  new.terms<-lapply(1:length(enrichs),function(x)
      enrichs[[x]][which(enrichs[[x]]$Term%in%dist.inds[[x]]),])
#  print(paste("Found",length(new.terms),'distinct terms'))
  return(new.terms)
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
  netnames<-lapply(netlist,function(x) x$condition)
  nets<-lapply(netlist,function(x) x$network)
  enrichs<-lapply(netlist,function(x) x$enrichment)
  params<-lapply(netlist,function(x) x$params)
  distinct.genes<-findDistinctGenes(nets)
  distinct.drugs<-findDistinctDrugs(nets)
  distinct.terms<-findDistinctTerms(enrichs)

  ##what do i want to see?
  require(dplyr)
  term.tab<-do.call(rbind,lapply(1:length(netlist),function(x){
      print(x)
    print(dim(distinct.terms[[x]]))
      if(is.null(dim(distinct.terms[[x]]))){
          return(data.frame(Condition=c(),mu=c(),beta=c(),w=c(),Cluster=c(),Term=c(),Overlap=c(),Adjusted.P.Value=c(),Genes=c(),DrugsByBetweenness=c()))}
    
 #     params[[x]]$mu<-params[[x]][[3]]
    res<-dplyr::select(distinct.terms[[x]],Cluster,Term,Overlap,Adjusted.P.value,Genes,DrugsByBetweenness)
    data.frame(Condition=rep(netnames[[x]], nrow(res)),
               mu=rep(params[[x]]$mu, nrow(res)),
               beta=rep(params[[x]]$b, nrow(res)),
               w=rep(params[[x]]$w,nrow(res)), res)
  }))

  unique.nodes<-do.call(rbind,lapply(1:length(netlist),function(x){
#          params[[x]]$mu<-params[[x]][[3]]
    rbind(data.frame(Condition=netnames[[x]],
                     mu=params[[x]]$mu,
                     beta=params[[x]]$b,
                     w=params[[x]]$w,
                     Node=distinct.drugs[[x]],nodeType='Compound'),
          data.frame(Condition=netnames[[x]],
                     mu=params[[x]]$mu,
                     beta=params[[x]]$b,
                     w=params[[x]]$w,
                     Node=distinct.genes[[x]],nodeType='Gene'))}))

  return(list(terms=term.tab,nodes=unique.nodes))



}
