FROM rocker/tidyverse

RUN apt-get install -y net-tools
RUN apt-get update -qq && apt-get -y install libffi-dev

RUN Rscript -e "install.packages('argparse')"
RUN Rscript -e "install.packages('devtools')"
RUN Rscript -e "install.packages('biomaRt')"
RUN Rscript -e "install.packages('synapser', repos=c('http://ran.synapse.org', 'http://cran.fhcrc.org'))"

RUN Rscript -e "source('http://bioconductor.org/biocLite.R')" -e "biocLite('viper')" -e "biocLite('topGO')"  -e "biocLite('org.Hs.eg.db')"

RUN Rscript -e "devtools::install_github('sgosline/PCSF')"


COPY bin/runMetaViperOnTable.R /usr/local/bin/
COPY bin/runNetworkFromGenes.R /usr/local/bin/
COPY bin/runPCSFWithDTEnetwork.R /usr/local/bin/

RUN chmod a+x /usr/local/bin/runMetaViperOnTable.R
RUN chmod a+x /usr/local/bin/runNetworkFromGenes.R
RUN chmod a+x /usr/local/bin/runPCSFWithDTEnetwork.R
