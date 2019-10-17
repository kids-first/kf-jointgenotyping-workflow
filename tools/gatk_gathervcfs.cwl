cwlVersion: v1.0
class: CommandLineTool
id: gatk_gathervcfs
requirements:
  - class: DockerRequirement
    dockerPull: 'kfdrc/gatk:4.0.12.0'
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: 10000
    coresMin: 5
hints:
  - class: 'sbg:AWSInstanceType'
    value: r4.2xlarge;ebs-gp2;500
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      /gatk --java-options "-Xmx6g -Xms6g"
      GatherVcfsCloud
      --ignore-safety-checks
      --gather-type BLOCK
      --output sites_only.vcf.gz
  - position: 2
    shellQuote: false
    valueFrom: >-
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
