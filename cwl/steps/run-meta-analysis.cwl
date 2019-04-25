label: run-network-with-params
id: run-network-with-params
cwlVersion: v1.0
class: CommandLineTool

baseCommand: ['Rscript','/usr/local/bin/metaNetworkComparisons.R']


requirements:
  - class: DockerRequirement
    dockerPull: sgosline/dten

inputs:
  input:
    type: File[]
    inputBinding:
      prefix: '-i'
  output:
    type: string
    inputBinding:
      prefix: '-o'

outputs:
  outfiles:
    type: File[]
    outputBinding:
      glob: "*tsv"
