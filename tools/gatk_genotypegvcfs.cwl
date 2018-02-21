cwlVersion: v1.0
class: CommandLineTool
id: gatk_genotypegvcfs
requirements:
  - class: DockerRequirement
    dockerPull: 'kfdrc/gatk:4.beta.1'
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
      set -e

      tar -xf $(inputs.workspace_tar.path)

      WORKSPACE=`basename $(inputs.workspace_tar.path) .tar)`

      /gatk-launch --javaOptions "-Xmx5g -Xms5g"
      GenotypeGVCFs
      -R $(inputs.ref_fasta.path)
      -O $(inputs.output_vcf_filename)
      -D $(inputs.dbsnp_vcf.path)
      -G StandardAnnotation
      --onlyOutputCallsStartingInIntervals
      -newQual
      -V gendb://$WORKSPACE
      -L $(inputs.interval.path)
inputs:
  workspace_tar:
    type: File
  ref_fasta:
    type: File
    secondaryFiles: [.idx, ^.dict]
  dbsnp_vcf:
    type: File
  interval:
    type: File
  output_vcf_filename:
    type: string
outputs:
  output:
    type: File
    outputBinding:
      glob: $(inputs.output_vcf_filename)
    secondaryFiles: [.tbi]
