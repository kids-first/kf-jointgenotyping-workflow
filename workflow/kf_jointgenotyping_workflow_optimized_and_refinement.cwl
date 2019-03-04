cwlVersion: v1.0
class: Workflow
id: kf_jointgenotyping_workflow_optimized_and_refinement
requirements:
  - class: ScatterFeatureRequirement

inputs:
  input_vcfs: File[]
  unpadded_intervals_file: File
  dbsnp_vcf: File
  output_basename: string
  ref_fasta: File
  hapmap_resource_vcf: File
  omni_resource_vcf: File
  one_thousand_genomes_resource_vcf: File
  axiomPoly_resource_vcf: File
  mills_resource_vcf: File
  reference_dict: File
  wgs_evaluation_interval_list: File
  ped: File
  cache: File
  snp_sites: File

outputs:
  collectvariantcallingmetrics:
    type: File[]
    outputSource: picard_collectvariantcallingmetrics/output
  cgp_vep_annotated_vcf:
    type: File
    outputSource: vep_annotate/output_vcf
  vcf_summary_stats:
    type: File
    outputSource: vep_annotate/output_txt
  vep_warn:
    type: File
    outputSource: vep_annotate/warn_txt
  output_html:
    type: File[]
    outputSource: peddy/output_html
  output_csv:
    type: File[]
    outputSource: peddy/output_csv
  output_peddy:
    type: File[]
    outputSource: peddy/output_peddy

steps:
  dynamicallycombineintervals:
    run: ../tools/script_dynamicallycombineintervals.cwl
    in:
      input_vcfs: input_vcfs
      interval: unpadded_intervals_file
    out: [out_intervals]
  gatk_import_genotype_filtergvcf_merge:
    run: ../tools/gatk_import_genotype_filtergvcf_merge.cwl
    in:
      input_vcfs: input_vcfs
      interval: dynamicallycombineintervals/out_intervals
      dbsnp_vcf: dbsnp_vcf
      ref_fasta: ref_fasta
    scatter: [interval]
    out:
      [variant_filtered_vcf, sites_only_vcf]
  gatk_gathervcfs:
    run: ../tools/gatk_gathervcfs.cwl
    in:
      input_vcfs: gatk_import_genotype_filtergvcf_merge/sites_only_vcf
    out: [output]
  gatk_snpsvariantrecalibratorcreatemodel:
    run: ../tools/gatk_snpsvariantrecalibratorcreatemodel.cwl
    in: 
      dbsnp_resource_vcf: dbsnp_vcf
      hapmap_resource_vcf: hapmap_resource_vcf
      omni_resource_vcf: omni_resource_vcf
      one_thousand_genomes_resource_vcf: one_thousand_genomes_resource_vcf
      sites_only_variant_filtered_vcf: gatk_gathervcfs/output
    out: [model_report]
  gatk_indelsvariantrecalibrator:
    run: ../tools/gatk_indelsvariantrecalibrator.cwl
    in:
      axiomPoly_resource_vcf: axiomPoly_resource_vcf
      dbsnp_resource_vcf: dbsnp_vcf
      mills_resource_vcf: mills_resource_vcf
      sites_only_variant_filtered_vcf: gatk_gathervcfs/output
    out: [recalibration, tranches]
  gatk_snpsvariantrecalibratorscattered:
    run: ../tools/gatk_snpsvariantrecalibratorscattered.cwl
    in:
      sites_only_variant_filtered_vcf: gatk_import_genotype_filtergvcf_merge/sites_only_vcf
      model_report: gatk_snpsvariantrecalibratorcreatemodel/model_report
      hapmap_resource_vcf: hapmap_resource_vcf
      omni_resource_vcf: omni_resource_vcf
      one_thousand_genomes_resource_vcf: one_thousand_genomes_resource_vcf
      dbsnp_resource_vcf: dbsnp_vcf
    scatter: [sites_only_variant_filtered_vcf]
    out: [recalibration, tranches]
  gatk_gathertranches:
    run: ../tools/gatk_gathertranches.cwl
    in:
      tranches: gatk_snpsvariantrecalibratorscattered/tranches
    out: [output]
  gatk_applyrecalibration:
    run: ../tools/gatk_applyrecalibration.cwl
    in:
      indels_recalibration: gatk_indelsvariantrecalibrator/recalibration
      indels_tranches: gatk_indelsvariantrecalibrator/tranches
      input_vcf: gatk_import_genotype_filtergvcf_merge/variant_filtered_vcf
      snps_recalibration: gatk_snpsvariantrecalibratorscattered/recalibration
      snps_tranches: gatk_gathertranches/output
    scatter: [input_vcf, snps_recalibration]
    scatterMethod: dotproduct
    out: [recalibrated_vcf]
  gatk_finalgathervcf:
    run: ../tools/gatk_gathervcfscloud.cwl
    in:
      input_vcfs: gatk_applyrecalibration/recalibrated_vcf
      output_vcf_basename: output_basename
    out: [output]
  picard_collectvariantcallingmetrics:
    run: ../tools/picard_collectvariantcallingmetrics.cwl
    in:
      input_vcf: gatk_finalgathervcf/output
      reference_dict: reference_dict
      final_gvcf_base_name: output_basename
      dbsnp_vcf: dbsnp_vcf
      wgs_evaluation_interval_list: wgs_evaluation_interval_list
    out: [output]
  gatk_calculategenotypeposteriors:
    in:
      ped: ped
      reference: ref_fasta
      snp_sites: snp_sites
      vqsr_vcf: gatk_finalgathervcf/output
      output_basename: output_basename
    out: [output]
    run: ../tools/gatk_calculategenotypeposteriors.cwl

  gatk_variantfiltration:
    in:
      cgp_vcf: gatk_calculategenotypeposteriors/output
      reference: ref_fasta
      output_basename: output_basename
    out: [output]
    run: ../tools/gatk_variantfiltration.cwl
  gatk_variantannotator:
    in:
      cgp_filtered_vcf: gatk_variantfiltration/output
      ped: ped
      reference: ref_fasta
      output_basename: output_basename
    out: [output]
    run: ../tools/gatk_variantannotator.cwl
  vep_annotate:
    in:
      input_vcf: gatk_variantannotator/output
      reference: ref_fasta
      output_basename: output_basename
      cache: cache
    out: [output]
    run: ../tools/variant_effect_predictor.cwl
  peddy:
    in:
      vqsr_vcf: gatk_finalgathervcf/output
      ped: ped
      output_basename: output_basename
    out: [output]
    run: ../tools/kf_peddy_tool.cwl

$namespaces:
  sbg: https://sevenbridges.com
hints:
  - class: 'sbg:maxNumberOfParallelInstances'
    value: 2
