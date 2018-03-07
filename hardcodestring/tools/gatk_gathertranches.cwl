cwlVersion: v1.0
class: CommandLineTool
id: gatk_gathertranches
requirements:
  - class: DockerRequirement
    dockerPull: 'kfdrc/gatk:4.beta.5'
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: 7000
    coresMin: 2
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      /gatk/gatk-launch --javaOptions "-Xmx6g -Xms6g"
      GatherTranches
      --output snps.gathered.tranches
inputs:
  tranches:
    type: File[]
    inputBinding:
      position: 1
      prefix: --input
      itemSeparator: ' --input '
outputs:
  output:
    type: File
    outputBinding:
      glob: snps.gathered.tranches
