#!/usr/bin/env Rscript


##run meta-network comparisons
suppressPackageStartupMessages(require(optparse))
suppressPackageStartupMessages(require(dten))

getArgs<-function(){

  option_list <- list(
    make_option(c("-i", "--input"), dest='input',help='Comma-delimited list of RDS files containing PCSF and enrichment output'),
    make_option(c("-o", "--output"), default="test", dest='output',help = "Prefix to add to output files"),
    make_option(c('-p',"--project"),dest='project',default=NULL,help='Synapse id of project')
  )

  args=parse_args(OptionParser(option_list = option_list))

  return(args)
}

main<-function(){

  args<-getArgs()
  all.nets<-lapply(unlist(strsplit(args$input,split=',')),readRDS)
  print(paste("Loaded",length(all.nets),'networks'))

  summary<-dten::getNetSummaries(all.nets)
    write.table(summary$nodes,file=paste(args$output,'nodeOutput.tsv',sep=''),sep='\t')
    write.table(summary$terms,file=paste(args$output,'termOutput.tsv',sep=''),sep='\t')

    if(!is.null(args$project)){
      require(synapser)
      synapser::synLogin()
      node.tab<-synapser::synBuildTable(values=summary$nodes,parent=args$project,name=paste(args$output,'DTEN Node results'))
       term.tab<-synapser::synBuildTable(values=summary$terms,parent=args$project,name=paste(args$output,'DTEN Term results'))
       synapser::synStore(node.tab)
       synapser::synStore(term.tab)
    }
}

main()
