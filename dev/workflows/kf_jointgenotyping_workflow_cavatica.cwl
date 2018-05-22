cwlVersion: v1.0
class: Workflow
id: kf_jointgenotyping_workflow_cavatica
requirements:
  - class: ScatterFeatureRequirement
  - class: SubworkflowFeatureRequirement

inputs:
  input_vcfs:
    type: File[]
    secondaryFiles: [.tbi]
  unpadded_intervals_file: File
  dbsnp_vcf:
    type: File
    secondaryFiles: [.idx]
  output_vcf_basename: string
  ref_fasta:
    type: File
    secondaryFiles: [^.dict, .fai]
  hapmap_resource_vcf:
    type: File
    secondaryFiles: [.tbi]
  omni_resource_vcf:
    type: File
    secondaryFiles: [.tbi]
  one_thousand_genomes_resource_vcf:
    type: File
    secondaryFiles: [.tbi]
  axiomPoly_resource_vcf:
    type: File
    secondaryFiles: [.tbi]
  mills_resource_vcf:
    type: File
    secondaryFiles: [.tbi]
  reference_dict: File
  wgs_evaluation_interval_list: File

outputs:
  gathered_vcfs:
    type: File
    outputSource: gatk_gathervcfs/output
  snp_model:
    type: File
    outputSource: gatk_snpsvariantrecalibratorcreatemodel/model_report
  indel_recal:
    type: File
    outputSource: gatk_indelsvariantrecalibrator/recalibration
  indel_tranches:
    type: File
    outputSource: gatk_indelsvariantrecalibrator/tranches
  snp_vqsr_recal:
    type: File[]
    outputSource: gatk_snpsvariantrecalibratorscattered/recalibration
  snp_vqsr_tranches:
    type: File[]
    outputSource: gatk_snpsvariantrecalibratorscattered/tranches
  gather_tranches:
    type: File
    outputSource: gatk_gathertranches/output
  applyvqsr:
    type: File[]
    outputSource: gatk_applyrecalibration/recalibrated_vcf
  finalgathervcf:
    type: File
    outputSource: gatk_finalgathervcf/output
  collectvariantcallingmetrics:
    type: File[]
    outputSource: picard_collectvariantcallingmetrics/output

steps:
  dynamicallycombineintervals:
    run: ../tools/script_dynamicallycombineintervals_tiny.cwl
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
      output_vcf_basename: output_vcf_basename
    out: [output]
  picard_collectvariantcallingmetrics:
    run: ../tools/picard_collectvariantcallingmetrics.cwl
    in:
      input_vcf: gatk_finalgathervcf/output
      reference_dict: reference_dict
      final_gvcf_base_name: output_vcf_basename
      dbsnp_vcf: dbsnp_vcf
      wgs_evaluation_interval_list: wgs_evaluation_interval_list
    out: [output]


