cwlVersion: v1.0
class: CommandLineTool
id: gatk_gathervcfs
requirements:
  - class: DockerRequirement
    dockerPull: 'kfdrc/gatk:4.0.5.2'
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
      /gatk --javaOptions "-Xmx6g -Xms6g"
      GatherVcfs
      --VALIDATION_STRINGENCY SILENT
      --OUTPUT $(inputs.output_vcf_name)
inputs:
  input_vcfs:
    type:
      type: array
      items: File
      inputBinding:
        prefix: -I
    inputBinding:
      position: 1
  output_vcf_name: string
outputs:
  output:
    type: File
    outputBinding:
      glob: $(inputs.output_vcf_name)
