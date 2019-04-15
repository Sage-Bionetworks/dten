source("metaviper.R")
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

getProteinsFromGenesCondition(tidied.df,condition,id.type)
