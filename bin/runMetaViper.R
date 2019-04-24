#!/usr/bin/env Rscript

suppressPackageStartupMessages(require(optparse))
suppressPackageStartupMessages(require(dten))

getArgs<-function(){

  option_list <- list(
    make_option(c("-i", "--input"), dest='input',help='Tab-delimited file of expression values in tidied format with the following column names: counts,gene,sample,conditions'),
    make_option(c("-o", "--output"), default="testprots.tsv", dest='output',help = "Prefix to add to output files"),
    make_option(c('-d','--idtype'),default='entrez',dest='idtype',help='Type of gene identifier'),
    make_option(c('-c','--condition'),dest='condition',default=NULL,help='Condition of interest to find differentially regulated proteins')
  )

  args=parse_args(OptionParser(option_list = option_list))

  return(args)
}

main<-function(){
  args<-getArgs()
  if(args$input=="")
    tab<-system.file('glioma_dataset.csv',package='dten')
  else
    tab<-args$input

  ext <- rev(unlist(strsplit(basename(tab),split='.',fixed=T)))[1]

#  if(ext=='gz')
#    tab<-gzfile(tab,'rt')
  tidied.df<-read.table(tab,sep=',',header=T)

  req.names=c('counts','gene','sample','conditions')
  #check names
  if(length(setdiff(req.names,names(tidied.df)))>0){
    print(paste("Data frame does not have required header:",paste(req.names,collapse=',')))

  print('Requires file name, id-type (entrez or hugo), and condition of interest as input')
 # q('no')
  }
  cond=args$condition
  if(is.null(cond))
      cond<-unique(tidied.df$conditions)

  lapply(cond,function(co){
          res<-dten::getProteinsFromGenesCondition(tidied.df,co,args$idtype)
          write.table(res,file=paste(gsub(' ','',co),args$output,sep=''),sep='\t',quote=F,row.names=F)

  })
   write.table(cond,row.names=F,col.names=F,quote=F,file='conditions.txt')

}

main()
