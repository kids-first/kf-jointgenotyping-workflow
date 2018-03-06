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
      -O $(inputs.variant_filtered_vcf_filename)
      -V $(inputs.vcf.path)

      java -Xmx3g -Xms3g -jar /picard.jar
      MakeSitesOnlyVcf
      INPUT=$(inputs.variant_filtered_vcf_filename)
      OUTPUT=$(inputs.sites_only_vcf_filename)
inputs:
  variant_filtered_vcf_filename: string
  sites_only_vcf_filename: string
  vcf:
    type: File
    secondaryFiles: [.tbi]
outputs:
  variant_filtered_vcf:
    type: File
    outputBinding:
      glob: $(inputs.variant_filtered_vcf_filename)
    secondaryFiles: [.tbi]
  sites_only_vcf:
    type: File
    outputBinding:
      glob: $(inputs.sites_only_vcf_filename)
    secondaryFiles: [.tbi]
