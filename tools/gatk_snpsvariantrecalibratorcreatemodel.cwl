cwlVersion: v1.0
class: CommandLineTool
id: gatk_snpsvariantrecalibratorcreatemodel
requirements:
  - class: DockerRequirement
    dockerPull: 'broadinstitute/gatk:4.beta.5'
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
      /usr/gitc/gatk-launch --javaOptions "-Xmx100g -Xms100g"
      VariantRecalibrator
      -V $(inputs.sites_only_variant_filtered_vcf.path)
      -O $(inputs.recalibration_filename)
      -tranchesFile $(inputs.tranches_filename)
      -allPoly
      -mode SNP
      -sampleEvery $(inputs.downsample_factor)
      --output_model $(inputs.model_report_filename)
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
  downsample_factor: int
  model_report_filename: string
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
  model_report:
    type: File
    outputBinding:
      glob: $(inputs.model_report_filename)
