cwlVersion: v1.0
class: CommandLineTool
id: gatk_gathertranches
requirements:
  - class: DockerRequirement
    dockerPull: 'kfdrc/gatk:4.beta.5'
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: 7000
    coresMin: 2
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      /gatk-launch --javaOptions "-Xmx6g -Xms6g"
      GatherTranches
      --output snps.gathered.tranches
inputs:
  tranches:
    type:
      type: array
      items: File
      inputBinding:
        prefix: --input
    inputBinding:
      position: 1
outputs:
  output:
    type: File
    outputBinding:
      glob: snps.gathered.tranches
