cwlVersion: v1.0
class: CommandLineTool
id: gatk_snpsvariantrecalibratorcreatemodel
requirements:
  - class: DockerRequirement
    dockerPull: 'kfdrc/gatk:4.0.3.0'
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: 7000
    coresMin: 1
hints:
  - class: 'sbg:AWSInstanceType'
    value: r4.2xlarge;ebs-gp2;500
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      /gatk --java-options "-Xmx100g -Xms50g"
      VariantRecalibrator
      -V $(inputs.sites_only_variant_filtered_vcf.path)
      -O snps.recal
      --tranches-file snps.tranches
      --trust-all-polymorphic
      --mode SNP
      --output-model snps.model.report
      --max-gaussians 6
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
    secondaryFiles: [.idx]
outputs:
  model_report:
    type: File
    outputBinding:
      glob: snps.model.report
