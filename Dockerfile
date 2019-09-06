FROM rocker/tidyverse:3.5.3

RUN apt-get install -y net-tools
RUN apt-get update -qq && apt-get -y install libffi-dev

RUN Rscript -e "install.packages('devtools')"
RUN Rscript -e "install.packages('optparse')"
RUN Rscript -e "install.packages('synapser', repos=c('http://ran.synapse.org', 'http://cran.fhcrc.org'))"
RUN Rscript -e "install.packages('BiocManager')"
RUN Rscript -e "BiocManager::install('viper')" \
  -e "BiocManager::install('aracne.networks')" \
  -e "BiocManager::install('topGO')" \ 
  -e "BiocManager::install('org.Hs.eg.db')" 

RUN Rscript -e "devtools::install_github('sgosline/PCSF')"

COPY . dten
WORKDIR dten

RUN Rscript -e 'devtools::install_deps(pkg = ".", dependencies=TRUE,threads = getOption("Ncpus",1))'
RUN R CMD INSTALL .

COPY bin/*.R /usr/local/bin/
COPY analysis/*.R /usr/local/bin/

RUN chmod a+x /usr/local/bin/*.R
