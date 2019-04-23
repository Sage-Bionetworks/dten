label: proteins-from-genes
id: proteins-from-genes
cwlVersion: v1.0
class: CommandLineTool

baseCommmand: ['Rscript','/usr/local/bin/runMetaViper.R']

requirements:
  - class: DockerRequirement
    dockerPull: sgosline/dten

in:
  gene-data:
    type: File
    inputBinding:
      prefix: '--i'
  id-type:
    type: string
    inputBinding:
      prefix: '--d'
  condition:
    type: string
    inputBinding:
      prefix: '--c'

out:
  proteins:
    type: File[]
    outputBinding:
      glob: "*.tsv"
  conditions:
    type: stdout
