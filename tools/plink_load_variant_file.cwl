class: CommandLineTool
cwlVersion: v1.2
id: plink_load_variant_file
doc: |-
  Create a plink file from a VCF/BCF
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
      $(inputs.biallelic_only != null ? "--biallelic-only" : "")
inputs:
  input_vcf: { type: 'File?', inputBinding: { position: 2, prefix: "--vcf" }, doc: "Input VCF file. Can be bgzipped." }
  input_bcf: { type: 'File?', inputBinding: { position: 2, prefix: "--bcf" }, doc: "Input BCF file. Can be bgzipped." }
  output_basename: { type: 'string?', default: "plink", inputBinding: { position: 2, prefix: "--out"}, doc: "Basename for plink binary files." }
  double_id: { type: 'boolean?', inputBinding: { position: 2, prefix: "--double-id" }, doc: "causes both family and within-family IDs to be set to the sample ID" }
  const_fid: { type: 'string?', inputBinding: { position: 2, prefix: "--const-fid" }, doc: "converts sample IDs to within-family IDs while setting all family IDs to a single value" }
  id_delim: { type: 'string?', inputBinding: { position: 2, prefix: "--id-delim" }, doc: "causes sample IDs to be parsed as <FID><delimiter><IID>" }
  vcf_idspace_to: { type: 'string?', inputBinding: { position: 2, prefix: "--vcf-idspace-to" }, doc: "convert all spaces in sample IDs to this character" }
  biallelic_only:
    type:
      - 'null'
      - type: record
        fields:
          - name: "strict"
            type: boolean?
            doc: "indiscriminately skip variants with 2+ alternate alleles listed even when only one alternate allele actually shows up"
            inputBinding:
              prefix: "strict"
          - name: "list"
            type: boolean?
            doc: "dump a list of skipped variant IDs to plink.skip.3allele"
            inputBinding:
              prefix: "list"
    inputBinding:
      position: 4
    doc: "Use to skip all variants where at least two alternate alleles are present in the dataset."
  vcf_min_qual: { type: 'float?', inputBinding: { position: 2, prefix: "--vcf-min-qual" }, doc: "causes all variants with QUAL value smaller than the given number, or with no QUAL value at all, to be skipped" }
  vcf_filter: { type: 'string[]?', inputBinding: { position: 2, prefix: "--vcf-filter" }, doc: "skip variants which failed one or more filters tracked by the FILTER field" }
  vcf_require_gt: { type: 'boolean?', inputBinding: { position: 2, prefix: "--vcf-require-gt" }, doc: "Skip variants with missing GT fields." }
  vcf_min_gp: { type: 'float?', inputBinding: { position: 2, prefix: "--vcf-min-gp" }, doc: "excludes all genotype calls with GP value below the given threshold" }
  vcf_min_gq: { type: 'float?', inputBinding: { position: 2, prefix: "--vcf-min-gq" }, doc: "excludes all genotype calls with GQ below the given (nonnegative, decimal values permitted) threshold" }
  vcf_half_call: { type: ['null', { type: enum, name: "vcf_half_call", symbols: ["error", "haploid", "missing", "reference"]}], inputBinding: { position: 2, prefix: "--vcf-half-call" }, doc: "specify how '0/.' and similar GT values should be interpreted. Error: PLINK 1.9 errors out and reports the line number of the anomaly. Haploid: Treat half-calls as haploid/homozygous. Missing: Treat half-calls as missing. Reference: Treat the missing part as reference." }

  cpu: { type: 'int?', default: 4, doc: "Number of CPUs to allocate to this task." }
  ram: { type: 'int?', default: 8, doc: "GB size of RAM to allocate to this task." }
outputs:
  bim:
    type: File
    outputBinding:
      glob: '*.bim'
  bed:
    type: File
    outputBinding:
      glob: '*.bed'
  fam:
    type: File
    outputBinding:
      glob: '*.fam'
  log:
    type: File
    outputBinding:
      glob: '*.log'
  skip_3allele:
    type: File?
    outputBinding:
      glob: '*.skip.3allele'
  catchall_out:
    type: File[]?
    outputBinding:
      glob: $(inputs.output_basename)*
