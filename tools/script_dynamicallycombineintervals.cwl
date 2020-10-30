cwlVersion: v1.0
class: CommandLineTool
id: script_dynamicallycombineintervals
requirements:
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/python:2.7.13'
  - class: InlineJavascriptRequirement
hints:
  - class: 'sbg:AWSInstanceType'
    value: r4.2xlarge;ebs-gp2;500
baseCommand: [python, -c]
arguments:
  - position: 0
    shellQuote: true
    valueFrom: >-
      def parse_interval(interval):
          colon_split = interval.split(":")
          chromosome = colon_split[0]
          dash_split = colon_split[1].split("-")
          start = int(dash_split[0])
          end = int(dash_split[1])
          return chromosome, start, end
      def add_interval(chr, start, end, i):
          fn = "out-{:0>5d}.intervals".format(i)
          lw = chr + ":" + str(start) + "-" + str(end) + "\n"
          with open(fn, "w") as fo:
              fo.writelines(lw)
          return chr, start, end
      def main():
          interval = "$(inputs.interval.path)"
          num_of_original_intervals = sum(1 for line in open(interval))
          num_gvcfs = $(inputs.input_vcfs.length)
          merge_count = int(num_of_original_intervals/num_gvcfs/2.5)
          count = 0
          i = 1
          chain_count = merge_count
          l_chr, l_start, l_end = "", 0, 0
          with open(interval) as f:
              for line in f.readlines():
                  # initialization
                  if count == 0:
                      w_chr, w_start, w_end = parse_interval(line)
                      count = 1
                      continue
                  # reached number to combine, so spit out and start over
                  if count == chain_count:
                      l_char, l_start, l_end = add_interval(w_chr, w_start, w_end, i)
                      w_chr, w_start, w_end = parse_interval(line)
                      count = 1
                      i += 1
                      continue
                  c_chr, c_start, c_end = parse_interval(line)
                  # if adjacent keep the chain going
                  if c_chr == w_chr and c_start == w_end + 1:
                      w_end = c_end
                      count += 1
                      continue
                  # not adjacent, end here and start a new chain
                  else:
                      l_char, l_start, l_end = add_interval(w_chr, w_start, w_end, i)
                      w_chr, w_start, w_end = parse_interval(line)
                      count = 1
                      i += 1
              if l_char != w_chr or l_start != w_start or l_end != w_end:
                  add_interval(w_chr, w_start, w_end, i)
      if __name__ == "__main__":
          main()
inputs:
  interval:  File
  input_vcfs: File[]

outputs:
  out_intervals:
    type: File[]
    outputBinding:
      glob: 'out-*.intervals'
      outputEval: ${
          var i;
          var name = [];
          var dict = {};
          for (i = 0; i < self.length; ++i) {
            name[i] = self[i].nameroot;
            dict[self[i].nameroot] = self[i];
          };
          name = name.sort();
          for (i = 0; i < name.length; ++i) {
            self[i] = dict[name[i]];
          };
          return self;
        }

