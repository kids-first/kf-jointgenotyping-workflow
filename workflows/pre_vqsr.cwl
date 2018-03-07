cwlVersion: v1.0
class: Workflow
id: scatter_pre_vqsr
requirements:
  - class: ScatterFeatureRequirement
  - class: StepInputExpressionRequirement
  - class: InlineJavascriptRequirement
  - class: SubworkflowFeatureRequirement

inputs:
  input_vcfs: File[]
  unpadded_intervals_file: File
  workspace_dir_name: string
  dbsnp_vcf: File
  output_vcf_filename: string
  ref_fasta: File
  sites_only_vcf_filename: string
  variant_filtered_vcf_filename: string

outputs:
  variant_filtered_vcf:
    type: File[]
    outputSource: import_genotype_filtergvcf/variant_filtered_vcf
  sites_only_vcf:
    type: File[]
    outputSource: import_genotype_filtergvcf/sites_only_vcf
  gathervcfs:
    type: File
    outputSource: gatk_gathervcfs/output

steps:
  dynamicallycombineintervals:
    run: ../tools/script_dynamicallycombineintervals_cwltool_tiny.cwl
    in:
      input_vcfs: input_vcfs
      interval: unpadded_intervals_file
    out: [out_intervals]
  import_genotype_filtergvcf:
    run: ../workflow/import_genotype_filtergvcf.cwl
    in:
      input_vcfs: input_vcfs
      interval: dynamicallycombineintervals/out_intervals
      workspace_dir_name: workspace_dir_name
      dbsnp_vcf: dbsnp_vcf
      output_vcf_filename: output_vcf_filename
      ref_fasta: ref_fasta
      sites_only_vcf_filename: sites_only_vcf_filename
      variant_filtered_vcf_filename: variant_filtered_vcf_filename
    scatter: [interval]
    out:
      [variant_filtered_vcf, sites_only_vcf]
  gatk_gathervcfs:
    run: ../tools/gatk_gathervcfs.cwl
    in:
      input_vcfs: import_genotype_filtergvcf/sites_only_vcf
      output_vcf_name: output_vcf_filename
    out: [output]

