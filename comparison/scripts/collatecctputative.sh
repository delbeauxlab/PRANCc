#!/bin/bash

# Directory containing text files
input_dir="../../results/cctresults"

# Output TSV file
output_file="../../results/cctputativeresults.tsv"

# Clear the output file if it already exists
> "$output_file"

header="Sequence\tContig\tOperon\tStart\tEnd\tPrediction\tComplete_interference\tComplete_Adaptation\t"
header+="Best_type\tBest_score\tGenes\tPositions\tE-values\tCoverageSeq\tCoverageHMM\t"
header+="Strand_interference\tStrand_Adaptation"

echo -e $header >> $output_file

total_sequences=0
total_crisprs=0

# Loop over all folders in directory
for folder in $input_dir/cctyperresults/*/
do
    foldername=$(basename $folder)
    file="$folder/cas_operons_putative.tab"
    total_sequences=$((total_sequences + 1))
    if [ -f $file ]
    then
        crispr_count=$(wc -l < $file)
        total_crisprs=$((total_crisprs + $crispr_count - 1 ))
        sed 1d $file | while IFS= read line
        do
            echo -en "$foldername\t" >> $output_file
            echo -e "$line" >> $output_file
        done
    fi
done

real_output_path=$(realpath $output_file)
echo "Parsing and compilation complete! $total_crisprs crisprs found over $total_sequences sequences. Results saved to $real_output_path."