#--------------------------------------------------------
# runPCSFwithDTEnetwork
#
# take set of viper-identified proteins and merge with DTE network to run pcsf
#
#---------------------------------------------------------

library(PCSF)
##make sure to install PCSF from her
##library(devtools)
##install_github("sgosline/PCSF",username='sgosline')

#' \code{loadDrugGraph} Identifies drugs in a
#' @keywords
#' @export
#' @examples
#' @return
#'
loadDrugGraph <- function(){

  ##load drug-target networ
  require(synapser)
  synLogin()
  drug.graph<-readRDS(synGet('syn11802194')$path)
  return(drug.graph)
}

#' \code{getDrugs} Identifies drugs in a
#' @param drug.graph
#' @keywords
#' @export
#' @examples
#' @return
#'
getDrugs <-function(drug.graph){
        drugs<-names(which(degree(drug.graph,mode="out")>0))
    drugs
}


#' \code{getDrugIds} Identifies drugs in a
#' @param drug_names
#' @param pheno.file Tidied drug response
#' @keywords
#' @export
#' @examples
#' @return
#'
getDrugIds <- function(drug_names,split){
  require(synapser)
  synLogin()
  require(dplyr)
  #remove problematic/combo screens
  parens=grep("(",drug_names,fixed=T)
  if(length(parens)>0)
    drug_names=drug_names[-parens]

  apos=grep("'",drug_names,fixed=T)
  if(length(apos)>0)
    drug_names=drug_names[-apos]

  if(!missing(split))
    drug_names2 <- sapply(drug_names,function(x) unlist(strsplit(x,split=split))[1])
  else
    drug_names2 <- drug_names

  prefix="select internal_id, std_name from syn17090819 where std_name='"
  query=paste(prefix,paste(drug_names2,collapse="' OR std_name='"),sep='')
  res <- synapser::synTableQuery(paste(query,"'",sep=''))$asDataFrame()%>%dplyr::select(-ROW_ID,-ROW_VERSION)

  print(paste("Found",nrow(res),'drug internal ids for',length(drug_names2),'common names'))
  colnames(res) <- c("ids","drugs")

  return(res)

}

#' \code{getDrugNames} Identifies drugs in a
#' @param drug_ids
#' @keywords
#' @export
#' @examples
#' @return
#'
getDrugNames <- function(drug_ids){
  require(synapser)
  require(dplyr)
  synLogin()
  prefix="select internal_id, std_name from syn17090819 where internal_id in ("
  #query=paste(prefix,paste(drug_ids,collapse="' OR internal_id='"),sep='')

  res2<-do.call(rbind,lapply(split(drug_ids,ceiling(seq_along(drug_ids)/50000)),function(x){
    query=paste(prefix,paste(sapply(x,function(y) paste("'",y,"'",sep='')),collapse=','),')',sep='')

    print(query)
    res <- synapser::synTableQuery(query)$asDataFrame()%>%dplyr::select(-ROW_ID,-ROW_VERSION)
    colnames(res) <- c("ids","drugs")
    res}))

  return(res2)
}


#' \code{buildNetwork} Identifies drugs in a
#' @param drug.graph Tidied drug response
#' @keywords
#' @export
#' @examples
#' @return
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
#'
getDrugsFromGraph <-function(drug.graph){
  #the goal of this is to extract the drugs from the graph,
  #which should be the only nodes with an indegree of zero
  names(which(degree(drug.graph,mode="in")==0))

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
#' @keywords
#' @export
#' @examples
#' @return
runPcsfWithParams <- function(ppi,terminals, dummies, w=2, b=1, mu=5e-04,doRand=FALSE){

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
#' @keywords
#' @export
#' @return original network as well as p-values on each node
shuffleTerminalsAndRun <-function(ppi,terminals,dummies,w,b,mu,numShuffles){

}

#' \code{renameDrugIds} Remaps drug ids to drug names for view-ability
#' @param pcsf.res
#' @param dummies
#' @keywords
#' @export
#' @examples
#' @return
renameDrugIds <-function(pcsf.res,dummies){
  drug.inds<-which(V(pcsf.res)$name%in%dummies)
  V(pcsf.res)$type[drug.inds]<-'Compound'
  V(pcsf.res)$name[drug.inds]<-getDrugNames(V(pcsf.res)$name[drug.inds])[,2]
  pcsf.res

}
