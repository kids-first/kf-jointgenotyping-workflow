cwlVersion: v1.0
class: CommandLineTool
id: gatk_gathervcfscloud
requirements:
  - class: DockerRequirement
    dockerPull: 'kfdrc/gatk:4.beta.6-tabix-m'
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: 7000
    coresMin: 2
hints:
  - class: 'sbg:AWSInstanceType'
    value: r4.2xlarge;ebs-gp2;500
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      /gatk/gatk-launch --javaOptions "-Xmx6g -Xms6g"
      GatherVcfsCloud
      --ignoreSafetyChecks
      --gatherType BLOCK
      --output $(inputs.output_vcf_basename + ".vcf.gz")
  - position: 2
    shellQuote: false
    valueFrom: >-
      && /tabix/tabix $(inputs.output_vcf_basename + ".vcf.gz")
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
      glob: $(inputs.output_vcf_basename + ".vcf.gz")
    secondaryFiles: [.tbi]
