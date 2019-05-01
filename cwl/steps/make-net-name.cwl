label: make-net-name
id: make-net-name
cwlVersion: v1.0
class: CommandLineTool

requirements:
  InlineJavascriptRequirement: {}

inputs:
  beta:
    type: double
  mu:
    type: double
  w:
    type: double
  netpre:
    type: string

outputs:
  net-name:
    type: string
    outputBinding:
      outputEval: |
        ${
        inputs.netpre+'beta'+inputs.beta +'mu'+inputs.mu+'w'+inputs.w;
        }
