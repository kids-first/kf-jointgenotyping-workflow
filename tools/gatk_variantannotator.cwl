cwlVersion: v1.0
class: CommandLineTool
id: kfdrc-gatk_variantannotator
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: 8000
    coresMin: 2
    coresMax: 4
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/gatk:3.8_ubuntu'
baseCommand: [java]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      -Xms7447m
      -Xmx7447m
      -XX:GCTimeLimit=50
      -XX:GCHeapFreeLimit=10
      -jar /GenomeAnalysisTK.jar
      -T VariantAnnotator
      -R $(inputs.reference_fasta.path)
      -o $(inputs.output_basename).postCGP.Gfiltered.deNovos.vcf.gz
      -V $(inputs.cgp_filtered_vcf.path)
      -A PossibleDeNovo
      -ped $(inputs.ped.path)
      --pedigreeValidationType STRICT

inputs:
  reference_fasta: {type: File, secondaryFiles: [^.dict, .fai]}
  cgp_filtered_vcf: {type: File, secondaryFiles: [.tbi]}
  ped: File
  output_basename: string
outputs:
  output:
    type: File
    outputBinding:
      glob: '*.vcf.gz'
    secondaryFiles: [.tbi]
