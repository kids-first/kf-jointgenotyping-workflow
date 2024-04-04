cwlVersion: v1.2
class: Workflow
id: plink
doc: |
  Plink subworkflow. Loads a VCF then runs genome identity-by-descent analysis on it.
requirements:
- class: ScatterFeatureRequirement
- class: MultipleInputFeatureRequirement
- class: InlineJavascriptRequirement
- class: StepInputExpressionRequirement
inputs:
  input_vcfs: { type: 'File[]' }
  genome_target_sites: { type: 'File?', doc: "Target sites for identity-by-descent genome analysis." }
  output_basename: {type: 'string', doc: "String value to use as basename for outputs"}
  genome:
    type:
      - 'null'
      - type: record
        fields:
          - name: "gz"
            type: boolean?
            doc: "output to be gzipped"
          - name: "full"
            type: boolean?
            doc: "adds additional fields"
          - name: "rel-check"
            type: boolean?
            doc: "removes pairs of samples with different FIDs"
          - name: "unbounded"
            type: boolean?
            doc: "turns off clipping"
          - name: "nudge"
            type: boolean?
            doc: "adjusts the final estimates"
    doc: |
      invokes an IBS/IBD computation.
      To turn on, set to empty/not null.
      Additional modifiers can be turned on using the boolean fields.
      gz: output to be gzipped.
      full: adds additional fields to output.
      rel-check: removes pairs of samples with different FIDs.
      unbounded: turns off clipping.
      nudge: adjusts the final estimates.

  # Resource Requirements
  plink_cpu: {type: 'int?', doc: "CPUs to allocate to plink"}
  plink_ram: {type: 'int?', doc: "RAM in GB to allocate to plink"}

outputs:
  genome_out: {type: 'File?', outputSource: plink_process_binary/genome_out }

steps:
  bcftools_view:
    run: ../tools/bcftools_view.cwl
    when: $(inputs.targets_file_include != null)
    scatter: [input_vcf]
    hints:
    - class: sbg:AWSInstanceType
      value: c5.4xlarge
    in:
      input_vcf: input_vcfs
      targets_file_include: genome_target_sites
      output_filename:
        valueFrom: "temp.vcf.gz##idx##temp.vcf.gz.tbi"
      write_index:
        valueFrom: $(1 == 1)
      output_type:
        valueFrom: "z"
      cpu:
        valueFrom: $(1)
      ram:
        valueFrom: $(2)
    out: [output]

  bcftools_merge:
    run: ../tools/bcftools_merge.cwl
    when: $(inputs.run_tool.length > 1)
    in:
      run_tool: input_vcfs
      input_vcfs:
        source: [bcftools_view/output, input_vcfs]
        pickValue: first_non_null
      output_filename:
        valueFrom: "merged.vcf.gz"
      output_type:
        valueFrom: "z"
    out: [output]

  plink_load_variant_file:
    run: ../tools/plink_load_variant_file.cwl
    in:
      input_vcf:
        source: [bcftools_merge/output, bcftools_view/output, input_vcfs]
        valueFrom: |
          $(self[0] != null ? self[0] : self[1] != null && self[1][0] != null ? self[1][0] : self[2][0])
      output_basename: output_basename
      const_fid:
        valueFrom: "FAMID"
      cpu: plink_cpu
      ram: plink_ram
    out: [bim, bed, fam, log, skip_3allele]

  plink_process_binary:
    run: ../tools/plink_process_binary.cwl
    in:
      input_bim: plink_load_variant_file/bim
      input_bed: plink_load_variant_file/bed
      input_fam: plink_load_variant_file/fam
      output_basename: output_basename
      genome: genome
      cpu: plink_cpu
      ram: plink_ram
    out: [genome_out, sexcheck_out, mendel_out, catchall_out]

$namespaces:
  sbg: https://sevenbridges.com
"sbg:license": Apache License 2.0
"sbg:publisher": KFDRC
