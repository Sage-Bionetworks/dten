

#' \code{getViperForCondition} takes a matrix from viper and condition of interest aind computes differential reg
#' @param condition set of columns
#' @keywords
#' @export
#' @examples
#' @import viper
#' @import org.Hs.eg.db
#' @return list
getViperForCondition <- function(v.res,condition,pvalthresh=0.05,useEntrez=TRUE,p.corr=TRUE){
  library(viper)
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

#' @import aracne.networks
getNets<-function(){
    require(aracne.networks)                        
                #get aracne networks
    net.names <- data(package="aracne.networks")$results[, "Item"]
    all.networks <- lapply(net.names,function(x) get(x))
    names(all.networks) <- net.names
    return(all.networks)
}


#' @import biomaRt
#' @export
getGeneEntrezMapping<-function(genes){
  #
  library(biomaRt)
    mart <- useMart('ensembl',dataset='hsapiens_gene_ensembl')

    entrez_list <- getBM(filters ="hgnc_symbol",
                         attributes = c("hgnc_symbol", "entrezgene"),
                         values =genes, mart = mart)%>%rename(hgnc_symbol='gene')
    return(entrez_list)
}


#' @import dplyr reshape2
#' @export 
getProteinsFromGenesCondition<-function(tidied.df,condition,idtype){
  require(dplyr)
  require(reshape2)
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
