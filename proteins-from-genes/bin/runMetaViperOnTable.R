##run and store metaviper on tcga data

library(viper)
library(tidyverse)
library(aracne.networks)


args<-commandArgs(trailingOnly=TRUE)
print(args)

if(length(args)!=2){
    print('Requires file name and id-type (entrez or hugo) as input')
    q('no')
}

tab<-args[1]
id.type=args[2]

tidied.df<-read.csv(tab)

req.names=c('counts','gene','sample')
#check names
if(length(setdiff(req.names,names(tidied.df)))>0){
    print(paste("Data frame does not have required header:",paste(req.names,collapse=',')))
    q(save='no')
    }

#get aracne networks
net.names <- data(package="aracne.networks")$results[, "Item"]
all.networks <- lapply(net.names,function(x) get(x))
names(all.networks) <- net.names

require(biomaRt)
mart <- useMart('ensembl',dataset='hsapiens_gene_ensembl')

##check id name to figure out hugo/enrez issue
if(tolower(idtype)=='entrez'){
    genes<-unique(tided.df$gene)

    entrez_list <- getBM(filters ="entrezgene",
  attributes = c("hgnc_symbol", "entrezgene"),
  values =genes, mart = mart)
    }
else if(tolower(idtype)=='hugo'){

entrez_list <- getBM(filters ="hgnc_symbol",
  attributes = c("hgnc_symbol", "entrezgene"),
  values =genes, mart = mart)
        }



combined.mat=reshape2::acast(tided.df,gene~sample,value.var="counts",fun.aggregate=function(x) mean(x,na.rm=T))
res <- viper(combined.mat all.networks)

##now re-shape to be tidy again and store!
rr<-tidyr::gather(data.frame(res,entrezgene=rownames(res)),key=id,value=viper,-entrezgene)%>%tidyr::unite('entre_syn',entrezgene,id)

#now paste the symbol_synId and then join
vip.res<-rr%>%
  inner_join(dplyr::select(entrez_list,-c(totalCounts,zScore,X)),by='entre_syn')%>%
  separate(entre_syn,c('entrez','id'))
