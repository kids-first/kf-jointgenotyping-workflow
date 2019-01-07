cwlVersion: v1.0
class: Workflow
id: kfdrc_jointgenotyping_workflow_optimized
label: Kids First DRC Joint Genotyping Workflow
doc: 'Kids First Data Resource Center Joint Genotyping Workflow (cram-to-deNovoGVCF). Cohort sample variant calling and genotype refinement. Using existing gVCFs, likely from GATK Haplotype Caller, we follow this workflow: <a href="https://software.broadinstitute.org/gatk/best-practices/workflow?id=11145"> Germline short variant discovery (SNPs + Indels)</a>, to create joint trios (typically mother-father-child) variant calls. Peddy is run to raise any potential issues in family relation definitions and sex assignment.'
requirements:
  - class: ScatterFeatureRequirement

inputs:
  input_vcfs: {type: 'File[]', doc: 'Input array of individual sample gVCF files'}
  unpadded_intervals_file: {type: File, doc: 'hg38.even.handcurated.20k.intervals'}
  dbsnp_vcf: {type: File, doc: 'Homo_sapiens_assembly38.dbsnp138.vcf'}
  reference_fasta: {type: File, doc: 'Homo_sapiens_assembly38.fasta'}
  hapmap_resource_vcf: {type: File, doc: 'Hapmap genotype SNP input vcf'}
  omni_resource_vcf: {type: File, doc: '1000G_omni2.5.hg38.vcf.gz'}
  one_thousand_genomes_resource_vcf: {type: File, doc: '1000G_phase1.snps.high_confidence.hg38.vcf.gz, high confidence snps'}
  snp_sites: {type: File, doc: '1000G_phase3_v4_20130502.sites.hg38.vcf'}
  axiomPoly_resource_vcf: {type: File, doc: 'Axiom_Exome_Plus.genotypes.all_populations.poly.hg38.vcf.gz'}
  mills_resource_vcf: {type: File, doc: 'Mills_and_1000G_gold_standard.indels.hg38.vcf.gz'}
  reference_dict: {type: File, doc: 'Homo_sapiens_assembly38.dict'}
  wgs_evaluation_interval_list: {type: File, doc: 'wgs_evaluation_regions.hg38.interval_list'}
  vep_cache: {type: File, doc: 'Variant effect predictor cache file'}
  ped: File
  output_basename: string

outputs:
  collectvariantcallingmetrics: {type: 'File[]', doc: 'Variant calling summary and detailed metrics files', outputSource: picard_collectvariantcallingmetrics/output}
  peddy_html: {type: 'File[]', doc: 'html summary of peddy results', outputSource: peddy/output_html}
  peddy_csv: {type: 'File[]', doc: 'csv details of peddy results', outputSource: peddy/output_csv}
  peddy_ped: {type: 'File[]', doc: 'ped format summary of peddy results', outputSource: peddy/output_peddy}
  cgp_vep_annotated_vcf: {type: File, outputSource: vep_annotate/output_vcf}
  vcf_summary_stats: {type: File, outputSource: vep_annotate/output_txt}
  vep_warn: {type: File, outputSource: vep_annotate/warn_txt}

steps:
  dynamicallycombineintervals:
    run: ../tools/script_dynamicallycombineintervals.cwl
    label: 'Combine intervals'
    doc: 'Merge interval lists based on number of gVCF inputs'
    in:
      input_vcfs: input_vcfs
      interval: unpadded_intervals_file
    out: [out_intervals]
  gatk_import_genotype_filtergvcf_merge:
    run: ../tools/gatk_import_genotype_filtergvcf_merge.cwl
    label: 'Genotype, filter, & merge'
    doc: 'Use GATK GenomicsDBImport, VariantFiltration GenotypeGVCFs, and picard MakeSitesOnlyVcf to genotype, filter and merge gVCF based on known sites'
    in:
      input_vcfs: input_vcfs
      interval: dynamicallycombineintervals/out_intervals
      dbsnp_vcf: dbsnp_vcf
      reference_fasta: reference_fasta
      ped: ped
    scatter: [interval]
    out:
      [variant_filtered_vcf, sites_only_vcf]
  gatk_gathervcfs:
    run: ../tools/gatk_gathervcfs.cwl
    label: 'Gather VCFs'
    doc: 'Merge VCFs scattered from previous step'
    in:
      input_vcfs: gatk_import_genotype_filtergvcf_merge/sites_only_vcf
    out: [output]
  gatk_snpsvariantrecalibratorcreatemodel:
    run: ../tools/gatk_snpsvariantrecalibratorcreatemodel.cwl
    label: 'GATK VariantRecalibrator SNPs'
    doc: 'Create recalibration model for snps using GATK VariantRecalibrator, tranch values, and known site VCFs'
    in: 
      dbsnp_resource_vcf: dbsnp_vcf
      hapmap_resource_vcf: hapmap_resource_vcf
      omni_resource_vcf: omni_resource_vcf
      one_thousand_genomes_resource_vcf: one_thousand_genomes_resource_vcf
      sites_only_variant_filtered_vcf: gatk_gathervcfs/output
    out: [model_report]
  gatk_indelsvariantrecalibrator:
    run: ../tools/gatk_indelsvariantrecalibrator.cwl
    label: 'GATK VariantRecalibrator Indels'
    doc: 'Create recalibration model for indels using GATK VariantRecalibrator, tranch values, and known site VCFs'
    in:
      axiomPoly_resource_vcf: axiomPoly_resource_vcf
      dbsnp_resource_vcf: dbsnp_vcf
      mills_resource_vcf: mills_resource_vcf
      sites_only_variant_filtered_vcf: gatk_gathervcfs/output
    out: [recalibration, tranches]
  gatk_snpsvariantrecalibratorscattered:
    run: ../tools/gatk_snpsvariantrecalibratorscattered.cwl
    label: 'GATK VariantRecalibrator Scatter'
    doc: 'Create recalibration model for known sites from input data using GATK VariantRecalibrator, tranch values, and known site VCFs'
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
    label: 'GATK GatherTranches'
    doc: 'Gather tranches from SNP variant recalibrate scatter'
    in:
      tranches: gatk_snpsvariantrecalibratorscattered/tranches
    out: [output]
  gatk_applyrecalibration:
    run: ../tools/gatk_applyrecalibration.cwl
    label: 'GATK ApplyVQSR'
    doc: 'Apply recalibration to snps and indels'
    in:
      indels_recalibration: gatk_indelsvariantrecalibrator/recalibration
      indels_tranches: gatk_indelsvariantrecalibrator/tranches
      input_vcf: gatk_import_genotype_filtergvcf_merge/variant_filtered_vcf
      snps_recalibration: gatk_snpsvariantrecalibratorscattered/recalibration
      snps_tranches: gatk_gathertranches/output
    scatter: [input_vcf, snps_recalibration]
    scatterMethod: dotproduct
    out: [recalibrated_vcf]
  gatk_gatherfinalvcf:
    run: ../tools/gatk_gatherfinalvcf.cwl
    label: 'GATK GatherVcfsCloud'
    doc: 'Combine resultant VQSR VCFs'
    in:
      input_vcfs: gatk_applyrecalibration/recalibrated_vcf
      output_basename: output_basename
    out: [output]
  peddy:
    run: ../tools/kfdrc_peddy_tool.cwl
    label: 'Peddy'
    doc: 'QC family relationships and sex assignment'
    in:
      ped: ped
      vqsr_vcf: gatk_gatherfinalvcf/output
      output_basename: output_basename
    out: [output_html, output_csv, output_peddy]
  picard_collectvariantcallingmetrics:
    run: ../tools/picard_collectvariantcallingmetrics.cwl
    label: 'CollectVariantCallingMetrics'
    doc: 'picard calculate variant calling metrics'
    in:
      input_vcf: gatk_gatherfinalvcf/output
      reference_dict: reference_dict
      output_basename: output_basename
      dbsnp_vcf: dbsnp_vcf
      wgs_evaluation_interval_list: wgs_evaluation_interval_list
    out: [output]
  gatk_calculategenotypeposteriors:
    in:
      ped: ped
      reference_fasta: reference_fasta
      snp_sites: snp_sites
      vqsr_vcf: gatk_gatherfinalvcf/output
      output_basename: output_basename
    out: [output]
    run: ../tools/gatk_calculategenotypeposteriors.cwl
  gatk_variantfiltration:
    in:
      cgp_vcf: gatk_calculategenotypeposteriors/output
      reference_fasta: reference_fasta
      output_basename: output_basename
    out: [output]
    run: ../tools/gatk_variantfiltration.cwl
  vep_annotate:
    in:
      input_vcf: gatk_variantfiltration/output
      reference_fasta: reference_fasta
      output_basename: output_basename
      cache: vep_cache
    out: [output]
    run: ../tools/variant_effect_predictor.cwl


$namespaces:
  sbg: https://sevenbridges.com
hints:
  - class: 'sbg:AWSInstanceType'
    value: r4.4xlarge;ebs-gp2;500
  - class: sbg:maxNumberOfParallelInstances
    value: 2