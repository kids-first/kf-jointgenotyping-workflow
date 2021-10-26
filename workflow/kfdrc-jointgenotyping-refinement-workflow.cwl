cwlVersion: v1.0
class: Workflow
id: kfdrc-jointgenotyping-refinement-workflow
label: Kids First DRC Joint Genotyping Workflow
doc: |
  # Kids First DRC Joint Genotyping Workflow
  Kids First Data Resource Center Joint Genotyping Workflow (cram-to-deNovoGVCF). Cohort sample variant calling and genotype refinement.

  Using existing gVCFs, likely from GATK Haplotype Caller, we follow this workflow: [Germline short variant discovery (SNPs + Indels)](https://software.broadinstitute.org/gatk/best-practices/workflow?id=11145), to create family joint calling and joint trios (typically mother-father-child) variant calls. Peddy is run to raise any potential issues in family relation definitions and sex assignment.

  If you would like to run this workflow using the cavatica public app, a basic primer on running public apps can be found [here](https://www.notion.so/d3b/Starting-From-Scratch-Running-Cavatica-af5ebb78c38a4f3190e32e67b4ce12bb).
  Alternatively, if you'd like to run it locally using `cwltool`, a basic primer on that can be found [here](https://www.notion.so/d3b/Starting-From-Scratch-Running-CWLtool-b8dbbde2dc7742e4aff290b0a878344d) and combined with app-specific info from the readme below.
  This workflow is the current production workflow, equivalent to this [Cavatica public app](https://cavatica.sbgenomics.com/public/apps#cavatica/apps-publisher/kfdrc-jointgenotyping-refinement-workflow).

  ![data service logo](https://github.com/d3b-center/d3b-research-workflows/raw/master/doc/kfdrc-logo-sm.png)

  ### Runtime Estimates
  - Single 5 GB gVCF Input: 90 Minutes & $2.25
  - Trio of 6 GB gVCFs Input: 240 Minutes & $3.25

  ### Tips To Run:
  1. inputs vcf files are the gVCF files from GATK Haplotype Caller, need to have the index **.tbi** files copy to the same project too.
  1. If you are experiencing issues with Variant Recalibration either in VariantRecalibrator or ApplyVQSR, consider adjusting the max_gaussians. If a dataset gives fewer variants than the expected scale, the number of Gaussians for training should be turned down. Lowering the max-Gaussians forces the program to group variants into a smaller number of clusters, which results in more variants per cluster.
  1. ped file in the input shows the family relationship between samples, the format should be the same as in GATK website [link](https://gatkforums.broadinstitute.org/gatk/discussion/7696/pedigree-ped-files), the Individual ID, Paternal ID and Maternal ID must be the same as in the inputs vcf files header.
  1. Here we recommend to use GRCh38 as reference genome to do the analysis, positions in gVCF should be GRCh38 too.
  1. Reference locations:
      - https://console.cloud.google.com/storage/browser/genomics-public-data/resources/broad/hg38/v0/
      - kfdrc bucket: s3://kids-first-seq-data/broad-references/
      - cavatica: https://cavatica.sbgenomics.com/u/kfdrc-harmonization/kf-references/
  1. Suggested inputs:
      -  Axiom_Exome_Plus.genotypes.all_populations.poly.hg38.vcf.gz
      -  Homo_sapiens_assembly38.dbsnp138.vcf
      -  hapmap_3.3.hg38.vcf.gz
      -  Mills_and_1000G_gold_standard.indels.hg38.vcf.gz
      -  1000G_omni2.5.hg38.vcf.gz
      -  1000G_phase1.snps.high_confidence.hg38.vcf.gz
      -  Homo_sapiens_assembly38.dict
      -  Homo_sapiens_assembly38.fasta.fai
      -  Homo_sapiens_assembly38.fasta
      -  1000G_phase3_v4_20130502.sites.hg38.vcf
      -  hg38.even.handcurated.20k.intervals
      -  homo_sapiens_vep_93_GRCh38_convert_cache.tar.gz, from ftp://ftp.ensembl.org/pub/release-93/variation/indexed_vep_cache/ - variant effect predictor cache.
      -  wgs_evaluation_regions.hg38.interval_list

  ## Other Resources
  - dockerfiles: https://github.com/d3b-center/bixtools

  ![pipeline flowchart](https://github.com/kids-first/kf-jointgenotyping-workflow/blob/master/docs/kfdrc-jointgenotyping-refinement-workflow.png?raw=true "Joint Genotyping Workflow")

requirements:
- class: ScatterFeatureRequirement
- class: SubworkflowFeatureRequirement

inputs:
  input_vcfs: {type: 'File[]', doc: 'Input array of individual sample gVCF files'}
  axiomPoly_resource_vcf: {type: File, doc: 'Axiom_Exome_Plus.genotypes.all_populations.poly.hg38.vcf.gz',
    "sbg:suggestedValue": {class: File, path: 60639016357c3a53540ca7c7, name: Axiom_Exome_Plus.genotypes.all_populations.poly.hg38.vcf.gz}}
  axiomPoly_resource_tbi: {type: 'File?', doc: 'Axiom_Exome_Plus.genotypes.all_populations.poly.hg38.vcf.gz.tbi',
    "sbg:suggestedValue": {class: File, path: 6063901d357c3a53540ca81b, name: Axiom_Exome_Plus.genotypes.all_populations.poly.hg38.vcf.gz.tbi}}
  dbsnp_vcf: {type: File, doc: 'Homo_sapiens_assembly38.dbsnp138.vcf', "sbg:suggestedValue": {
      class: File, path: 6063901f357c3a53540ca84b, name: Homo_sapiens_assembly38.dbsnp138.vcf}}
  dbsnp_idx: {type: 'File?', doc: 'Homo_sapiens_assembly38.dbsnp138.vcf.idx', "sbg:suggestedValue": {
      class: File, path: 6063901e357c3a53540ca834, name: Homo_sapiens_assembly38.dbsnp138.vcf.idx}}
  hapmap_resource_vcf: {type: File, doc: 'Hapmap genotype SNP input vcf', "sbg:suggestedValue": {
      class: File, path: 60639016357c3a53540ca7be, name: hapmap_3.3.hg38.vcf.gz}}
  hapmap_resource_tbi: {type: 'File?', doc: 'Hapmap genotype SNP input tbi', "sbg:suggestedValue": {
      class: File, path: 60639016357c3a53540ca7c5, name: hapmap_3.3.hg38.vcf.gz.tbi}}
  mills_resource_vcf: {type: File, doc: 'Mills_and_1000G_gold_standard.indels.hg38.vcf.gz',
    "sbg:suggestedValue": {class: File, path: 6063901a357c3a53540ca7f3, name: Mills_and_1000G_gold_standard.indels.hg38.vcf.gz}}
  mills_resource_tbi: {type: 'File?', doc: 'Mills_and_1000G_gold_standard.indels.hg38.vcf.gz.tbi',
    "sbg:suggestedValue": {class: File, path: 6063901c357c3a53540ca806, name: Mills_and_1000G_gold_standard.indels.hg38.vcf.gz.tbi}}
  omni_resource_vcf: {type: File, doc: '1000G_omni2.5.hg38.vcf.gz', "sbg:suggestedValue": {
      class: File, path: 6063901e357c3a53540ca835, name: 1000G_omni2.5.hg38.vcf.gz}}
  omni_resource_tbi: {type: 'File?', doc: '1000G_omni2.5.hg38.vcf.gz.tbi', "sbg:suggestedValue": {
      class: File, path: 60639016357c3a53540ca7b1, name: 1000G_omni2.5.hg38.vcf.gz.tbi}}
  one_thousand_genomes_resource_vcf: {type: File, doc: '1000G_phase1.snps.high_confidence.hg38.vcf.gz,
      high confidence snps', "sbg:suggestedValue": {class: File, path: 6063901c357c3a53540ca80f,
      name: 1000G_phase1.snps.high_confidence.hg38.vcf.gz}}
  one_thousand_genomes_resource_tbi: {type: 'File?', doc: '1000G_phase1.snps.high_confidence.hg38.vcf.gz.tbi,
      high confidence snps', "sbg:suggestedValue": {class: File, path: 6063901e357c3a53540ca845,
      name: 1000G_phase1.snps.high_confidence.hg38.vcf.gz.tbi}}
  ped: {type: File, doc: 'Ped file for the family relationship'}
  reference_dict: {type: 'File?', doc: 'Homo_sapiens_assembly38.dict', "sbg:suggestedValue": {
      class: File, path: 60639019357c3a53540ca7e7, name: Homo_sapiens_assembly38.dict}}
  reference_fai: {type: 'File?', doc: 'Homo_sapiens_assembly38.fasta.fai', "sbg:suggestedValue": {
      class: File, path: 60639016357c3a53540ca7af, name: Homo_sapiens_assembly38.fasta.fai}}
  reference_fasta: {type: File, doc: 'Homo_sapiens_assembly38.fasta', "sbg:suggestedValue": {
      class: File, path: 60639014357c3a53540ca7a3, name: Homo_sapiens_assembly38.fasta}}
  snp_sites_vcf: {type: File, doc: '1000G_phase3_v4_20130502.sites.hg38.vcf', "sbg:suggestedValue": {
      class: File, path: 60639016357c3a53540ca7b5, name: 1000G_phase3_v4_20130502.sites.hg38.vcf}}
  snp_sites_idx: {type: 'File?', doc: '1000G_phase3_v4_20130502.sites.hg38.vcf.idx',
    "sbg:suggestedValue": {class: File, path: 6063901d357c3a53540ca819, name: 1000G_phase3_v4_20130502.sites.hg38.vcf.idx}}
  unpadded_intervals_file: {type: File, doc: 'hg38.even.handcurated.20k.intervals',
    "sbg:suggestedValue": {class: File, path: 5f500135e4b0370371c051b1, name: hg38.even.handcurated.20k.intervals}}
  vep_cache: {type: File, doc: 'Variant effect predictor cache file', "sbg:suggestedValue": {
      class: File, path: 5f500135e4b0370371c051b5, name: homo_sapiens_vep_93_GRCh38_convert_cache.tar.gz}}
  wgs_evaluation_interval_list: {type: File, doc: 'wgs_evaluation_regions.hg38.interval_list',
    "sbg:suggestedValue": {class: File, path: 60639017357c3a53540ca7d3, name: wgs_evaluation_regions.hg38.interval_list}}
  snp_max_gaussians: {type: 'int?', doc: "Interger value for max gaussians in SNP\
      \ VariantRecalibration. If a dataset gives fewer variants than the expected\
      \ scale, the number of Gaussians for training should be turned down. Lowering\
      \ the max-Gaussians forces the program to group variants into a smaller number\
      \ of clusters, which results in more variants per cluster."}
  indel_max_gaussians: {type: 'int?', doc: "Interger value for max gaussians in INDEL\
      \ VariantRecalibration. If a dataset gives fewer variants than the expected\
      \ scale, the number of Gaussians for training should be turned down. Lowering\
      \ the max-Gaussians forces the program to group variants into a smaller number\
      \ of clusters, which results in more variants per cluster."}
  output_basename: string

outputs:
  collectvariantcallingmetrics: {type: 'File[]', doc: 'Variant calling summary and
      detailed metrics files', outputSource: picard_collectvariantcallingmetrics/output}
  peddy_html: {type: 'File[]', doc: 'html summary of peddy results', outputSource: peddy/output_html}
  peddy_csv: {type: 'File[]', doc: 'csv details of peddy results', outputSource: peddy/output_csv}
  peddy_ped: {type: 'File[]', doc: 'ped format summary of peddy results', outputSource: peddy/output_peddy}
  cgp_vep_annotated_vcf: {type: File, outputSource: vep_annotate/output_vcf}
  vcf_summary_stats: {type: File, outputSource: vep_annotate/output_txt}
  vep_warn: {type: 'File?', outputSource: vep_annotate/warn_txt}

steps:
  prepare_reference:
    run: ../subworkflows/prepare_reference.cwl
    in:
      input_fasta: reference_fasta
      input_fai: reference_fai
      input_dict: reference_dict
    out: [indexed_fasta, reference_dict]
  index_axiomPoly:
    run: ../tools/tabix_index.cwl
    in:
      input_file: axiomPoly_resource_vcf
      input_index: axiomPoly_resource_tbi
    out: [output]
  index_dbsnp:
    run: ../tools/gatk_indexfeaturefile.cwl
    in:
      input_file: dbsnp_vcf
      input_index: dbsnp_idx
    out: [output]
  index_hapmap:
    run: ../tools/tabix_index.cwl
    in:
      input_file: hapmap_resource_vcf
      input_index: hapmap_resource_tbi
    out: [output]
  index_mills:
    run: ../tools/tabix_index.cwl
    in:
      input_file: mills_resource_vcf
      input_index: mills_resource_tbi
    out: [output]
  index_omni:
    run: ../tools/tabix_index.cwl
    in:
      input_file: omni_resource_vcf
      input_index: omni_resource_tbi
    out: [output]
  index_1k:
    run: ../tools/tabix_index.cwl
    in:
      input_file: one_thousand_genomes_resource_vcf
      input_index: one_thousand_genomes_resource_tbi
    out: [output]
  index_snp:
    run: ../tools/gatk_indexfeaturefile.cwl
    in:
      input_file: snp_sites_vcf
      input_index: snp_sites_idx
    out: [output]
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
    doc: 'Use GATK GenomicsDBImport, VariantFiltration GenotypeGVCFs, and picard MakeSitesOnlyVcf
      to genotype, filter and merge gVCF based on known sites'
    hints:
    - class: sbg:AWSInstanceType
      value: r5.4xlarge
    in:
      input_vcfs: input_vcfs
      interval: dynamicallycombineintervals/out_intervals
      dbsnp_vcf: index_dbsnp/output
      reference_fasta: prepare_reference/indexed_fasta
    scatter: [interval]
    out: [variant_filtered_vcf, sites_only_vcf]
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
    doc: 'Create recalibration model for snps using GATK VariantRecalibrator, tranch
      values, and known site VCFs'
    in:
      dbsnp_resource_vcf: index_dbsnp/output
      hapmap_resource_vcf: index_hapmap/output
      omni_resource_vcf: index_omni/output
      one_thousand_genomes_resource_vcf: index_1k/output
      sites_only_variant_filtered_vcf: gatk_gathervcfs/output
      max_gaussians: snp_max_gaussians
    out: [model_report]
  gatk_indelsvariantrecalibrator:
    run: ../tools/gatk_indelsvariantrecalibrator.cwl
    label: 'GATK VariantRecalibrator Indels'
    doc: 'Create recalibration model for indels using GATK VariantRecalibrator, tranch
      values, and known site VCFs'
    in:
      axiomPoly_resource_vcf: index_axiomPoly/output
      dbsnp_resource_vcf: index_dbsnp/output
      mills_resource_vcf: index_mills/output
      sites_only_variant_filtered_vcf: gatk_gathervcfs/output
      max_gaussians: indel_max_gaussians
    out: [recalibration, tranches]
  gatk_snpsvariantrecalibratorscattered:
    run: ../tools/gatk_snpsvariantrecalibratorscattered.cwl
    label: 'GATK VariantRecalibrator Scatter'
    doc: 'Create recalibration model for known sites from input data using GATK VariantRecalibrator,
      tranch values, and known site VCFs'
    hints:
    - class: sbg:AWSInstanceType
      value: r5.4xlarge
    in:
      sites_only_variant_filtered_vcf: gatk_import_genotype_filtergvcf_merge/sites_only_vcf
      model_report: gatk_snpsvariantrecalibratorcreatemodel/model_report
      hapmap_resource_vcf: index_hapmap/output
      omni_resource_vcf: index_omni/output
      one_thousand_genomes_resource_vcf: index_1k/output
      dbsnp_resource_vcf: index_dbsnp/output
      max_gaussians: snp_max_gaussians
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
    hints:
    - class: sbg:AWSInstanceType
      value: r5.4xlarge
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
      reference_dict: prepare_reference/reference_dict
      output_basename: output_basename
      dbsnp_vcf: index_dbsnp/output
      wgs_evaluation_interval_list: wgs_evaluation_interval_list
    out: [output]
  gatk_calculategenotypeposteriors:
    in:
      ped: ped
      reference_fasta: prepare_reference/indexed_fasta
      snp_sites: index_snp/output
      vqsr_vcf: gatk_gatherfinalvcf/output
      output_basename: output_basename
    out: [output]
    run: ../tools/gatk_calculategenotypeposteriors.cwl
  gatk_variantfiltration:
    in:
      cgp_vcf: gatk_calculategenotypeposteriors/output
      reference_fasta: prepare_reference/indexed_fasta
      output_basename: output_basename
    out: [output]
    run: ../tools/gatk_variantfiltration.cwl
  gatk_variantannotator:
    in:
      cgp_filtered_vcf: gatk_variantfiltration/output
      ped: ped
      reference_fasta: prepare_reference/indexed_fasta
      output_basename: output_basename
    out: [output]
    run: ../tools/gatk_variantannotator.cwl
  vep_annotate:
    in:
      input_vcf: gatk_variantannotator/output
      reference_fasta: prepare_reference/indexed_fasta
      output_basename: output_basename
      cache: vep_cache
    out: [output_vcf, output_txt, warn_txt]
    run: ../tools/variant_effect_predictor.cwl

$namespaces:
  sbg: https://sevenbridges.com
hints:
- class: sbg:maxNumberOfParallelInstances
  value: 2
"sbg:license": Apache License 2.0
"sbg:publisher": KFDRC
"sbg:categories":
- GATK
- GENOTYPING
- JOINT
- PEDDY
- VCF
- VEP
"sbg:links":
- id: 'https://github.com/kids-first/kf-jointgenotyping-workflow/releases/tag/v2.2.2'
  label: github-release
