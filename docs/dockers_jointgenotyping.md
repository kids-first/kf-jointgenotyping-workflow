# Dockers of kfdrc-jointgenotyping-refinement-workflow.cwl

TOOL|DOCKER
-|-
bcftools_annotate.cwl|pgc-images.sbgenomics.com/d3b-bixu/vcfutils:latest
bcftools_filter_vcf.cwl|pgc-images.sbgenomics.com/d3b-bixu/bvcftools:latest
bcftools_strip_ann.cwl|pgc-images.sbgenomics.com/d3b-bixu/vcfutils:latest
bundle_secondaryfiles.cwl|None
bwa_index.cwl|pgc-images.sbgenomics.com/d3b-bixu/bwa:0.7.17-r1188
echtvar_anno.cwl|pgc-images.sbgenomics.com/d3b-bixu/echtvar:0.2.0
gatk_applyrecalibration.cwl|pgc-images.sbgenomics.com/d3b-bixu/gatk:4.0.12.0
gatk_calculategenotypeposteriors.cwl|pgc-images.sbgenomics.com/d3b-bixu/gatk:4.0.12.0
gatk_gatherfinalvcf.cwl|pgc-images.sbgenomics.com/d3b-bixu/gatk:4.0.12.0
gatk_gathertranches.cwl|pgc-images.sbgenomics.com/d3b-bixu/gatk:4.0.12.0
gatk_gathervcfs.cwl|pgc-images.sbgenomics.com/d3b-bixu/gatk:4.0.12.0
gatk_import_genotype_filtergvcf_merge.cwl|pgc-images.sbgenomics.com/d3b-bixu/gatk:4.0.12.0
gatk_indelsvariantrecalibrator.cwl|pgc-images.sbgenomics.com/d3b-bixu/gatk:4.0.12.0
gatk_indexfeaturefile.cwl|pgc-images.sbgenomics.com/d3b-bixu/gatk:4.1.7.0R
gatk_snpsvariantrecalibratorcreatemodel.cwl|pgc-images.sbgenomics.com/d3b-bixu/gatk:4.0.12.0
gatk_snpsvariantrecalibratorscattered.cwl|pgc-images.sbgenomics.com/d3b-bixu/gatk:4.0.12.0
gatk_variantannotator.cwl|pgc-images.sbgenomics.com/d3b-bixu/gatk:3.8_ubuntu
gatk_variantfiltration.cwl|pgc-images.sbgenomics.com/d3b-bixu/gatk:4.0.12.0
generic_rename_outputs.cwl|None
kfdrc_peddy_tool.cwl|pgc-images.sbgenomics.com/d3b-bixu/peddy:v0.4.2
normalize_vcf.cwl|pgc-images.sbgenomics.com/d3b-bixu/vcfutils:latest
picard_collectvariantcallingmetrics.cwl|pgc-images.sbgenomics.com/d3b-bixu/gatk:4.0.12.0
picard_createsequencedictionary.cwl|pgc-images.sbgenomics.com/d3b-bixu/gatk:4.1.7.0R
samtools_faidx.cwl|pgc-images.sbgenomics.com/d3b-bixu/samtools:1.9
script_dynamicallycombineintervals.cwl|pgc-images.sbgenomics.com/d3b-bixu/python:2.7.13
tabix_index.cwl|pgc-images.sbgenomics.com/d3b-bixu/samtools:1.9
variant_effect_predictor_105.cwl|ensemblorg/ensembl-vep:release_105.0
