cwlVersion: v1.0
class: CommandLineTool
id: gatk_import_genotype_filtergvcf_merge
requirements:
  - class: DockerRequirement
    dockerPull: 'zhangb1/broad-gatk4.beta.5-picard'
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: 16000
    coresMin: 5
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      /gatk/gatk-launch --javaOptions "-Xms4g"
      GenomicsDBImport
      --genomicsDBWorkspace genomicsdb
      --batchSize 50
      -L $(inputs.interval.path)
      --readerThreads 5
      -ip 5
  - position: 2
    shellQuote: false
    valueFrom: >-
      && tar -cf genomicsdb.tar genomicsdb
  - position: 3
    shellQuote: false
    valueFrom: >-
      && /gatk/gatk-launch --javaOptions "-Xmx16g -Xms5g"
      GenotypeGVCFs
      -R $(inputs.ref_fasta.path)
      -O output.vcf.gz
      -D $(inputs.dbsnp_vcf.path)
      -G StandardAnnotation
      --onlyOutputCallsStartingInIntervals
      -newQual
      -V gendb://genomicsdb
      -L $(inputs.interval.path)
  - position: 4
    shellQuote: false
    valueFrom: >-
      && /gatk/gatk-launch --javaOptions "-Xmx3g -Xms3g" 
      VariantFiltration 
      --filterExpression "ExcessHet > 54.69"
      --filterName ExcessHet
      -O variant_filtered.vcf.gz
      -V output.vcf.gz
  - position: 5
    shellQuote: false
    valueFrom: >-
      && java -Xmx3g -Xms3g -jar /picard.jar
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
