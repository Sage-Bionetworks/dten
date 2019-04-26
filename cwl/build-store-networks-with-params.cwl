label: build-store-networks-with-params
id: build-store-networks-with-params
cwlVersion: v1.0
class: Workflow

requirements:
  - class: ScatterFeatureRequirement
  - class: SubworkflowFeatureRequirement

inputs:
  beta:
    type: double
  mu:
    type: double
  w:
    type: double
  protein-lists:
    type: File[]
  condition-list:
    type: string[]
  output-project-id:
    type: string
  output-folder-id:
    type: string
  synapse_config:
    type: File

outputs:
   network-file:
     type: File[]
     outputSource: run-networks/network-file

steps:
  run-networks:
    in:
      beta: beta
      mu: mu
      w: w
      protein-list: protein-lists
      condition: condition-list
      synapse_config: synapse_config
    scatter: [protein-list, condition]
    scatterMethod: dotproduct
    run: steps/run-network-with-params.cwl
    out:
      [network-file]
  meta-analysis:
    in:
      input: run-networks/network-file
    run: steps/run-meta-analysis.cwl
    out:
      [nodefile,termfile]
  store-meta-analysis:
    in:
      nodeTable: meta-analysis/nodefile
      termTable: meta-analysis/termfile
      synapse_config: synapse_config
      output-project-id: output-project-id
    run: steps/store-tables.cwl
    out:
      []
