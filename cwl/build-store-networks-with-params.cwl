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
      synapse_config: synapse_config
      output-folder-id: output-folder-id
      protein-list: protein-lists
      condition: condition-list
    scatter: [protein-list, condition]
    scatterMethod: dotproduct
    run: network-and-store.cwl
    out:
      [network-file]
  meta-analysis:
    in:
      net-file-list: run-networks/network-file
      output-project-id: output-project-id
    run: run-meta-analysis.cwl
    out:
      [gene-table,path-table]
  store-meta-analysis:
    in:
      gene-tab: meta-analysis/gene-table
      path-tab: meta-analysis/path-table
      synapse_config: synapse_config
      output-project-id: output-project-id
    run: steps/store-tables.cwl
    out:
      []
