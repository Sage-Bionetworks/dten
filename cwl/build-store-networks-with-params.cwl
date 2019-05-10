label: build-store-networks-with-params
id: build-store-networks-with-params
cwlVersion: v1.0
class: Workflow

requirements:
  - class: ScatterFeatureRequirement
  - class: SubworkflowFeatureRequirement
  - class: InlineJavascriptRequirement

inputs:
  beta:
    type: double
  mu:
    type: double
  w:
    type: double
  protein-lists:
    type: File[]
  output-project-id:
    type: string
  output-folder-id:
    type: string
  synapse_config:
    type: File
  net-name:
    type: string

outputs:
   - id: network-file
     type: File[]
     outputSource: run-networks/network-file

steps:
  run-networks:
    in:
      beta: beta
      mu: mu
      w: w
      protein-list: protein-lists
      synapse_config: synapse_config
    scatter: [protein-list]
    scatterMethod: dotproduct
    run: steps/run-network-with-params.cwl
    out:
      [network-file]
 # make-name:
 #   in:
 #     beta: beta
 #     mu: mu
 #     w: w
 #     netpre: net-name
 #   run:
 #     steps/make-net-name.cwl
 #   out:
 #     [net-name]
  meta-analysis:
    in:
      input: run-networks/network-file
      project: output-project-id
      synapse_config: synapse_config
      output: net-name
    run: steps/run-meta-analysis.cwl
    out:
      [nodefile,termfile]
