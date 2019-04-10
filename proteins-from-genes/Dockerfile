FROM rocker/tidyverse

RUN apt-get install -y net-tools
RUN apt-get update -qq

RUN Rscript -e "install.packages('argparse')"
RUN Rscript -e "install.packages('devtools')"
RUN Rscript -e "install.packages('biomaRt')"
RUN Rscript -e "source('http://bioconductor.org/biocLite.R')" -e "biocLite('viper')" -e "biocLite('topGO')"
RUN Rscript -e "source('http://bioconductor.org/biocLite.R')" -e "biocLite('org.Hs.eg.db')"


COPY bin/runMetaViperOnTable.R /usr/local/bin/
RUN chmod a+x /usr/local/bin/runMetaViperOnTable.R
