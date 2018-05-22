cwlVersion: v1.0
class: CommandLineTool
id: gatk_genotypegvcfs
requirements:
  - class: DockerRequirement
    dockerPull: 'broadinstitute/gatk:4.beta.5'
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: 7000
    coresMin: 2
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      tar -xf $(inputs.workspace_tar.path)

      /gatk/gatk-launch --javaOptions "-Xmx5g -Xms5g"
      GenotypeGVCFs
      -R $(inputs.ref_fasta.path)
      -O $(inputs.output_vcf_filename)
      -D $(inputs.dbsnp_vcf.path)
      -G StandardAnnotation
      --onlyOutputCallsStartingInIntervals
      -newQual
      -V gendb://$(inputs.workspace_tar.nameroot)
      -L $(inputs.interval.path)
inputs:
  workspace_tar: File
  ref_fasta:
    type: File
    secondaryFiles: [^.dict, .fai]
  dbsnp_vcf:
    type: File
    secondaryFiles: [.idx]
  interval: File
  output_vcf_filename: string
outputs:
  output:
    type: File
    outputBinding:
      glob: $(inputs.output_vcf_filename)
    secondaryFiles: [.tbi]
