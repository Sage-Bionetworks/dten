require(optparse)




getArgs<-function(){

    option_list<-list(
        make_option(c('-f','--folderid'),dest='folder',help='Synapse id of folder containing files'),
        make_option(c('-n','--number'),dest='num',help='Number to sample',default=10),
        make_option(c('-v','--fileview'),dest='fv',help='Fileview to query'))

    args=parse_args(OptionParser(option_list = option_list))
    return(args)
}

main<-function(){
    args<-getArgs()
    require(synapser)
    synLogin()

    sample(x=synapser::synTableQuery(paste0('select id from ',args$fv,' where parentId = \'',args$folder,'\''))$asDataFrame()$id,args$num)

}

main()
