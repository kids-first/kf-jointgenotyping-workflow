cwlVersion: v1.0
class: ExpressionTool
id: expression_inputvcfnum
requirements:
  - class: InlineJavascriptRequirement

inputs:
  input_vcfs:
    type: File[]

outputs:
  input_vcfs_num:
    type: int
    outputBinding:
      valueFrom: $(inputs.input_vcfs.length)
