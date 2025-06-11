#!/bin/bash

# Directory containing text files
# input_dir="../../results/padlocresults"
input_dir=${1:-"results/padloc/"}

# Output TSV file
# output_file="../../results/padlocresults.tsv"
output_file=${2:-"results/padloc.tsv"}

# Clear the output file if it already exists
> "$output_file"

header='sequence\tsystem.number\tseqid\tsystem\ttarget.name\thmm.accession\t'
header+='hmm.name\tprotein.name\tfull.seq.E.value\tdomain.iE.value\t'
header+='target.coverage\thmm.coverage\tstart\tend\tstrand\ttarget.description\t'
header+='relative.position\tcontig.end\tall.domains\tbest.hits'

# on linux - FreeBSD sed doesn't have -s flag
# echo -e $header >> $output_file
# sed -s -e '1d' -e 's/,/\t/g' $inputdir/*.csv >> $output_file

echo -e $header >> $output_file

# clever but doesn't add in file name column
# cp -r $input_dir $input_dir.bak
# sed -i '' -e '1d' -e 's/,/\t/g' $input_dir/*.csv
# cat $input_dir/*.csv >> $output_file
# rm -r $input_dir
# mv $input_dir.bak $input_dir

for file in $input_dir*/*.csv
do
    filename=$(basename $file '.csv')
    sed -e '1d' -e 's/,/\t/g' $file | while IFS= read line
    do
        echo -en "$filename\t" >> $output_file
        echo -e "$line" >> $output_file
    done
done