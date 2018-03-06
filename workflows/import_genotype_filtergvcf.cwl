cwlVersion: v1.0
class: Workflow
id: import_genotype_filtergvcf
requirements:
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement

inputs:
  input_vcfs: File[]
  interval: File
  workspace_dir_name: string
  dbsnp_vcf: File
  output_vcf_filename: string
  ref_fasta: File
  sites_only_vcf_filename: string
  variant_filtered_vcf_filename: string
outputs:
  variant_filtered_vcf:
    type: File
    outputSource: gatk_hardfiltermakesitesonlyvcf/variant_filtered_vcf

steps:
  gatk_importgvcfs:
    run: ../tools/gatk_importgvcfs.cwl
    in:
      gvcf: input_vcfs
      interval: interval
      workspace_dir_name: workspace_dir_name
    out: [output]
  gatk_genotypegvcfs:
    run: ../tools/gatk_genotypegvcfs.cwl
    in:
      dbsnp_vcf: dbsnp_vcf
      interval: interval
      output_vcf_filename: output_vcf_filename
      ref_fasta: ref_fasta
      workspace_tar: gatk_importgvcfs/output
    out: [output]
  gatk_hardfiltermakesitesonlyvcf:
    run: ../tools/gatk_hardfiltermakesitesonlyvcf.cwl
    in:
      sites_only_vcf_filename: sites_only_vcf_filename
      variant_filtered_vcf_filename: variant_filtered_vcf_filename
      vcf: gatk_genotypegvcfs/output
    out: [variant_filtered_vcf, sites_only_vcf]