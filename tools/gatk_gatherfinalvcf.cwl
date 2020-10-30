cwlVersion: v1.0
class: CommandLineTool
id: gatk_gathervcfs
requirements:
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/gatk:4.0.12.0'
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
      /gatk --java-options "-Xmx6g -Xms6g"
      GatherVcfsCloud
      --ignore-safety-checks
      --gather-type BLOCK
      --output $(inputs.output_basename + '.vcf.gz')
  - position: 2
    shellQuote: false
    valueFrom: >-
      && /gatk IndexFeatureFile -F $(inputs.output_basename + '.vcf.gz')
inputs:
  input_vcfs:
    type:
      type: array
      items: File
      inputBinding:
        prefix: -I
    inputBinding:
      position: 1
  output_basename: string
outputs:
  output:
    type: File
    outputBinding:
      glob: $(inputs.output_basename + '.vcf.gz')
    secondaryFiles: [.tbi]
