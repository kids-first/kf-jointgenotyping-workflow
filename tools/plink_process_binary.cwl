class: CommandLineTool
cwlVersion: v1.2
id: plink_process_binary
doc: |-
  Process a plink binary file
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/danmiller/plink:1.90-b7.2'
  - class: ResourceRequirement
    ramMin: $(inputs.ram*1000)
    coresMin: $(inputs.cpu)
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >
      plink
inputs:
  input_bed: { type: 'File', inputBinding: { position: 2, prefix: "--bed" }, doc: "Binary BED file for plink." }
  input_bim: { type: 'File', inputBinding: { position: 2, prefix: "--bim" }, doc: "Binary BIM file for plink." }
  input_fam: { type: 'File', inputBinding: { position: 2, prefix: "--fam" }, doc: "Binary FAM file for plink." }
  output_basename: { type: 'string?', default: "plink", inputBinding: { position: 2, prefix: "--out"}, doc: "Basename for plink binary files." }

  # GENOME
  genome: { type: ['null', { type: enum, name: "genome", symbols: ["base", "gz", "rel-check", "full", "unbounded", "nudge"]}], inputBinding: { position: 2, prefix: "--genome", shellQuote: false, valueFrom: "$(self == 'base' ? '' : self)" }, doc: "invokes an IBS/IBD computation. The 'full' modifier adds additional fields. The 'gz' modifier causes the output to be gzipped, while 'rel-check' removes pairs of samples with different FIDs.  The 'unbounded' modifier turns off clipping. Nudge 'nudge' modifier adjusts the final estimates" }
  ppc_gap: { type: 'int?', inputBinding: { position: 2, prefix: "--ppc-gap" }, doc: "minimum distance between informative pairs of SNPs used in the pairwise population concordance (PPC) test in kilobases" }
  min_pi_hat: { type: 'float?', inputBinding: { position: 2, prefix: "--min" }, doc: "Minimum pi hat value to be included in the final output." }
  max_pi_hat: { type: 'float?', inputBinding: { position: 2, prefix: "--max" }, doc: "Maximum pi hat value to be included in the final output." }

  # SEX CHECK
  check_sex: { type: ['null', { type: enum, name: "check_sex", symbols: ["base", "ycount", "y-only"]}], inputBinding: { position: 2, prefix: "--check-sex", shellQuote: false, valueFrom: "$(self == 'base' ? '' : self)" }, doc: "compares sex assignments in the input dataset with those imputed from X chromosome inbreeding coefficients. In 'ycount' mode, gender is still imputed from the X chromosome, but female calls are downgraded to ambiguous whenever more than 0 nonmissing Y genotypes are present, and male calls are downgraded when fewer than 0 are present. In 'y-only' mode, gender is imputed from nonmissing Y genotype counts, and the X chromosome is ignored." }

  # MENDEL and more
  mendel: { type: ['null', { type: enum, name: "mendel", symbols: ["base", "summaries-only"]}], inputBinding: { position: 2, prefix: "--mendel", valueFrom: "$(self == 'base' ? '' : self)" }, doc: "scans the dataset for Mendel errors. If you only want summary statistics, use the 'summaries-only' modifier." }
  additional_args: { type: 'string[]?', inputBinding: { position: 2, shellQuote: false }, doc: "Any additonal args for plink. There are a lot..." }

  cpu:
    type: 'int?'
    default: 4
    doc: "Number of CPUs to allocate to this task."
  ram:
    type: 'int?'
    default: 8
    doc: "GB size of RAM to allocate to this task."

outputs:
  genome_out:
    type: File?
    outputBinding:
      glob: '*.genome'
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
