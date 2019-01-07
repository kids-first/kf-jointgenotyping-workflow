cwlVersion: v1.0
class: CommandLineTool
id: gatk_collectgvcfcallingmetrics
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'migbro/gatk:4.0.12.0'
  - class: ResourceRequirement
    ramMin: 7000
    coresMin: 8
baseCommand: []
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      /gatk --java-options "-Xmx6g -Xms6g"
      CollectVariantCallingMetrics
      INPUT=$(inputs.input_vcf.path)
      OUTPUT=$(inputs.output_basename)
      DBSNP=$(inputs.dbsnp_vcf.path)
      SEQUENCE_DICTIONARY=$(inputs.reference_dict.path)
      TARGET_INTERVALS=$(inputs.wgs_evaluation_interval_list.path)
      THREAD_COUNT=8
inputs:
  input_vcf:
    type: File
    secondaryFiles: [.tbi]
  reference_dict:
    type: File
  output_basename:
    type: string
  dbsnp_vcf:
    type: File
    secondaryFiles: [.idx]
  wgs_evaluation_interval_list:
    type: File
outputs:
  output:
    type: File[]
    outputBinding:
      glob: '*_metrics'