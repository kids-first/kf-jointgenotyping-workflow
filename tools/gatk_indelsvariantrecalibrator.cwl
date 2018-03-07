cwlVersion: v1.0
class: CommandLineTool
id: gatk_indelsvariantrecalibrator
requirements:
  - class: DockerRequirement
    dockerPull: 'broadinstitute/gatk:4.beta.5'
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: 24000
    coresMin: 2
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      /gatk/gatk-launch --javaOptions "-Xmx24g -Xms24g"
      VariantRecalibrator
      -V $(inputs.sites_only_variant_filtered_vcf.path)
      -O $(inputs.recalibration_filename)
      -tranchesFile $(inputs.tranches_filename)
      -allPoly
      -mode INDEL
      --maxGaussians 4
      -resource mills,known=false,training=true,truth=true,prior=12:$(inputs.mills_resource_vcf.path)
      -resource axiomPoly,known=false,training=true,truth=false,prior=10:$(inputs.axiomPoly_resource_vcf.path)
      -resource dbsnp,known=true,training=false,truth=false,prior=2:$(inputs.dbsnp_resource_vcf.path)

inputs:
  sites_only_variant_filtered_vcf:
    type: File
    secondaryFiles: [.tbi]
  recalibration_filename: string
  tranches_filename: string
  mills_resource_vcf:
    type: File
    secondaryFiles: [.tbi]
  axiomPoly_resource_vcf:
    type: File
    secondaryFiles: [.tbi]
  dbsnp_resource_vcf:
    type: File
    secondaryFiles: [.idx]
  recalibration_tranche_values:
    type:
      type: array
      items: string
      inputBinding:
        prefix: -tranche
    inputBinding:
      position: 1
  recalibration_annotation_values:
    type:
      type: array
      items: string
      inputBinding:
        prefix: -an
    inputBinding:
      position: 2
outputs:
  recalibration:
    type: File
    outputBinding:
      glob: $(inputs.recalibration_filename)
    secondaryFiles: [.tbi]
  tranches:
    type: File
    outputBinding:
      glob: $(inputs.tranches_filename)
