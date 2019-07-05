cwlVersion: v1.0
class: CommandLineTool
label: get-mv-samples
id: get-mv-samples

baseCommand: ['Rscript','/usr/local/bin/subSampleTumorTypes.R']

requirements:
  - class: DockerRequirement
    dockerPull: sgosline/dten
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
     - entry: $(inputs.synapse_config)

inputs:
  synapse_config:
    type: File
  parent-folder:
    type: string
    inputBinding:
      prefix: "--folderid"
  fileview:
    type: string
    inputBinding:
      prefix: "--fileview"
  num-samps:
    type: string
    inputBinding:
      prefix: "--n"

outputs:
  synids:
    type: string[]
