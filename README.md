# Drug Target Expression Networks
A suite of tools designed to enable identification of drugs effective in a disease of interest based on gene expression data.

### Related Packages
Many packages are used by this workflow to enable proper assessment of the gene expressiond ata.

* [MetaViper](https://www.bioconductor.org/packages/release/bioc/html/viper.html): MetaViper is used to identify proteins of activity from gene expression data
* [Drug Target Explorer](https://www.synapse.org/#!Synapse:syn11672851): DTEx is used to identify protein-drug interactions
* [PCSF](https://github.com/sgosline/pcsf): Prize-collecting steiner forest package is used for network reduction and pathway enrichment

### Using DTEN
This project is written as a workflow, which requires Docker and a workflow execution engine that can run CWL

#### Getting environment ready
1. Install Docker
2. Install cwltool
3. Format your inputs in JSON format
4. cwl-runner `workflow-name.cwl` `inputfile.json'

#### Input Files
The input files required for this workflow are tidied gene expression datasets. 

#### Output Files
The output of these files are `iGraph`-formatted networks. 
