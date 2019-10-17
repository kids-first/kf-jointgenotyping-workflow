cwlVersion: v1.0
class: CommandLineTool
id: gatk_import_genotype_filtergvcf_merge
requirements:
  - class: DockerRequirement
    dockerPull: 'kfdrc/gatk:4.0.12.0'
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: 8000
    coresMin: 1
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      /gatk --java-options "-Xms4g"
      GenomicsDBImport
      --genomicsdb-workspace-path genomicsdb
      --batch-size 50
      -L $(inputs.interval.path)
      --reader-threads 16
      -ip 5
  - position: 2
    shellQuote: false
    valueFrom: >-
      && tar -cf genomicsdb.tar genomicsdb
  - position: 3
    shellQuote: false
    valueFrom: >-
      && /gatk --java-options "-Xmx8g -Xms4g"
      GenotypeGVCFs
      -R $(inputs.reference_fasta.path)
      -O output.vcf.gz
      -D $(inputs.dbsnp_vcf.path)
      -G StandardAnnotation
      --only-output-calls-starting-in-intervals
      -new-qual
      -V gendb://genomicsdb
      -L $(inputs.interval.path)
  - position: 4
    shellQuote: false
    valueFrom: >-
      && /gatk --java-options "-Xmx3g -Xms3g"
      VariantFiltration
      --filter-expression "ExcessHet > 54.69"
      --filter-name ExcessHet
      -O variant_filtered.vcf.gz
      -V output.vcf.gz
  - position: 5
    shellQuote: false
    valueFrom: >-
      && /gatk
      MakeSitesOnlyVcf
      -I variant_filtered.vcf.gz
      -O sites_only.variant_filtered.vcf.gz

inputs:
  interval: File
  reference_fasta:
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
