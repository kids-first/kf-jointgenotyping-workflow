cwlVersion: v1.2
class: Workflow
id: plink
doc: |
  Plink subworkflow. Loads a VCF then runs genome and sexchecks on it.
requirements:
- class: ScatterFeatureRequirement
- class: MultipleInputFeatureRequirement
- class: InlineJavascriptRequirement
- class: StepInputExpressionRequirement
inputs:
  input_vcf: { type: 'File' }
  input_ped: { type: 'File?' }
  output_basename: {type: 'string', doc: "String value to use as basename for outputs"}

  genome: { type: ['null', { type: enum, name: "genome", symbols: ["base", "gz", "rel-check", "full", "unbounded", "nudge"]}], doc: "invokes an IBS/IBD computation. The 'full' modifier adds additional fields. The 'gz' modifier causes the output to be gzipped, while 'rel-check' removes pairs of samples with different FIDs.  The 'unbounded' modifier turns off clipping. Nudge 'nudge' modifier adjusts the final estimates" }

  # Resource Requirements
  plink_cpu: {type: 'int?', doc: "CPUs to allocate to plink"}
  plink_ram: {type: 'int?', doc: "RAM in GB to allocate to plink"}

outputs:
  genome_out: {type: 'File?', outputSource: plink_process_binary/genome_out }
  sexcheck_out: {type: 'File', outputSource: plink_process_binary/sexcheck_out }

steps:
  plink_load_variant_file:
    run: ../tools/plink_load_variant_file.cwl
    in:
      input_vcf: input_vcf
      output_basename: output_basename
      const_fid:
        valueFrom: "placeholder"
      cpu: plink_cpu
      ram: plink_ram
    out: [bim, bed, fam, log, skip_3allele]

  awk_reorder_ped_for_plink:
    run: ../tools/awk_reorder_ped_for_plink.cwl
    when: $(inputs.input_ped != null)
    in:
      input_fam: plink_load_variant_file/fam
      input_ped: input_ped
    out: [output_fam]

  plink_process_binary:
    run: ../tools/plink_process_binary.cwl
    in:
      input_bim: plink_load_variant_file/bim
      input_bed: plink_load_variant_file/bed
      input_fam:
        source: [awk_reorder_ped_for_plink/output_fam, plink_load_variant_file/fam]
        pickValue: first_non_null
      output_basename: output_basename
      genome: genome
      check_sex:
        valueFrom: "base"
      cpu: plink_cpu
      ram: plink_ram
    out: [genome_out, sexcheck_out, mendel_out, catchall_out]

$namespaces:
  sbg: https://sevenbridges.com
"sbg:license": Apache License 2.0
"sbg:publisher": KFDRC
