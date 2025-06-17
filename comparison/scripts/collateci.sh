#!/bin/bash

# Directory containing text files
# input_dir="../../results/crispridentifyresults"
input_dir=${1:-"results/cidentify"}

# Input map file to map multifastas
input_map=${2:-"results/cidentify/sequence_map.txt"}

# Output TSV file
# output_file="../../results/ciresults.tsv"
output_file=${3:-"results/cidentify.tsv"}

# Clear the output file if it already exists
> "$output_file"

counter=0
        > $output_file
        declare -A map
        while read line
        do
            map[${line%:*}]=${line#*:}
        done < $input_map

        while read line
        do
            if [ $counter -eq 0 ]
            then
                echo -en Filename\t >> $output_file
                counter=1
            else
                $filename=$map[${line%%,*}]
                echo -en $filename\t >> $output_file
            fi
            sed -e 's/,/\t/g' "$line" >> $output_file
        done < $input_dir/Complete_summary.csv

# header="Sequence\tName\tGlobal ID\tID\tRegion index\tStart\tEnd\t"
# header+="Length\tConsensus repeat\tRepeat Length\tAverage Spacer Length\t"
# header+="Number of spacers\tStrand\tCategory\tScore"

# echo -e $header >> $output_file

# total_sequences=0
# total_spacers=0

# for folder in $input_dir/*/
# do
#     foldername=$(basename $folder)
#     file="$folder/Complete_summary.csv"
#     # check if it exists
#     if [ -f $file ]
#     then
#         # sed two commands, delete first line then replace all ',' with '\t' then pipe to loop
#         sed -e '1d' -e 's/,/\t/g' $file | while IFS= read line
#         do
#             echo -en "$foldername\t" >> $output_file
#             echo -e "$line" >> $output_file
#         done
#     fi
# done