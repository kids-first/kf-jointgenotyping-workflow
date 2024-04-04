cwlVersion: v1.2
class: CommandLineTool
id: bcftools_merge
doc: |
  BCFTOOLS merge
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.ram*1000)
    coresMin: $(inputs.cpu)
  - class: DockerRequirement
    dockerPull: 'staphb/bcftools:1.19'
  - class: InitialWorkDirRequirement
    listing:
      - entryname: files_to_merge.txt
        entry:
          $(inputs.input_vcfs.map(function(e) { return e.path }).join('\n'))
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >
      bcftools merge --file-list files_to_merge.txt

inputs:
  # Required Inputs
  input_vcfs: { type: 'File[]', secondaryFiles: [{pattern: ".tbi", required: true}], doc: "Two or more VCF files to merge." }
  output_filename: { type: 'string', inputBinding: { position: 2, prefix: "--output"}, doc: "output file name" }

  # Merge Arguments
  write_index: { type: 'boolean?', inputBinding: { position: 2, prefix: "--write-index" }, doc: "Automatically index the output file" }
  force_samples: { type: 'boolean?', inputBinding: { position: 2, prefix: "--force-samples"}, doc: "resolve duplicate sample names" }
  print_header: { type: 'boolean?', inputBinding: { position: 2, prefix: "--print-header"}, doc: "print only the merged header and exit" }
  use_header: { type: 'File?', inputBinding: { position: 2, prefix: "--use-header"}, doc: "use the provided header" }
  missing_to_ref: { type: 'boolean?', inputBinding: { position: 2, prefix: "--missing-to-ref"}, doc: "assume genotypes at missing sites are 0/0" }
  apply_filters: { type: 'string?', inputBinding: { position: 2, prefix: "--apply-filters"}, doc: "require at least one of the listed FILTER strings (e.g. 'PASS,.')" }
  filter_logic:
    type:
      - 'null'
      - type: enum
        name: filter_logic
        symbols: ["x", "+"]
    inputBinding:
      prefix: "--filter-logic"
      position: 2
    doc: |
      remove filters if some input is PASS ('x'), or apply all filters ('+')
  gvcf: { type: 'File?', inputBinding: { position: 2, prefix: "--gvcf"}, doc: "merge gVCF blocks, INFO/END tag is expected. Implies -i QS:sum,MinDP:min,I16:sum,IDV:max,IMF:max. Provide a reference fasta." }
  info_rules: { type: 'string?', inputBinding: { position: 2, prefix: "--info-rules"}, doc: "rules for merging INFO fields (method is one of sum,avg,min,max,join) or '-' to turn off the default [DP:sum,DP4:sum]" }
  file_list: { type: 'File?', inputBinding: { position: 2, prefix: "--file-list"}, doc: "read file names from the file" }
  no_version: { type: 'boolean?', inputBinding: { position: 2, prefix: "--no-version"}, doc: "do not append version and command line to the header" }
  regions: { type: 'string?', inputBinding: { position: 2, prefix: "--regions"}, doc: "restrict to comma-separated list of regions" }
  regions_file: { type: 'File?', inputBinding: { position: 2, prefix: "--regions-file"}, doc: "restrict to regions listed in a file" }
  merge:
    type:
      - 'null'
      - type: enum
        name: merge
        symbols: ["snps","indels","both","all","some","id"]
    inputBinding:
      prefix: "--merge"
      position: 2
    doc: |
      allow multiallelic records for <snps|indels|both|all|none|id>, see man page for details
  output_type:
    type:
      - 'null'
      - type: enum
        name: output_type
        symbols: ["b", "u", "v", "z"]
    inputBinding:
      prefix: "--output-type"
      position: 2
    doc: |
      b: compressed BCF, u: uncompressed BCF, z: compressed VCF, v: uncompressed VCF [v]

  cpu: { type: 'int?', default: 2, doc: "Number of CPUs to allocate to this task.", inputBinding: { prefix: "--threads", position: 2 } }
  ram: { type: 'int?', default: 4, doc: "GB size of RAM to allocate to this task." }
outputs:
  merge_file_list:
    type: 'File'
    outputBinding:
      glob: "files_to_merge.txt"
  output:
    type: 'File'
    secondaryFiles: [{pattern: '.tbi', required: false}, {pattern: '.csi', required: false}]
    outputBinding:
      glob: "*.{v,b}cf{,.gz}"
