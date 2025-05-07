#!/bin/bash

# Directory containing text files
input_dir="../../results/crispridentifyresults"

# Output TSV file
output_file="../../results/ciresults.tsv"

# Clear the output file if it already exists
> "$output_file"

header="Sequence\tName\tGlobal ID\tID\tRegion index\tStart\tEnd\t"
header+="Length\tConsensus repeat\tRepeat Length\tAverage Spacer Length\t"
header+="Number of spacers\tStrand\tCategory\tScore"

echo -e $header >> $output_file

total_sequences=0
total_spacers=0

for folder in $input_dir/*/
do
    foldername=$(basename $folder)
    file="$folder/Complete_summary.csv"
    # check if it exists
    if [ -f $file ]
    then
        # sed two commands, delete first line then replace all ',' with '\t' then pipe to loop
        sed -e '1d' -e 's/,/\t/g' $file | while IFS= read line
        do
            echo -en "$foldername\t" >> $output_file
            echo -e "$line" >> $output_file
        done
    fi
done