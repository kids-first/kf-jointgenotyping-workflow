cwlVersion: v1.2
class: CommandLineTool
id: bcftools_view
doc: |
  BCFTOOLS view
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.ram*1000)
    coresMin: $(inputs.cpu)
  - class: DockerRequirement
    dockerPull: 'staphb/bcftools:1.19'
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >
      bcftools view

inputs:
  # Required Inputs
  input_vcf: { type: 'File', inputBinding: { position: 9 }, doc: "VCF files to concat, sort, and optionally index" }
  output_filename: { type: 'string', inputBinding: { position: 2, prefix: "--output-file"}, doc: "output file name [stdout]" }

  # View Generic Arguments
  write_index: { type: 'boolean?', inputBinding: { position: 2, prefix: "--write-index" }, doc: "Automatically index the output file" }
  drop_genotypes: { type: 'boolean?', inputBinding: { position: 2, prefix: "--drop-genotypes"}, doc: "drop individual genotype information (after subsetting if -s option set)" }
  header_only: { type: 'boolean?', inputBinding: { position: 2, prefix: "--header-only"}, doc: "print the header only in VCF output" }
  no_header: { type: 'boolean?', inputBinding: { position: 2, prefix: "--no-header"}, doc: "suppress the header in VCF output" }
  compression_level: { type: 'int?', inputBinding: { position: 2, prefix: "--compression-level"}, doc: "compression level: 0 uncompressed, 1 best speed, 9 best compression [-1]" }
  no_version_view: { type: 'boolean?', inputBinding: { position: 2, prefix: "--no-version"}, doc: "do not append version and command line to the header" }
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
  regions_view: { type: 'string?', inputBinding: { position: 2, prefix: "--regions"}, doc: "restrict to comma-separated list of regions" }
  regions_file_view: { type: 'File?', inputBinding: { position: 2, prefix: "--regions-file"}, doc: "restrict to regions listed in a file" }
  regions_overlap:
    type:
      - 'null'
      - type: enum
        name: regions_overlap
        symbols: ["0", "1", "2"]
    inputBinding:
      prefix: "--regions-overlap"
      position: 2
    doc: |
      Include if POS in the region (0), record overlaps (1), variant overlaps (2)
  targets: { type: 'string?', inputBinding: { position: 2, prefix: "--targets"}, doc: "similar to --regions but streams rather than index-jumps. Exclude regions with '^' prefix" }
  targets_file_include: { type: 'File?', inputBinding: { position: 2, prefix: "--targets-file"}, doc: "similar to --regions-file but streams rather than index-jumps." }
  targets_file_exclude: { type: 'File?', inputBinding: { position: 2, prefix: "--targets-file ^", separate: false, shellQuote: false }, doc: "similar to --regions-file but streams rather than index-jumps. Excludes regions in file" }
  targets_overlap:
    type:
      - 'null'
      - type: enum
        name: targets_overlap
        symbols: ["0", "1", "2"]
    inputBinding:
      prefix: "--targets-overlap"
      position: 2
    doc: |
      Include if POS in the region (0), record overlaps (1), variant overlaps (2)

  # View Subset Arguments
  trim_alt_alleles: { type: 'boolean?', inputBinding: { position: 2, prefix: "--trim-alt-alleles"}, doc: "trim ALT alleles not seen in the genotype fields (or their subset with -s/-S)" }
  no_update: { type: 'boolean?', inputBinding: { position: 2, prefix: "--no-update"}, doc: "do not (re)calculate INFO fields for the subset (currently INFO/AC and INFO/AN)" }
  samples: { type: 'string?', inputBinding: { position: 2, prefix: "--samples"}, doc: "comma separated list of samples to include (or exclude with '^' prefix)" }
  samples_file_include: { type: 'File?', inputBinding: { position: 2, prefix: "--samples-file"}, doc: "file of samples to include" }
  samples_file_exclude: { type: 'File?', inputBinding: { position: 2, prefix: "--samples-file ^", separate: false, shellQuote: false }, doc: "file of samples to exclude" }
  force_samples: { type: 'boolean?', inputBinding: { position: 2, prefix: "--force-samples"}, doc: "only warn about unknown subset samples" }

  # View Filter Arguments
  min_ac: { type: 'string?', inputBinding: { position: 2, prefix: "--min-ac"}, doc: "minimum count for non-reference (nref), 1st alternate (alt1), least frequent (minor), most frequent (major) or sum of all but most frequent (nonmajor) alleles [nref]" }
  max_ac: { type: 'string?', inputBinding: { position: 2, prefix: "--max-ac"}, doc: "maximum count for non-reference (nref), 1st alternate (alt1), least frequent (minor), most frequent (major) or sum of all but most frequent (nonmajor) alleles [nref]" }
  apply_filters: { type: 'string?', inputBinding: { position: 2, prefix: "--apply-filters"}, doc: "require at least one of the listed FILTER strings (e.g. 'PASS,.)'" }
  genotype: { type: 'string?', inputBinding: { position: 2, prefix: "--genotype"}, doc: "require one or more hom/het/missing genotype or, if prefixed with '^', exclude sites with hom/het/missing genotypes" }
  include: { type: 'string?', inputBinding: { position: 2, prefix: "--include"}, doc: "include sites for which the expression is true (see man page for details)" }
  exclude: { type: 'string?', inputBinding: { position: 2, prefix: "--exclude"}, doc: "exclude sites for which the expression is true (see man page for details)" }
  known: { type: 'boolean?', inputBinding: { position: 2, prefix: "--known"}, doc: "select known sites only (ID is not/is '.')" }
  novel: { type: 'boolean?', inputBinding: { position: 2, prefix: "--novel"}, doc: "select novel sites only (ID is not/is '.')" }
  min_alleles: { type: 'int?', inputBinding: { position: 2, prefix: "--min-alleles"}, doc: "minimum number of alleles listed in REF and ALT (e.g. -m2 -M2 for biallelic sites)" }
  max_alleles: { type: 'int?', inputBinding: { position: 2, prefix: "--max-alleles"}, doc: "maximum number of alleles listed in REF and ALT (e.g. -m2 -M2 for biallelic sites)" }
  phased: { type: 'boolean?', inputBinding: { position: 2, prefix: "--phased"}, doc: "select sites where all samples are phased" }
  exclude_phased: { type: 'boolean?', inputBinding: { position: 2, prefix: "--exclude-phased"}, doc: "exclude sites where all samples are phased" }
  min_af: { type: 'string?', inputBinding: { position: 2, prefix: "--min-af"}, doc: "minimum frequency for non-reference (nref), 1st alternate (alt1), least frequent (minor), most frequent (major) or sum of all but most frequent (nonmajor) alleles [nref]" }
  max_af: { type: 'string?', inputBinding: { position: 2, prefix: "--max-af"}, doc: "maximum frequency for non-reference (nref), 1st alternate (alt1), least frequent (minor), most frequent (major) or sum of all but most frequent (nonmajor) alleles [nref]" }
  uncalled: { type: 'boolean?', inputBinding: { position: 2, prefix: "--uncalled"}, doc: "select sites without a called genotype" }
  exclude_uncalled: { type: 'boolean?', inputBinding: { position: 2, prefix: "--exclude-uncalled"}, doc: "select sites without a called genotype" }
  include_variant_types: { type: 'string?', inputBinding: { position: 2, prefix: "--types"}, doc: "select comma-separated list of variant types: snps,indels,mnps,ref,bnd,other" }
  exclude_variant_types: { type: 'string?', inputBinding: { position: 2, prefix: "--exclude-types"}, doc: "exclude comma-separated list of variant types: snps,indels,mnps,ref,bnd,other [null]" }
  private: { type: 'boolean?', inputBinding: { position: 2, prefix: "--private"}, doc: "select sites where the non-reference alleles are exclusive (private) to the subset samples" }
  exclude_private: { type: 'boolean?', inputBinding: { position: 2, prefix: "--exclude-private"}, doc: "exclude sites where the non-reference alleles are exclusive (private) to the subset samples" }

  cpu: { type: 'int?', default: 4, doc: "Number of CPUs to allocate to this task.", inputBinding: { position: 2, prefix: "--threads" } }
  ram: { type: 'int?', default: 16, doc: "GB size of RAM to allocate to this task." }
outputs:
  output:
    type: 'File'
    secondaryFiles: [{pattern: '.tbi', required: false}, {pattern: '.csi', required: false}]
    outputBinding:
      glob: "*.{v,b}cf{,.gz}"
