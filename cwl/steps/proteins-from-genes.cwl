label: proteins-from-genes
id: proteins-from-genes
cwlVersion: v1.0
class: CommandLineTool

baseCommand: ['Rscript','/usr/local/bin/runMetaViper.R']

requirements:
  - class: DockerRequirement
    dockerPull: sgosline/dten
  - class: InlineJavascriptRequirement

inputs:
  gene-data:
    type: File
    inputBinding:
      prefix: '-i'
  id-type:
    type: string
    inputBinding:
      prefix: '-d'
  condition:
    type: string?
    inputBinding:
      prefix: '-c'


outputs:
  protein-lists:
    type:
       type: array
       items: File
    outputBinding:
       glob: "*.tsv"
