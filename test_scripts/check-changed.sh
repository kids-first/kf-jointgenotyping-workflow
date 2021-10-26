for cwl_file in $(git diff --staged --name-only | grep '.*\.cwl$')
do
  cwltool --validate "$cwl_file"
done
