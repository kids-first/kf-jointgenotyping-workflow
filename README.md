# Kids First DRC Joint Genotyping Workflow
Kids First Data Resource Center Joint Genotyping Workflow (cram-to-deNovoGVCF). **_Small_** Cohort sample variant calling and genotype refinement.
This workflow is intended for family cohort calling, typically mother-father-proband trios.
If you wish to run on a larger cohort, please see our [Kids First-Sentieon Joint Cohort Calling](https://github.com/kids-first/Kids-First-Sentieon-Joint-Cohort-Genotyping-Workflow) workflow.
Furthermore, in its current state, it follows best practices for WGS input only.
While WXS data could be run, parameters are not currently optimized for that, but a planned update will allow for appropriate defaults to be set for either input type.
Note: The DNA annotation has been significantly upgraded since v2.2.3, if you'd like to use the old version, revert to that release.

Using existing gVCFs, likely from GATK Haplotype Caller, we follow this workflow: [Germline short variant discovery (SNPs + Indels)](https://gatk.broadinstitute.org/hc/en-us/articles/360035535932-Germline-short-variant-discovery-SNPs-Indels), to create family joint calling and joint trios (typically mother-father-child) variant calls. Peddy is run to raise any potential issues in family relation definitions and sex assignment.

If you would like to run this workflow using the CAVATICA public app, a basic primer on running public apps can be found [here](https://www.notion.so/d3b/Starting-From-Scratch-Running-Cavatica-af5ebb78c38a4f3190e32e67b4ce12bb).
Alternatively, if you'd like to run it locally using `cwltool`, a basic primer on that can be found [here](https://www.notion.so/d3b/Starting-From-Scratch-Running-CWLtool-b8dbbde2dc7742e4aff290b0a878344d) and combined with app-specific info from the readme below.
This workflow is the current production workflow, equivalent to this [CAVATICA public app](https://cavatica.sbgenomics.com/public/apps#cavatica/apps-publisher/kfdrc-jointgenotyping-refinement-workflow).

![data service logo](https://github.com/d3b-center/d3b-research-workflows/raw/master/doc/kfdrc-logo-sm.png)

### Runtime Estimates
- Trio of 6 GB gVCFs Input: 540 Minutes & ~$6.95

### Tips To Run:
1. inputs vcf files are the gVCF files from GATK Haplotype Caller, need to have the index **.tbi** files copy to the same project too.
1. If you are experiencing issues with Variant Recalibration either in VariantRecalibrator or ApplyVQSR, consider adjusting the max_gaussians. If a dataset gives fewer variants than the expected scale, the number of Gaussians for training should be turned down. Lowering the max-Gaussians forces the program to group variants into a smaller number of clusters, which results in more variants per cluster.
1. ped file in the input shows the family relationship between samples, the format should be the same as in GATK website [link](https://gatk.broadinstitute.org/hc/en-us/articles/360035531972-PED-Pedigree-format), the Individual ID, Paternal ID and Maternal ID must be the same as in the inputs vcf files header.
1. Here we recommend to use GRCh38 as reference genome to do the analysis, positions in gVCF should be GRCh38 too.
1. Reference locations:
    - Broad Institute Goolge Cloud: https://console.cloud.google.com/storage/browser/gcp-public-data--broad-references/hg38/v0
    - KFDRC S3 bucket: s3://kids-first-seq-data/broad-references/, s3://kids-first-seq-data/pipeline-references/
    - CAVATICA: https://cavatica.sbgenomics.com/u/kfdrc-harmonization/kf-references/
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
    -  homo_sapiens_merged_vep_105_GRCh38.tar.gz, from ftp://ftp.ensembl.org/pub/release-105/variation/indexed_vep_cache/ - variant effect predictor cache.
    - gnomad_v3.1.1.custom.echtvar.zip
    -  wgs_evaluation_regions.hg38.interval_list
1. Optional inputs:
    - dbNSFP4.3a_grch38.gz
      - dbNSFP4.3a_grch38.gz.tbi
      - dbNSFP4.3a_grch38.readme.txt
    - CADDv1.6-38-gnomad.genomes.r3.0.indel.tsv.gz
    - CADDv1.6-38-whole_genome_SNVs.tsv.gz
    - clinvar_20220507_chr.vcf.gz

## Outputs
Note: Not all outputs are available from the Kids First Portal. If there is an output that you'd like that is produced by the workflow that is not available, please contact support@kidsfirstdrc.org.
 - `collectvariantcallingmetrics`: Variant calling summary and detailed metrics files
 - `peddy_html`: html summary of peddy results
 - `peddy_ped`: ped format summary of peddy results
 - `cgp_vep_annotated_vcf`: Variant Effect Predictor annotated VCF files. File suffix tyically `.multi.vqsr.filtered.denovo.vep_105.vcf.gz`. Contains joint calls with the following:
   - `lowGQ` FILTER `GQ < 20.0`.
   - Genotype posterior probabilities. See [here](https://gatk.broadinstitute.org/hc/en-us/articles/360037226592-CalculateGenotypePosteriors) for an explanation
   - INFO tags of `hiConfDeNovo`, `loConfDeNovo`. See [here](https://gatk.broadinstitute.org/hc/en-us/articles/4409924802331-PossibleDeNovo) for more info

## Import info on cloning the git repo
This repo takes advantage of the git submodule feature.
The germline annotation workflow is maintained in a different repo.
Therefore, in order to get the rest of the code after cloning, you need to run: `git submodule init` and `git submodule update`.
Currently this workflow uses tools from `v1.1.0` of the annotation workflow.
If that is updated, submodule should be as well.
More info on how this works [here](https://git-scm.com/book/en/v2/Git-Tools-Submodules)

### Annotation sub workflow
Information of default annotation performed can be found in the [Kids First DRC Germline SNV Annotation Workflow docs](kf-annotation-tools/docs/GERMLINE_SNV_ANNOT_README.md)

## Other Resources
- dockerfiles: https://github.com/d3b-center/bixtools
