cwlVersion: v1.0
class: CommandLineTool
id: gatk_hardfiltermakesitesonlyvcf
requirements:
  - class: DockerRequirement
    dockerPull: 'kfdrc/gatk4-picard:4.beta.1-2.8.3'
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: 3500
    coresMin: 1
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      /gatk-launch --javaOptions "-Xmx3g -Xms3g"
      VariantFiltration
      --filterExpression "ExcessHet > 54.69"
      --filterName ExcessHet
      -O variant_filtered.vcf.gz
      -V $(inputs.vcf.path)

      java -Xmx3g -Xms3g -jar /picard.jar
      MakeSitesOnlyVcf
      INPUT=variant_filtered.vcf.gz
      OUTPUT=sites_only.variant_filtered.vcf.gz
inputs:
  vcf:
    type: File
    secondaryFiles: [.tbi]
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
