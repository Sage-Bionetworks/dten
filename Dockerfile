FROM rocker/tidyverse

RUN apt-get install -y net-tools
RUN apt-get update -qq && apt-get -y install libffi-dev

RUN Rscript -e "install.packages('devtools')"
RUN Rscript -e "install.packages('synapser', repos=c('http://ran.synapse.org', 'http://cran.fhcrc.org'))"
RUN Rscript -e "source('http://bioconductor.org/biocLite.R')" -e "biocLite('viper')" -e "biocLite('topGO')"  -e "biocLite('org.Hs.eg.db')"
RUN Rscript -e "devtools::install_github('sgosline/PCSF')"

COPY . dten
WORKDIR dten

RUN Rscript -e 'devtools::install_deps(pkg = ".", dependencies=TRUE,threads = getOption("Ncpus",1))'
RUN R CMD INSTALL .

COPY bin/loadSaveGraphResults.R /usr/local/bin/
COPY bin/runMetaViper.R /usr/local/bin/
COPY bin/runNetworkFromGenes.R /usr/local/bin/

RUN chmod a+x /usr/local/bin/runMetaViper.R
RUN chmod a+x /usr/local/bin/runNetworkFromGenes.R
RUN chmod a+x /usr/local/bin/loadSaveGraphResults.R
