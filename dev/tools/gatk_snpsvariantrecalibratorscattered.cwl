cwlVersion: v1.0
class: CommandLineTool
id: gatk_snpsvariantrecalibratorscattered
requirements:
  - class: DockerRequirement
    dockerPull: 'kfdrc/gatk:4.beta.5'
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: 104000
    coresMin: 2
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      /usr/gitc/gatk-launch --javaOptions "-Xmx3g -Xms3g"
      VariantRecalibrator
      -V $(inputs.sites_only_variant_filtered_vcf.path)
      -O $(inputs.recalibration_filename)
      -tranchesFile $(inputs.tranches_filename)
      -allPoly
      -mode SNP
      --input_model $(inputs.model_report)
      --maxGaussians 6
      -resource hapmap,known=false,training=true,truth=true,prior=15:$(inputs.hapmap_resource_vcf.path)
      -resource omni,known=false,training=true,truth=true,prior=12:$(inputs.omni_resource_vcf.path)
      -resource 1000G,known=false,training=true,truth=false,prior=10:$(inputs.one_thousand_genomes_resource_vcf.path)
      -resource dbsnp,known=true,training=false,truth=false,prior=7:$(inputs.dbsnp_resource_vcf.path)
inputs:
  sites_only_variant_filtered_vcf:
    type: File
    secondaryFiles: [.tbi]
  recalibration_filename: string
  tranches_filename: string
  model_report: File
  hapmap_resource_vcf:
    type: File
    secondaryFiles: [.tbi]
  omni_resource_vcf:
    type: File
    secondaryFiles: [.tbi]
  one_thousand_genomes_resource_vcf:
    type: File
    secondaryFiles: [.tbi]
  dbsnp_resource_vcf:
    type: File
    secondaryFiles: [.tbi]
  recalibration_tranche_values:
    type: string[]
    inputBinding:
      position: 1
      prefix: -tranche
      itemSeparator: ' -tranche '
  recalibration_annotation_values:
    type: string[]
    inputBinding:
      position: 2
      prefix: -an
      itemSeparator: ' -an '
outputs:
  recalibration:
    type: File
    outputBinding:
      glob: $(inputs.recalibration_filename)
    secondaryFiles: [.idx]
  tranches:
    type: File
    outputBinding:
      glob: $(inputs.tranches_filename)
