cwlVersion: v1.0
class: CommandLineTool
id: kfdrc-sv2-sv-tool
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: 3000
  - class: DockerRequirement
    dockerPull: 'migbro/sv2:latest'
  - class: MultipleInputFeatureRequirement
baseCommand: ["/bin/bash", "-c"]
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      set -eo pipefail

      tar -xzf $(inputs.sv2_ref.path)
      && /seq_cache_populate.pl
      -root $PWD/ref_cache
      $(inputs.reference.path)
      && export REF_CACHE=$PWD/ref_cache/%2s/%2s/%s
      && cp /usr/local/lib/python2.7/dist-packages/sv2/config/sv2.ini ./
      && sed -i "s,sv2_resource = None,sv2_resource = $PWD," ./sv2.ini
      && sed -i "s,hg38 = None,hg38 = $(inputs.reference.path)," ./sv2.ini
      && cp /usr/local/lib/python2.7/dist-packages/sv2/resources/training_sets/*.pkl .
      && sv2 -snv $(inputs.snv_vcf.path) -p $(inputs.ped.path) -g hg38 -ini ./sv2.ini -i
  - position: 1
    shellQuote: false
    valueFrom: |
      ${
        var bams = inputs.input_cram[0].path
        for (var i = 1; i < inputs.input_cram.length; i++){
          bams += " "+inputs.input_cram[i].path
        }
        return bams
      }
  - position: 2
    shellQuote: false
    valueFrom: >-
      -v
  - position: 3
    shellQuote: false
    valueFrom: |
      ${
        var vcfs = inputs.sv_vcf[0].path
        for (var i = 1; i < inputs.sv_vcf.length; i++){
          vcfs += " "+inputs.sv_vcf[i].path
        }
        return vcfs
      }
  - position: 4
    shellQuote: false
    valueFrom: >-
      && cat sv2_genotypes/sv2_genotypes.vcf
      | bgzip -c > $(inputs.output_basename)_sv2_genotypes.vcf.gz
      && tabix $(inputs.output_basename)_sv2_genotypes.vcf.gz
      && mv sv2_genotypes/sv2_genotypes.txt $(inputs.output_basename)_sv2_genotypes.txt
inputs:
  reference: { type: File, secondaryFiles: [.fai] }
  input_cram:
    type:
      type: array
      items: File
    secondaryFiles:
      - .crai
  sv_vcf:
    type:
      type: array
      items: File
    secondaryFiles:
      - .tbi
  snv_vcf: { type: File, secondaryFiles: [.tbi] }
  ped: File
  output_basename: string
  sv2_ref: File

outputs:
  out_vcf:
    type: File
    outputBinding:
      glob: '*.vcf.gz'
    secondaryFiles: [.tbi]
  out_txt:
    type: File
    outputBinding:
      glob: '*.txt'
