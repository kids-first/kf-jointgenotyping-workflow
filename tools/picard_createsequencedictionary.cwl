cwlVersion: v1.0
class: CommandLineTool
id: picard_createsequencedictionary
requirements:
  - class: DockerRequirement
    dockerPull: 'kfdrc/gatk:4.1.7.0R'
  - class: InitialWorkDirRequirement
    listing: [$(inputs.input_fasta),$(inputs.input_dict)]
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
  - class: ShellCommandRequirement
baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      $(inputs.input_dict ? 'echo java -jar /gatk-package-4.1.7.0-local.jar' : 'java -jar /gatk-package-4.1.7.0-local.jar' )
  - position: 1
    shellQuote: false
    valueFrom: >-
      CreateSequenceDictionary
inputs:
  input_fasta:
    type: File
    inputBinding:
      position: 2
      prefix: "-R"
  input_dict:
    type: 'File?'
outputs:
  dict:
    type: File
    outputBinding:
      glob: "*.dict" 
