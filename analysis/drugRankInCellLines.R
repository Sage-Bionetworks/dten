
##drug rank vs. auc

require(synapser)

synLogin()
synId='syn17462699'
require(tidyverse)
tab<-read.csv(synGet(synId)$path)%>%dplyr::rename(internal_id='DT_explorer_internal_id')


syn.tab<-'syn17090820'
drug.map<-synTableQuery('SELECT distinct internal_id,std_name FROM syn17090819')$asDataFrame()

tab.with.id<-tab%>%left_join(drug.map,by='internal_id')

all.compounds<-unique(tab.with.id$std_name)
all.models<-unique(tab.with.id$model_name)
all.tumor.types<-unique(tab.with.id$symptom_name)
print(paste('Loaded',length(all.compounds),'compound response data over',length(all.models),'models'))


path.syntable='syn18820885'
node.syntable='syn18820883'
##fig 4
rank.drugs<-function(){
  dtab<-synTableQuery(paste('select Condition,Node,NodeWeight,nodeType from',node.syntable))$asDataFrame()
  
  require(dplyr)
  res<-dtab%>%select(-c(ROW_ID,ROW_VERSION))%>%
    group_by(Condition,Node)%>%
    mutate(meanWeight=mean(NodeWeight))%>%
    mutate(rank=rank(meanWeight,ties.method='min'))%>%
    arrange(desc(meanWeight))%>%
    select(Condition,Node,nodeType,meanWeight,rank)%>%
    distinct()
  
  topGenes<-subset(res,nodeType=='Gene')
  topComps<-subset(res,nodeType=='Compound')
  return(topComps)
}


compare.drugs.to.cell.lines<-function(drug.ranks,cell.lines){
    
  synTableQuery(paste('select * from',syn.tab,'where common_name ='))
  
}
