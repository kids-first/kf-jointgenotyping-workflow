cwlVersion: v1.0
class: CommandLineTool
id: gatk_hardfiltermakesitesonlyvcf
requirements:
  - class: DockerRequirement
    dockerPull: 'kfdrc/gatk:4.beta.1-2.8.3'
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
      set -e

      /gatk-launch --javaOptions "-Xmx3g -Xms3g"
      VariantFiltration
      --filterExpression "ExcessHet > $(inputs.excess_het_threshold)"
      --filterName ExcessHet
      -O $(inputs.variant_filtered_vcf_filename)
      -V $(inputs.vcf.path)

      WORKSPACE=`basename $(inputs.workspace_tar.path) .tar)`

      java -Xmx3g -Xms3g -jar /usr/gitc/picard.jar
      MakeSitesOnlyVcf
      INPUT=$(inputs.variant_filtered_vcf_filename)
      OUTPUT=$(inputs.sites_only_vcf_filename)
inputs:
  excess_het_threshold:
    type: float
  variant_filtered_vcf_filename:
    type: string
  vcf:
    type: File
    secondaryFiles: [.tbi]
  sites_only_vcf_filename:
    type: string
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
