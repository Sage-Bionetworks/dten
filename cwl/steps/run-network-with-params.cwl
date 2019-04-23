label: run-network-with-params
id: run-network-with-params
cwlVersion: v1.0
class: CommandLindTool

baseCommand: ['Rscript','/usr/local/bin/runNetworksFromGenes.R']


requirements:
  - class: DockerRequirement
    dockerPull: sgosline/dten

in:
  mu:
    type: double
    inputBinding:
      prefix: '-m'
  beta:
    type: double
    inputBinding:
      prefix: '-b'
  w:
    type: double
    inputBinding:
      prefix: '-w'
  protein-list:
    type: File
    inputBinding:
      prefix: '-i'
  condition:
    type: string
    inputBinding:
      prefix: '-c'

out:
  network-file:
    outputBinding:
      glob: "*.rds"
