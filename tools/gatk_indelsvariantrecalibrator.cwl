cwlVersion: v1.0
class: CommandLineTool
id: gatk_indelsvariantrecalibrator
requirements:
  - class: DockerRequirement
    dockerPull: 'kfdrc/gatk:4.beta.5'
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
      /gatk-launch --javaOptions "-Xmx24g -Xms24g"
      VariantRecalibrator
      -V $(inputs.sites_only_variant_filtered_vcf.path)
      -O indels.recal
      -tranchesFile indels.tranches
      -allPoly
      -mode INDEL
      --maxGaussians 4
      -resource mills,known=false,training=true,truth=true,prior=12:$(inputs.mills_resource_vcf.path)
      -resource axiomPoly,known=false,training=true,truth=false,prior=10:$(inputs.axiomPoly_resource_vcf.path)
      -resource dbsnp,known=true,training=false,truth=false,prior=2:$(inputs.dbsnp_resource_vcf.path)
      -tranche 100.0
      -tranche 99.95
      -tranche 99.9
      -tranche 99.5
      -tranche 99.0
      -tranche 97.0
      -tranche 96.0
      -tranche 95.0
      -tranche 94.0
      -tranche 93.5
      -tranche 93.0
      -tranche 92.0
      -tranche 91.0
      -tranche 90.0
      -an FS
      -an ReadPosRankSum
      -an MQRankSum
      -an QD
      -an SOR
      -an DP
inputs:
  sites_only_variant_filtered_vcf:
    type: File
    secondaryFiles: [.tbi]
  mills_resource_vcf:
    type: File
    secondaryFiles: [.tbi]
  axiomPoly_resource_vcf:
    type: File
    secondaryFiles: [.tbi]
  dbsnp_resource_vcf:
    type: File
    secondaryFiles: [.idx]
outputs:
  recalibration:
    type: File
    outputBinding:
      glob: indels.recal
    secondaryFiles: [.idx]
  tranches:
    type: File
    outputBinding:
      glob: indels.tranches
