cwlVersion: v1.0
class: CommandLineTool
id: tabix_index 
doc: >-
  This tool will run tabix conditionally dependent on whether an index is provided.
  The tool will output the input_file with the index, provided or created within, as a secondary file.
requirements:
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'kfdrc/samtools:1.9'
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
  - class: InitialWorkDirRequirement
    listing: [$(inputs.input_file),$(inputs.input_index)]

baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      $(inputs.input_index ? 'echo tabix' : 'tabix')

inputs:
  input_file: { type: 'File', doc: "Position sorted and compressed by bgzip input file", inputBinding: { position: 1, shellQuote: false } }
  input_index: { type: 'File?', doc: "Index file for the input_file, if one exists" }

outputs:
  output: 
    type: File
    outputBinding:
      glob: $(inputs.input_file.basename) 
    secondaryFiles: [.tbi]
