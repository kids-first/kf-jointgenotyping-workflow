cwlVersion: v1.0
class: CommandLineTool
id: gatk_gathervcfs
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
      GatherVcfs
      --ignoreSafetyChecks
      --gatherType BLOCK
      --output $(inputs.output_vcf_basename + '.vcf.gz')
inputs:
  input_vcfs:
    type:
      type: array
      items: File
      inputBinding:
        prefix: -I
    inputBinding:
      position: 1
  output_vcf_basename: string
outputs:
  output:
    type: File
    outputBinding:
      glob: *.vcf.gz
