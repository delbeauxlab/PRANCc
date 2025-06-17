#!/bin/bash

# directory containing results
input_dir=${1:-"results/ccfresults"}

# output .tsv files
output_file_cas=${2:-"results/ccfcas.tsv"}

output_file_crispr=${3:-"results/ccfcrispr.tsv"}

# Clear the output files if they already exist
> "$output_file_cas"
> "$output_file_crispr"

# loop over results summaries in TSV folder per output sequence
# add on the fna fikes name and collate
counter=0
for folder in $input_dir/*/
do
    foldername=$(basename $folder)
    while IFS="\n" read line
    do
        if [ $counter -eq 0 ]
        then
            echo -en "Filename\t" >> $output_file_cas
            echo -en "Filename\t" >> $output_file_crispr
            counter=1
        else
            echo -en "$foldername\t" >> $output_file_cas
        fi
        echo -e "$line" >> $output_file_cas
    done < $folder/TSV/CRISPR-Cas_summary.tsv

    while read line
    do
        echo -en "$foldername\t" >> $output_file_crispr
        echo -e "$line" >> $output_file_crispr
    done < $folder/TSV/Crisprs_REPORT.tsv
done
