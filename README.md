# Drug Target Expression Networks
A suite of tools designed to enable identification of drugs effective in a disease of interest based on gene expression data.

### Related Packages
Many packages are used by this workflow to enable proper assessment of the gene expressiond ata.

* [MetaViper](https://www.bioconductor.org/packages/release/bioc/html/viper.html): MetaViper is used to identify proteins of activity from gene expression data
* [Drug Target Explorer](https://www.synapse.org/#!Synapse:syn11672851): DTEx is used to identify protein-drug interactions
* [PCSF](https://github.com/sgosline/pcsf): Prize-collecting steiner forest package is used for network reduction and pathway enrichment

### Using DTEN
The DTEN scientific workflow comprises a series of steps that can be performed individually or in sequence. 

#### Formatted Data
We have built another workflow that aligns and annotates `fastq` files and uploads them to Synapse.
*TODO*: create workflow that combines aligned counts into tidieid data frame

#### Getting Proteins of interest
DTEN assumes that files are in a tidied data frame with the following headers:
| Header name | Description |
| --- | --- |
| gene| Name of gene, either `entrez` identifier or `hugo` |
| sample | some sample identifier |
| counts | quantification of counts |
| conditions | Conditions under which that sample applies |

#### Building networks and getting pathway enrichment
Once we have the proteins we can add them to networks

#### Storing results on Synapse

#### Selecting drugs and pathways across conditions

### Getting started
1. Install Docker
2. Install cwltool
3. Format your inputs in JSON format
4. cwl-runner `workflow-name.cwl` `inputfile.json'
