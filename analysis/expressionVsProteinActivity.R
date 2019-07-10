##plot inter-sample metaviper distances and compare to gene expression distances
#grabs expression tidied dataset and computes distance between samples within condition

require(synapser)
synLogin()
require(tidyverse)
expr.id='syn18523913'

run.viper.tidy<-function(tab){
  library(dten)
  mat<-tab%>%dplyr::select(sample,counts,gene)#%>%unique()%>%spread(key=gene,value=counts)
  res<-reshape2::acast(mat,gene ~ sample,value.var='counts',fun.aggregate=mean)
#  rownames(mat)<-mat$gene
#  mat<-mat%>%select(-gene)
  all.nets<-dten::getNets()
  map<-dten::getGeneEntrezMapping(rownames(res))
  rownames(res)<-map$entrezgene[match(rownames(res),map$gene)]
  vres<-viper(res,all.nets)
  rownames(vres)<-map$gene[match(rownames(vres),map$entrezgene)]
  samps<-tab%>%dplyr::select(conditions,sample)%>%distinct()
  full.res<-data.frame(vres,gene=rownames(vres),check.names=F)

  rtab<-full.res%>%gather(key=sample,value=counts,-gene)%>%left_join(samps,by='sample')
  rtab
}

##fig 2
within.condition.correlation<-function(tab){
  #get mean distance between samples in a matrix
  conds=setdiff(as.character(unique(tab$conditions)),NA)

  cors=do.call(rbind,lapply(conds,function(cond){
    cvals=subset(tab,conditions==cond)%>%
      filter(!is.na(gene))%>%
        dplyr::select(sample,counts,gene)%>%
        spread(key=sample,value=counts)%>%
        dplyr::select(-gene)%>%
        cor(use='pairwise.complete.obs')
    dvals<-unique(unlist(as.dist(cvals)))
    data.frame(condition=rep(cond,length(dvals)),correlation=dvals)
  }))
  cors
}


across.condition.correlation<-function(tab){
  
}

cross.condition.correlation<-function(tab){
  conds=setdiff(as.character(unique(tab$conditions)),NA)
  
  vals<-filter(tab,!is.na(gene))%>%
    dplyr::select(sample,counts,gene)%>%
    reshape2::acast(gene~sample,value.var='counts',fun.aggregate=mean)
  samps<-tab%>%dplyr::select(sample,conditions)%>%unique()
  
  cors=do.call(rbind,lapply(conds,function(cond){
    print(cond)
    cvals=vals[,which(colnames(vals)%in%samps$sample[which(samps$conditions==cond)])]
    ovals=vals[,which(!colnames(vals)%in%samps$sample[which(samps$conditions==cond)])]
    
       cors<-apply(cvals,2,function(x)
      apply(ovals,2,function(y)
        cor(x,y,use='pairwise.complete.obs')))
    
    dvals<-unique(unlist(as.dist(cors)))
    data.frame(condition=rep(cond,length(dvals)),correlation=dvals)
  }))
  cors 
}


tab<-read.csv(synGet(expr.id)$path)

ecors<-within.condition.correlation(tab)
##lets get the 6169 most variable genes
rtab<-run.viper.tidy(tab)
mcors<-within.condition.correlation(rtab)

etcors<-cross.condition.correlation(tab)
mtcors<-cross.condition.correlation(rtab)

##now plot the differences
require(ggplot2)
full.res<-rbind(data.frame(ecors,method='expression within condition'),
    data.frame(mcors,method='metaviper within condition'),
    data.frame(etcors,method='expression across condition'),
  data.frame(mtcors,method='metaviper across condition'))

ggplot(full.res)+geom_boxplot(aes(x=condition,y=correlation,col=method))+ggtitle("Sample correlation within various conditions")+theme(axis.text.x = element_text(angle = 45, hjust = 1))


require(ggplot2)
full.res<-rbind(data.frame(ecors,method='expression within condition'),
  data.frame(mcors,method='metaviper within condition'))

ggplot(full.res)+geom_boxplot(aes(x=condition,y=correlation,col=method))+ggtitle("Sample correlation within various conditions")+theme(axis.text.x = element_text(angle = 45, hjust = 1))
