cwlVersion: v1.0
class: CommandLineTool
id: gatk_import_genotype_filtergvcf_merge
requirements:
  - class: DockerRequirement
    dockerPull: 'kfdrc/gatk:4.0.5.2'
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: 14000
    coresMin: 2
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      /gatk --javaOptions "-Xms4g"
      GenomicsDBImport
      --genomicsdb-workspace-path genomicsdb
      --batchSize 50
      -L $(inputs.interval.path)
      --reader-threads 16
      -ip 5
  - position: 2
    shellQuote: false
    valueFrom: >-
      && tar -cf genomicsdb.tar genomicsdb
      
      /gatk --javaOptions "-Xmx16g -Xms5g"
      GenotypeGVCFs
      -R $(inputs.ref_fasta.path)
      -O output.vcf.gz
      -D $(inputs.dbsnp_vcf.path)
      -G StandardAnnotation
      --only-output-calls-starting-in-intervals
      -new-qual
      -V gendb://genomicsdb
      -L $(inputs.interval.path)
      
      /gatk --javaOptions "-Xmx3g -Xms3g"
      VariantFiltration 
      --filterExpression "ExcessHet > 54.69"
      --filterName ExcessHet
      -O variant_filtered.vcf.gz
      -V output.vcf.gz

      /gatk
      MakeSitesOnlyVcf
      INPUT=variant_filtered.vcf.gz
      OUTPUT=sites_only.variant_filtered.vcf.gz

inputs:
  interval: File
  ref_fasta:
    type: File
    secondaryFiles: [^.dict, .fai]
  dbsnp_vcf:
    type: File
    secondaryFiles: [.idx]
  input_vcfs:
    type:
      type: array
      items: File
      inputBinding:
        prefix: -V
    secondaryFiles: [.tbi]
    inputBinding:
      position: 1
outputs:
  variant_filtered_vcf:
    type: File
    outputBinding:
      glob: variant_filtered.vcf.gz
    secondaryFiles: [.tbi]
  sites_only_vcf:
    type: File
    outputBinding:
      glob: sites_only.variant_filtered.vcf.gz
    secondaryFiles: [.tbi]
