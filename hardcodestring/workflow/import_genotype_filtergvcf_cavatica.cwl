cwlVersion: v1.0
class: Workflow
id: import_genotype_filtergvcf
requirements:
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement

inputs:
  input_vcfs:
    type: File[]
    inputBinding: [.tbi]
  interval: File
  dbsnp_vcf:
    type: File[]
    inputBinding: [.idx]
  ref_fasta:
    type: File[]
    inputBinding: [^.dict, .fai]
outputs:
  variant_filtered_vcf:
    type: File
    outputSource: gatk_hardfiltermakesitesonlyvcf/variant_filtered_vcf
  sites_only_vcf:
    type: File
    outputSource: gatk_hardfiltermakesitesonlyvcf/sites_only_vcf

steps:
  gatk_importgvcfs:
    run: ../tools/gatk_importgvcfs.cwl
    in:
      gvcf: input_vcfs
      interval: interval
    out: [output]
  gatk_genotypegvcfs:
    run: ../tools/gatk_genotypegvcfs.cwl
    in:
      dbsnp_vcf: dbsnp_vcf
      interval: interval
      ref_fasta: ref_fasta
      workspace_tar: gatk_importgvcfs/output
    out: [output]
  gatk_hardfiltermakesitesonlyvcf:
    run: ../tools/gatk_hardfiltermakesitesonlyvcf.cwl
    in:
      vcf: gatk_genotypegvcfs/output
    out: [variant_filtered_vcf, sites_only_vcf]