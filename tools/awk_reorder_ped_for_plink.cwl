cwlVersion: v1.2
class: CommandLineTool
id: awk_ped_to_fam
doc: |
  Use the fam from plink to properly order the provided PED file.
  Return the output as a fam for use with future plink steps.
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
baseCommand: []
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >
      awk '{print $2}' $(inputs.input_fam.path)
      | while read line;
      do awk -v var="$line" '$2 == var {print $0}' $(inputs.input_ped.path) >> $(inputs.input_fam.basename);
      done
inputs:
  input_fam: { type: 'File' }
  input_ped: { type: 'File' }
outputs:
  output_fam:
    type: File
    outputBinding:
      glob: '*.fam'
