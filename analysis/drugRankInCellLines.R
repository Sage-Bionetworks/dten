
##drug rank vs. auc

require(synapser)
require(tidyverse)

synLogin()

###get cell line data
synId='syn17462699'
tab<-read.csv(synGet(synId)$path)%>%dplyr::rename(internal_id='DT_explorer_internal_id')

this.script='https://raw.githubusercontent.com/Sage-Bionetworks/dten/master/analysis/drugRankInCellLines.R'

syn.tab<-'syn17090820'
drug.map<-synTableQuery('SELECT distinct internal_id,std_name FROM syn17090819')$asDataFrame()

tab.with.id<-tab%>%left_join(drug.map,by='internal_id')

all.compounds<-unique(tab.with.id$std_name)
all.models<-unique(tab.with.id$model_name)
all.tumor.types<-unique(tab.with.id$symptom_name)
print(paste('Loaded',length(all.compounds),'compound response data over',length(all.models),'models'))


##these are the current DTEN results
path.syntable='syn18820885'
node.syntable='syn18820883'


###rank drugs by mean weigth in each condition, join with drug data
rank.drugs<-function(node.tab=node.syntable,comp.tab=tab.with.id){
  dtab<-synTableQuery(paste('select Condition,Node,NodeWeight,nodeType from',node.tab))$asDataFrame()
  
  res<-dtab%>%select(-c(ROW_ID,ROW_VERSION))%>%
    group_by(Condition,Node)%>%
    mutate(meanWeight=mean(NodeWeight))%>%
    mutate(rank=rank(meanWeight,ties.method='min'))%>%
    arrange(desc(meanWeight))%>%
    select(Condition,Node,nodeType,meanWeight,rank)%>%
    distinct()
  
  topGenes<-subset(res,nodeType=='Gene')
  topComps<-subset(res,nodeType=='Compound')
  
  tests=comp.tab%>%
    subset(response_type%in%c("AUC_Trapezoid","IC50_abs","IC50_rel"))%>%
      select(std_name,symptom_name,response_type,response)%>%unique()%>%rename(Node='std_name',TestedIn='symptom_name')
  topComps<-topComps%>%left_join(tests,by='Node')%>%subset(!is.na(TestedIn))

#  topComps$hasData=topComps$Node%in%tab.with.id$std_name
  return(topComps)
}

##plots the top compounds joined with the results in cell lines
plotRes<-function(compList,parentid='syn20503265'){
  compList$response[!is.finite(compList$response)]<-NA
  ggplot(subset(compList,response_type=='AUC_Trapezoid')%>%ungroup())+geom_point(aes(x=meanWeight,y=response,col=Condition,shape=TestedIn))+ggtitle('AUC of response in various cell lines')
  
  ggsave('aucRes.png')
  ggplot(subset(compList,response_type=='IC50_abs')%>%ungroup())+geom_point(aes(x=meanWeight,y=-log10(response),col=Condition,shape=TestedIn))+scale_y_log10()+ggtitle('Absolute IC50 of response in various cell lines')
  ggsave('ic50abs.png')
  
  ggplot(subset(compList,response_type=='IC50_rel')%>%ungroup())+geom_point(aes(x=meanWeight,y=-log10(response),col=Condition,shape=TestedIn))+scale_y_log10()+ggtitle('Relative IC50 of response in various cell lines')
  ggsave('ic50rel.png')
  
  for(f in c('aucRes.png','ic50abs.png','ic50rel.png'))
    synStore(File(f,parentId=parentid),used=c(node.syntable,synId,syn.tab),executed=this.script)

  
}

drug.rank<-rank.drugs()%>%filter(meanWeight>75)%>%select(Condition,Node)
#plotRes(drug.rank)
plotNetsByDrugInCondition(unique(drug.rank$Condition),unique(drug.rank$Node),node.syntable)

