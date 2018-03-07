cwlVersion: v1.0
class: CommandLineTool
id: gatk_snpsvariantrecalibratorcreatemodel
requirements:
  - class: DockerRequirement
    dockerPull: 'kfdrc/gatk:4.beta.5'
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: 30000
    coresMin: 2
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      /gatk-launch --javaOptions "-Xmx100g -Xms30g"
      VariantRecalibrator
      -V $(inputs.sites_only_variant_filtered_vcf.path)
      -O snps.recal
      -tranchesFile snps.tranches
      -allPoly
      -mode SNP
      -sampleEvery 10
      --output_model snps.model.report
      --maxGaussians 6
      -resource hapmap,known=false,training=true,truth=true,prior=15:$(inputs.hapmap_resource_vcf.path)
      -resource omni,known=false,training=true,truth=true,prior=12:$(inputs.omni_resource_vcf.path)
      -resource 1000G,known=false,training=true,truth=false,prior=10:$(inputs.one_thousand_genomes_resource_vcf.path)
      -resource dbsnp,known=true,training=false,truth=false,prior=7:$(inputs.dbsnp_resource_vcf.path)
      -tranche 100.0
      -tranche 99.95
      -tranche 99.9
      -tranche 99.8
      -tranche 99.6
      -tranche 99.5
      -tranche 99.4
      -tranche 99.3
      -tranche 99.0
      -tranche 98.0
      -tranche 97.0
      -tranche 90.0
      -an QD
      -an MQRankSum
      -an ReadPosRankSum
      -an FS
      -an MQ
      -an SOR
      -an DP
inputs:
  sites_only_variant_filtered_vcf:
    type: File
    secondaryFiles: [.tbi]
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
outputs:
  model_report:
    type: File
    outputBinding:
      glob: snps.model.report
