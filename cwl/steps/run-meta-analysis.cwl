label: run-network-with-params
id: run-network-with-params
cwlVersion: v1.0
class: CommandLindTool

baseCommand: ['Rscript','/usr/local/bin/metaNetworkComparisons.R']


requirements:
  - class: DockerRequirement
    dockerPull: sgosline/dten

in:
  input:
    type: File[]
    inputBinding:
      prefix: '-i'
out:
  []
