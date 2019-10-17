cwlVersion: v1.0
class: CommandLineTool
id: gatk_applyrecalibration
requirements:
  - class: DockerRequirement
    dockerPull: 'kfdrc/gatk:4.0.12.0'
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
      /gatk --java-options "-Xmx5g -Xms5g"
      ApplyVQSR
      -O tmp.indel.recalibrated.vcf
      -V $(inputs.input_vcf.path)
      --recal-file $(inputs.indels_recalibration.path)
      --tranches-file $(inputs.indels_tranches.path)
      -ts-filter-level 99.7
      --create-output-bam-index true
      -mode INDEL

      /gatk --java-options "-Xmx5g -Xms5g"
      ApplyVQSR
      -O scatter.filtered.vcf.gz
      -V tmp.indel.recalibrated.vcf
      --recal-file $(inputs.snps_recalibration.path)
      --tranches-file $(inputs.snps_tranches.path)
      -ts-filter-level 99.7
      --create-output-bam-index true
      -mode SNP
inputs:
  input_vcf:
    type: File
    secondaryFiles: [.tbi]
  indels_recalibration:
    type: File
    secondaryFiles: [.idx]
  indels_tranches: File
  snps_recalibration:
    type: File
    secondaryFiles: [.idx]
  snps_tranches: File

outputs:
  recalibrated_vcf:
    type: File
    outputBinding:
      glob: scatter.filtered.vcf.gz
    secondaryFiles: [.tbi]
