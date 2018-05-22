cwlVersion: v1.0
class: CommandLineTool
id: gatk_importgvcfs
requirements:
  - class: DockerRequirement
    dockerPull: 'broadinstitute/gatk:4.beta.5'
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: 4000
    coresMin: 5
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      /gatk/gatk-launch --javaOptions "-Xmx4g -Xms4g"
      GenomicsDBImport
      --genomicsDBWorkspace genomicsdb
      --batchSize 50
      -L $(inputs.interval.path)
      --readerThreads 5
      -ip 5
  - position: 2
    shellQuote: false
    valueFrom: >-
      && tar -cf genomicsdb.tar genomicsdb
inputs:
  interval: File
  gvcf:
    type:
      type: array
      items: File
      inputBinding:
        prefix: -V
    secondaryFiles: [.tbi]
    inputBinding:
      position: 1
outputs:
  output:
    type: File
    outputBinding:
      glob: genomicsdb.tar