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
    dockerPull: 'kfdrc/gatk:4.0.12.0'
baseCommand: [/gatk]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      --java-options "-Xms8000m
      -XX:GCTimeLimit=50
      -XX:GCHeapFreeLimit=10"
      CalculateGenotypePosteriors
      -R $(inputs.reference_fasta.path)
      -O $(inputs.output_basename).postCGP.vcf.gz
      -V $(inputs.vqsr_vcf.path)
      --supporting $(inputs.snp_sites.path)
      ${
        var arg = "";
        if (inputs.ped != null){
          arg += " --pedigree " + inputs.ped.path;
        }
        return arg;
      }

inputs:
  reference_fasta: {type: File}
  reference_dict: {type: File}
  reference_fai: {type: File}
  snp_sites: {type: File, secondaryFiles: [.idx]}
  vqsr_vcf: {type: File, secondaryFiles: [.tbi]}
  ped: {type: ['null', File]}
  output_basename: string
outputs:
  output:
    type: File
    outputBinding:
      glob: '*.vcf.gz'
    secondaryFiles: [.tbi]
