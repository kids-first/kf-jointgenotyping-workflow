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
      --output $(inputs.output_filename)
inputs:
  tranches:
    type: File[]
    inputBinding:
      position: 1
      prefix: --input
      itemSeparator: ' --input '
  output_filename: string
outputs:
  output:
    type: File
    outputBinding:
      glob: $(inputs.output_filename)
