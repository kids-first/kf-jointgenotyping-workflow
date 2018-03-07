cwlVersion: v1.0
class: CommandLineTool
id: gatk_applyrecalibration
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
      /gatk-launch --javaOptions "-Xmx5g -Xms5g"
      ApplyVQSR
      -O tmp.indel.recalibrated.vcf
      -V $(inputs.input_vcf.path)
      --recalFile $(inputs.indels_recalibration.path)
      -tranchesFile $(inputs.indels_tranches.path)
      -ts_filter_level 99.7
      --createOutputVariantIndex true
      -mode INDEL

      /gatk-launch --javaOptions "-Xmx5g -Xms5g"
      ApplyVQSR
      -O $(inputs.recalibrated_vcf_filename)
      -V tmp.indel.recalibrated.vcf
      --recalFile $(inputs.snps_recalibration.path)
      -tranchesFile $(inputs.snps_tranches.path)
      -ts_filter_level 99.7
      --createOutputVariantIndex true
      -mode SNP
inputs:
  input_vcf:
    type: File
    secondaryFiles: [.tbi]
  indels_recalibration:
    type: File
    secondaryFiles: [.idx]
  indels_tranches: File
  recalibrated_vcf_filename: string
  snps_recalibration:
    type: File
    secondaryFiles: [.idx]
  snps_tranches: File

outputs:
  recalibrated_vcf:
    type: File
    outputBinding:
      glob: $(inputs.recalibrated_vcf_filename)
    secondaryFiles: [.tbi]