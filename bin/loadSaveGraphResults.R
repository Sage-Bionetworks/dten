#!/usr/bin/env Rscript
library(synapser)
require(optparse)

getArgs<-function(){

  option_list <- list(
    make_option(c("-i", "--input"), dest='input',help='R data file comprised of dten output'),
    make_option(c("-s", "--synapseid"), default="testprots.tsv", dest='output',help = "Prefix to add to output files"),
    make_option(c('-c','--configfile'),default='.synapseConfig',dest='configfile',help='Path to synapse config'),
    make_option(c('-c','--condition'),dest='condition',help='Condition of interest to find differentially regulated proteins')
  )

  args=parse_args(OptionParser(option_list = option_list))

  return(args)
}

main<-function(){
    args<-getArgs()
}

main()
