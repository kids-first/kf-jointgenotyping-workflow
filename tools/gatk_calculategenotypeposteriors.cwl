cwlVersion: v1.0
class: CommandLineTool
id: kfdrc-gatk_calculategenotypeposteriors
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: 8000
    coresMin: 2
    coresMax: 4
  - class: DockerRequirement
    dockerPull: 'kfdrc/gatk:4.0.5.2'
baseCommand: [/gatk]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      --java-options "-Xms8000m
      -XX:GCTimeLimit=50
      -XX:GCHeapFreeLimit=10"
      CalculateGenotypePosteriors
      -R $(inputs.reference.path)
      -O $(inputs.output_basename).postCGP.vcf.gz
      -V $(inputs.vqsr_vcf.path)
      --supporting $(inputs.snp_sites.path)
      --pedigree $(inputs.ped.path)

inputs:
  reference: {type: File, secondaryFiles: [^.dict, .fai]}
  snp_sites: {type: File, secondaryFiles: [.idx]}
  vqsr_vcf: {type: File, secondaryFiles: [.tbi]}
  ped: File
  output_basename: string
outputs:
  output:
    type: File
    outputBinding:
      glob: '*.vcf.gz'
    secondaryFiles: [.tbi]
