cwlVersion: v1.0
class: CommandLineTool
id: kf-vep-annotate
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: 24000
    coresMin: 14
  - class: DockerRequirement
    dockerPull: 'kfdrc/vep:r93'
baseCommand: [tar, -xzf ]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      $(inputs.cache.path)
      && perl /ensembl-vep/vep
      --cache --dir_cache $PWD
      --cache_version 93
      --vcf
      --symbol
      --canonical
      --variant_class
      --offline
      --hgvs
      --hgvsg
      --fork 14
      --sift b
      --vcf_info_field ANN
      -i $(inputs.input_vcf.path)
      -o STDOUT
      --stats_file $(inputs.output_basename)_stats.txt
      --stats_text
      --warning_file $(inputs.output_basename)_warnings.txt
      --fasta $(inputs.reference.path) |
      /ensembl-vep/htslib/bgzip -c > $(inputs.output_basename).CGP.filtered.deNovo.vep.vcf.gz
      && /ensembl-vep/htslib/tabix $(inputs.output_basename).CGP.filtered.deNovo.vep.vcf.gz

inputs:
  reference: { type: File,  secondaryFiles: [.fai], label: Fasta genome assembly with index }
  input_vcf:
    type: File
    secondaryFiles: [.tbi]
  output_basename: string
  cache: { type: File, label: tar gzipped cache from ensembl/local converted cache }

outputs:
  output_vcf:
    type: File
    outputBinding:
      glob: '*.vcf.gz'
    secondaryFiles: [.tbi]
  output_txt:
    type: File
    outputBinding:
      glob: '*_stats.txt'
  warn_txt:
    type: ["null", File]
    outputBinding:
      glob: '*_warnings.txt'