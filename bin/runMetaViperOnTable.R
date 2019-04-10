##run and store metaviper on tcga data

library(viper)
library(tidyverse)
library(aracne.networks)
require(biomaRt)
library(org.Hs.eg.db)

args<-commandArgs(trailingOnly=TRUE)


if(length(args)>0){

  tab<-args[1]
id.type=args[2]
condition=args[3]

tidied.df<-read.csv(tab)

req.names=c('counts','gene','sample','conditions')
#check names
if(length(setdiff(req.names,names(tidied.df)))>0){
  print(paste("Data frame does not have required header:",paste(req.names,collapse=',')))
  q(save='no')
}
}else if(length(args)<3){
  
  print('Requires file name, id-type (entrez or hugo), and condition of interest as input')
 # q('no')
}


#
#' \code{getViperForCondition} takes a matrix from viper and condition of interest aind computes differential reg
#' @param condition set of columns
#' @keywords
#' @export
#' @examples
#' @return list
getViperForCondition <- function(v.res,condition,pvalthresh=0.05,useEntrez=TRUE,p.corr=TRUE){

  #TODO: increase number of permuations! this is too low!!
   sig <-viper::rowTtest(v.res[,condition],v.res[,-condition])$statistic
   pval<-viper::rowTtest(v.res[,condition],v.res[,-condition])$p.value
   if(p.corr){
     pval <- p.adjust(pval)
   }
  sig.ps<-which(pval<pvalthresh)
  ret<-sig[sig.ps]
  names(ret)<-rownames(v.res)[sig.ps]

  if(useEntrez){
      #we have to map back to HUGO
      x <- org.Hs.egSYMBOL2EG
      # Get the entrez gene identifiers that are mapped to a gene symbol
      mapped_genes <- AnnotationDbi::mappedkeys(x)
      # Convert to a list
      xx <- AnnotationDbi::as.list(x[mapped_genes])
      inds=match(names(ret),xx)
      names(ret)<-names(xx)[inds]
  }

    return(ret)
    }

getNets<-function(){
                                        #get aracne networks
    net.names <- data(package="aracne.networks")$results[, "Item"]
    all.networks <- lapply(net.names,function(x) get(x))
    names(all.networks) <- net.names
    return(all.networks)
}


getGeneEntrezMapping<-function(genes){

    mart <- useMart('ensembl',dataset='hsapiens_gene_ensembl')

    entrez_list <- getBM(filters ="hgnc_symbol",
                         attributes = c("hgnc_symbol", "entrezgene"),
                         values =genes, mart = mart)%>%rename(hgnc_symbol='gene')
    return(entrez_list)
}



getProteinsFromGenesCondition<-function(tidied.df,condition,idtype){
    if(tolower(idtype)=='entrez')
        tidied.df<-rename(tidied.df,entrezgene='gene')
    else
        tidied.df<-tidied.df%>%left_join(getGeneEntrezMapping(unique(tidied.df$gene)),by='gene')
    
    combined.mat<-reshape2::acast(tidied.df,entrezgene~sample,value.var="counts",fun.aggregate=function(x) mean(x,na.rm=T))

    res <- viper(combined.mat,getNets())
    vals=tidied.df$sample[which(tidied.df$condition==condition)]

    cond<-getViperForCondition(res,which(colnames(res)%in%vals))
    write.table(data.frame(gene=names(cond),vals=unlist(cond)),file="",row.names=F,sep='\t')

}

getProteinsFromGenesCondition(tidied.df,condition,id.type)
