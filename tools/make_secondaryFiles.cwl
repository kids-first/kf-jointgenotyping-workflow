cwlVersion: v1.0
class: CommandLineTool
id: make_secondayFiles
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
  - class: DockerRequirement
    dockerPull: 'kfdrc/gatk:4.0.12.0'
baseCommand: []
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      cp $(inputs.axiomPoly_resource_vcf.path) ./ &&
      /gatk IndexFeatureFile -F ./Axiom_Exome_Plus.genotypes.all_populations.poly.hg38.vcf.gz &&
      cp $(inputs.dbsnp_vcf.path) ./ && 
      /gatk IndexFeatureFile -F ./Homo_sapiens_assembly38.dbsnp138.vcf &&
      cp $(inputs.hapmap_resource_vcf.path) ./ &&
      /gatk IndexFeatureFile -F ./hapmap_3.3.hg38.vcf.gz &&
      cp $(inputs.mills_resource_vcf.path) ./ &&
      /gatk IndexFeatureFile -F ./Mills_and_1000G_gold_standard.indels.hg38.vcf.gz &&
      cp $(inputs.omni_resource_vcf.path) ./ &&
      /gatk IndexFeatureFile -F ./1000G_omni2.5.hg38.vcf.gz &&
      cp $(inputs.one_thousand_genomes_resource_vcf.path) ./ &&
      /gatk IndexFeatureFile -F ./1000G_phase1.snps.high_confidence.hg38.vcf.gz &&
      cp $(inputs.snp_sites.path) ./ &&
      /gatk IndexFeatureFile -F ./1000G_phase3_v4_20130502.sites.hg38.vcf

inputs:
  axiomPoly_resource_vcf: { type: File}
  dbsnp_vcf: {type: File}
  hapmap_resource_vcf: { type: File}
  mills_resource_vcf: { type: File}
  omni_resource_vcf: {type: File}
  one_thousand_genomes_resource_vcf: {type: File}
  snp_sites: {type: File}
outputs:
  axiomPoly_resource_vcf_output:
    type: File
    outputBinding:
      glob: '*Axiom_Exome_Plus.genotypes.all_populations.poly.hg38.vcf.gz'
    secondaryFiles: [.tbi]
  dbsnp_vcf_output:
    type: File
    outputBinding:
      glob: '*Homo_sapiens_assembly38.dbsnp138.vcf'
    secondaryFiles: [.idx]
  hapmap_resource_vcf_output:
    type: File
    outputBinding:
      glob: '*hapmap_3.3.hg38.vcf.gz'
    secondaryFiles: [.tbi]
  mills_resource_vcf_output:
    type: File
    outputBinding:
      glob: '*Mills_and_1000G_gold_standard.indels.hg38.vcf.gz'
    secondaryFiles: [.tbi]
  omni_resource_vcf_output:
    type: File
    outputBinding:
      glob: '*1000G_omni2.5.hg38.vcf.gz'
    secondaryFiles: [.tbi]
  one_thousand_genomes_resource_vcf_output:
    type: File
    outputBinding:
      glob: '*1000G_phase1.snps.high_confidence.hg38.vcf.gz'
    secondaryFiles: [.tbi]
  snp_sites_output:
    type: File
    outputBinding:
      glob: '*1000G_phase3_v4_20130502.sites.hg38.vcf'
    secondaryFiles: [.idx]