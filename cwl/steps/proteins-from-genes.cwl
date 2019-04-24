label: proteins-from-genes
id: proteins-from-genes
cwlVersion: v1.0
class: CommandLineTool

baseCommand: ['Rscript','/usr/local/bin/runMetaViper.R']

requirements:
  - class: DockerRequirement
    dockerPull: sgosline/dten
  - class: InlineJavascriptRequirement

stdout: out.txt

inputs:
  gene-data:
    type: File
    inputBinding:
      prefix: '-i'
  id-type:
    type: string
    inputBinding:
      prefix: '-d'


outputs:
  protein-lists:
    type:
       type: array
       items: File
    outputBinding:
       glob: "*.tsv"
  conditions:
    type: string[]
    outputBinding:
      glob: "*.txt"
      loadContents: true
      outputEval: $(String(self[0].contents))
