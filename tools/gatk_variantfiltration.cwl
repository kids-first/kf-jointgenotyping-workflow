cwlVersion: v1.0
class: CommandLineTool
id: kfdrc-gatk_variantfiltration
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
      VariantFiltration
      -R $(inputs.reference.path)
      -O $(inputs.output_basename).postCGP.Gfiltered.vcf.gz
      -V $(inputs.cgp_vcf.path)
      -G-filter "GQ < 20.0"
      -G-filter-name lowGQ

inputs:
  reference: {type: File, secondaryFiles: [^.dict, .fai]}
  cgp_vcf: {type: File, secondaryFiles: [.tbi]}
  output_basename: string
outputs:
  output:
    type: File
    outputBinding:
      glob: '*.vcf.gz'
    secondaryFiles: [.tbi]
