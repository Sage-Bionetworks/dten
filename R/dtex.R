##library(devtools)
##install_github("sgosline/PCSF",username='sgosline')


#' \code{loadDrugGraph} Identifies drugs in a
#' @keywords
#' @export
#' @examples
#' @return
#'
loadDrugGraph <- function(minQuant=2){
require(synapser)
  ##load drug-target networ
  synLogin()
  drug.graph<-readRDS(synGet('syn11802194')$path)
  edges<-intersect(which(!is.na(E(drug.graph)$n_qualitative)),which(E(drug.graph)$n_quantitative>2))
  return(drug.graph)
}


#' \code{getDrugs} Identifies drugs in a
#' @param drug.graph
#' @keywords
#' @export
#' @examples
#' @return list of node names
#'
getDrugs <-function(drug.graph){
        drugs<-names(which(degree(drug.graph,mode="out")>0))
    drugs
}

#' \code{getDrugNodes} Identifies drugs in a
#' @param drug.graph
#' @keywords
#' @export
#' @examples
#' @return list of nodes
#'
getDrugNodes <-function(drug.graph){
  drugs<-V(drug.graph)[which(degree(drug.graph,mode="out")>0)]
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
