cwlVersion: v1.0
class: CommandLineTool
id: gatk_importgvcfs
requirements:
  - class: DockerRequirement
    dockerPull: 'kfdrc/gatk:4.beta.1'
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: 4000
    coresMin: 5
baseCommand: [set, -e]
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-

      rm -rf $(inputs.workspace_dir_name)

      /gatk-launch --javaOptions "-Xmx4g -Xms4g"
      GenomicsDBImport
      --genomicsDBWorkspace $(inputs.workspace_dir_name)
      --batchSize $(inputs.batch_size)
      -L $(inputs.interval.path)
      --sampleNameMap $(inputs.sample_name_map.path)
      --readerThreads 5
      -ip 5 && tar -cf $(inputs.workspace_dir_name).tar $(inputs.workspace_dir_name)
inputs:
  workspace_dir_name:
    type: string
  batch_size:
    type: int
  interval:
    type: File
  sample_name_map:
    type: File
outputs:
  output:
    type: File
    outputBinding:
      glob: $(inputs.workspace_dir_name).tar
