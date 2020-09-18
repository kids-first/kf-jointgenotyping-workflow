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
1. ped file in the input shows the family relationship between samples, the format should be the same as in GATK website [link](https://gatkforums.broadinstitute.org/gatk/discussion/7696/pedigree-ped-files), the Individual ID, Paternal ID and Maternal ID must be the same as in the inputs vcf files header.
1. Here we recommend to use GRCh38 as reference genome to do the analysis, positions in gVCF should be GRCh38 too.
1. Reference locations:
    - https://console.cloud.google.com/storage/browser/genomics-public-data/resources/broad/hg38/v0/
    - kfdrc bucket: s3://kids-first-seq-data/broad-references/
    - cavatica: https://cavatica.sbgenomics.com/u/yuankun/kf-reference/
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
- tool images: https://hub.docker.com/r/kfdrc/
- dockerfiles: https://github.com/d3b-center/bixtools

![pipeline flowchart](https://github.com/kids-first/kf-jointgenotyping-workflow/blob/master/docs/kfdrc-jointgenotyping-refinement-workflow.png?raw=true "Joint Genotyping Workflow")
