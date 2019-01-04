cwlVersion: v1.0
class: CommandLineTool
id: gatk_gathervcfs
requirements:
  - class: DockerRequirement
    dockerPull: 'migbro/gatk:4.0.12.0'
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: 10000
    coresMin: 5
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      /gatk --java-options "-Xmx6g -Xms6g"
      GatherVcfsCloud
      --ignore-safety-checks
      --gather-type BLOCK
      --output sites_only_unsorted.vcf.gz
  - position: 2
    shellQuote: false
    valueFrom: >-
      && /gatk SortVcf -I sites_only_unsorted.vcf.gz -O sites_only.vcf.gz
      && /gatk IndexFeatureFile -F sites_only.vcf.gz
inputs:
  input_vcfs:
    type:
      type: array
      items: File
      inputBinding:
        prefix: -I
    inputBinding:
      position: 1
outputs:
  output:
    type: File
    outputBinding:
      glob: sites_only.vcf.gz
    secondaryFiles: [.tbi]
