label: run-dten
id: run-dten
cwlVersion: v1.0
class: Workflow

inputs:
  input-file-id:
    type: string
  synapse-config:
    type: File
  gene-id-type:
    type: string
  beta-params:
    type: string[]
  mu-params:
    type: string[]
  w-params:
    type: string[]
  output-parent-id:
    type: string
  output-project-id:
    type: string

outputs:
  []

requirements:
  - class: ScatterFeatureRequirement
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement

steps:
  download-file:
    run: https://raw.githubusercontent.com/Sage-Bionetworks/synapse-client-cwl-tools/master/synapse-get-tool.cwl
    in:
      synapseid: input-file-id
      synapse_config: synapse_config
    out: [filepath]
  get-prots:
    run: steps/proteins-from-genes.cwl
    in:
      gene-data: download-file/filepath
      id-type: gene-id-type
    out:
      proteins:
        type: File[]
      conditions:
        type: string[]
  build-networks:
    scatter:
      - beta
      - mu
      - w
    scatterMethod: flat_crossprojuct
    run: steps/build-store-networks-with-params.cwl
    in:
      beta:
        beta-params
      mu:
        mu-params
      w:
        w-params
      proteins-lists:
        get-proteins/proteins
      condition-list:
        get-proteins/conditions
      output-project-id:
        output-project-id
      output-folder-id:
        output-folder-out
   out:
     network-files:
       type: File[]
