#--------------------------------------------------------
# runPCSFwithDTEnetwork
#
# take set of viper-identified proteins and merge with DTE network to run pcsf
#
#---------------------------------------------------------



#' \code{buildNetwork} Identifies drugs in a
#' @param drug.graph Tidied drug response
#' @keywords
#' @export
#' @examples
#' @return
#' @import PCSF
#'
buildNetwork <- function(drug.graph){

  ##add weights
#  edge_attr(drug.graph,"weight")<-edge_attr(drug.graph,"mean_pchembl")
  require(PCSF)

  rank.norm<-function(x){
    rank(x)/length(x)
  }

  red.graph<-delete_edges(drug.graph,E(drug.graph)[which(is.na(E(drug.graph)$mean_pchembl))])
  edge_attr(red.graph,"weight")<-rank.norm(edge_attr(red.graph,"mean_pchembl"))

  ##load STRING
  data("STRING")


  ##build interactome
  ppi <- construct_interactome(STRING)

  ##now merge networks
  u.drug.graph <- as.undirected(red.graph)
  combined.df<-rbind(igraph::as_data_frame(ppi),igraph::as_data_frame(u.drug.graph)[,c('from','to','weight')])
  combined.graph <- igraph::graph_from_data_frame(combined.df,directed=FALSE)


  return(combined.graph)
}


#' \code{getDrugsFromGraph} Identifies drugs in a
#' @param combined.graph Graph
#' @keywords
#' @export
#' @examples
#' @return drug names
#' @import igraph
#'
getDrugsFromGraph <-function(drug.graph){
  #the goal of this is to extract the drugs from the graph,
  #which should be the only nodes with an indegree of zero
  names(which(igraph::degree(drug.graph,mode="in")==0))

}

#' \code{getDrugTargets} Gets drug target graph and returns table of drug targeets
#' @param drug.graph
#' @keywords
#' @export
#' @examples
#' @return tidied dataset
getDrugTargets <-function(drug.graph){

  drugs <-getDrugsFromGraph(drug.graph)
  dnames <-getDrugNames(drugs)

  #get drug targets
  targs<-do.call(c,lapply(split(drug_ids,ceiling(seq_along(drug_ids)/1000)),function(drugs){
    sapply(igraph::V(drug.graph)[unlist(igraph::adjacent_vertices(drug.graph,as.character(drugs)))],paste,collapse=',')}))
  drug.tab<-data.frame(dnames,targets=targs)
  drug.targs

}

#' \code{runPcsfWithParams} Identifies drugs in a
#' @param combined.graph
#' @param terminals
#' @param dummies
#' @param w
#' @param b
#' @param mu
#' @param doRand
#' @keywords PCSF terminals network
#' @import PCSF
#' @export
#' @examples
#' @return
runPcsfWithParams <- function(ppi,terminals, dummies, w=2, b=1, mu=5e-04,doRand=FALSE){
  require(PCSF)
  if(doRand)
    res <- PCSF::PCSF_rand(ppi,terminals,w=w,b=b,mu=mu,dummies=dummies,n=100,r=1)
  else
    res <- PCSF::PCSF(ppi,terminals,w=w,b=b,mu=mu,dummies=dummies)

  return(res)

}


#' \code{shuffleTerminalsAndRun} will shuffle terminals for a permutation test
#' @param ppi
#' @param terminals
#' @param dummies
#' @param w
#' @param b
#' @param mu
#' @return original network as well as p-values on each node
shuffleTerminalsAndRun <-function(ppi,terminals,dummies,w,b,mu,numShuffles){

}
