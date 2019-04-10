FROM rocker/tidyverse

RUN apt-get update
RUN Rscript -e "install.packages('argparse')"
RUN Rscript -e "install.packages('biomaRt')

COPY bin/runMetaViperOnTable.R /usr/local/bin/
RUN chmod a+x /usr/local/bin/runMetaViperOnTable.RUN
