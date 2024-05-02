class: CommandLineTool
cwlVersion: v1.2
id: plink_update_ids_with_ped
doc: |-
  Update Plink FAM file with PED file. 
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
      awk -F'\t' -v OLDFAM=$(inputs.original_fam_id) -v OFS=' ' '{print OLDFAM,$2,$1,$2}' $(inputs.input_ped.path) > UPDATE_IDS.tsv
  - position: 10
    shellQuote: false
    prefix: "&&"
    valueFrom: >-
      plink --make-just-fam --update-ids UPDATE_IDS.tsv
inputs:
  input_ped: { type: 'File', doc: "PED file detailing families"} 
  original_fam_id: { type: 'string?', default: "FAMID", doc: "Original family ID assigned to the individuals in the PED file. Only works if they are all the same." }
  input_fam: { type: 'File', inputBinding: { position: 12, prefix: "--fam" }, doc: "Input Plink FAM file." }
  output_basename: { type: 'string?', default: "plink", inputBinding: { position: 12, prefix: "--out"}, doc: "Basename for plink binary files." }

  cpu: { type: 'int?', default: 4, doc: "Number of CPUs to allocate to this task." }
  ram: { type: 'int?', default: 8, doc: "GB size of RAM to allocate to this task." }
outputs:
  fam:
    type: File
    outputBinding:
      glob: '*.fam'
  log:
    type: File
    outputBinding:
      glob: '*.log'
