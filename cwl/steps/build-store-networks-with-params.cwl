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
    scatter: [protein-list, condition]
    scatterMethod: dotproduct
    run: run-network-with-params.cwl
    out:
      [network-file]
