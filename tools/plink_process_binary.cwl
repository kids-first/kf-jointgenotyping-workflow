class: CommandLineTool
cwlVersion: v1.2
id: plink_process_binary
doc: |-
  Process a plink binary file
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/plink:1.90b7.2'
  - class: ResourceRequirement
    ramMin: $(inputs.ram*1000)
    coresMin: $(inputs.cpu)
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      plink
  - position: 3
    shellQuote: false
    valueFrom: >-
      $(inputs.genome != null ? "--genome" : "")
  - position: 5
    shellQuote: false
    valueFrom: >-
      $(inputs.check_sex != null ? "--check-sex" : "")
  - position: 7
    shellQuote: false
    valueFrom: >-
      $(inputs.mendel != null ? "--mendel": "")
inputs:
  input_bed: { type: 'File', inputBinding: { position: 2, prefix: "--bed" }, doc: "Binary BED file for plink." }
  input_bim: { type: 'File', inputBinding: { position: 2, prefix: "--bim" }, doc: "Binary BIM file for plink." }
  input_fam: { type: 'File', inputBinding: { position: 2, prefix: "--fam" }, doc: "Binary FAM file for plink." }
  output_basename: { type: 'string?', default: "plink", inputBinding: { position: 2, prefix: "--out"}, doc: "Basename for plink binary files." }

  # GENOME
  genome:
    type:
      - 'null'
      - type: record
        fields:
          - name: "gz"
            type: boolean?
            doc: "output to be gzipped"
            inputBinding:
              prefix: "gz"
          - name: "full"
            type: boolean?
            doc: "adds additional fields"
            inputBinding:
              prefix: "full"
          - name: "rel-check"
            type: boolean?
            doc: "removes pairs of samples with different FIDs"
            inputBinding:
              prefix: "rel-check"
          - name: "unbounded"
            type: boolean?
            doc: "turns off clipping"
            inputBinding:
              prefix: "unbounded"
          - name: "nudge"
            type: boolean?
            doc: "adjusts the final estimates"
            inputBinding:
              prefix: "nudge"
    inputBinding:
      position: 4
    doc: "invokes an IBS/IBD computation"
  ppc_gap: { type: 'int?', inputBinding: { position: 2, prefix: "--ppc-gap" }, doc: "minimum distance between informative pairs of SNPs used in the pairwise population concordance (PPC) test in kilobases" }
  min_pi_hat: { type: 'float?', inputBinding: { position: 2, prefix: "--min" }, doc: "Minimum pi hat value to be included in the final output." }
  max_pi_hat: { type: 'float?', inputBinding: { position: 2, prefix: "--max" }, doc: "Maximum pi hat value to be included in the final output." }

  # SEX CHECK
  check_sex:
    type:
      - 'null'
      - type: record
        fields:
          - name: "full"
            type: boolean?
            doc: "gender is still imputed from the X chromosome, but female calls are downgraded to ambiguous whenever more than 0 nonmissing Y genotypes are present, and male calls are downgraded when fewer than 0 are present"
            inputBinding:
              prefix: "full"
          - name: "y-only"
            type: boolean?
            doc: "gender is imputed from nonmissing Y genotype counts, and the X chromosome is ignored"
            inputBinding:
              prefix: "y-only"
    inputBinding:
      position: 6
    doc: "compares sex assignments in the input dataset with those imputed from X chromosome inbreeding coefficients"
  # MENDEL and more
  mendel:
    type:
      - 'null'
      - type: record
        fields:
          - name: "summaries-only"
            type: boolean?
            doc: "Only provide summary statistics"
            inputBinding:
              prefix: "summaries-only"
    inputBinding:
      position: 8
    doc: "scans the dataset for Mendel errors"
  additional_args: { type: 'string[]?', inputBinding: { position: 2, shellQuote: false }, doc: "Any additonal args for plink. There are a lot..." }

  cpu: { type: 'int?', default: 4, doc: "Number of CPUs to allocate to this task." }
  ram: { type: 'int?', default: 8, doc: "GB size of RAM to allocate to this task." }
outputs:
  genome_out:
    type: File?
    outputBinding:
      glob: '*.genome{,.gz}'
  sexcheck_out:
    type: File?
    outputBinding:
      glob: '*.sexcheck'
  mendel_out:
    type: File[]?
    outputBinding:
      glob: '*{.mendel,.imendel,.fmendel,.lmendel}'
  catchall_out:
    type: File[]?
    outputBinding:
      glob: $(inputs.output_basename)*
