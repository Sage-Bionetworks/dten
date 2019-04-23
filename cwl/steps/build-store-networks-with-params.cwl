label: build-store-networks-with-params
id: build-store-networks-with-params
cwlVersion: v1.0
class: Workflow

requirements:
  - class: ScatterFeatureRequirement

inputs:
  beta:
    type: double
  mu:
    type: double
  w:
    type: double
  protein-lists:
    type: File[]
  conditions:
    type: string[]

steps:
  run-networks:
    in:
      beta: beta
      mu: mu
      w: w
      protein-list:
        protein-lists
      condition:
        conditions
    scatter:
      - protein-list
      - condition
    scatterMethod: dotproduct
    run: run-network-with-params.cwl
    out:
      network:
        type: File
