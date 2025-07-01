#!/bin/bash

##########
# collateccf.sh
# ./collateccf.sh [INPUT_DIRS] [OUTPUT_CAS.tsv] [OUTPUT_ARRAY.tsv]
# takes a list of directories [INPUT_DIRS] and finds the TSV/Crisprs_REPORT.tsv
# and TSV/CRISPR-Cas_summary.tsv inside the directories, gets the header from the 
# first [INPUT_DIRS] given and concatenates them all into two files 
# [OUTPUT_CAS.tsv] and [OUTPUT_ARRAY.tsv] while including basename of [INPUT_DIRS]
# in data
#########

# get arguments from command line
args=( "$@" )

# set last two elements of arguments array to variables, then remove from array
# leaving only the list of folders to process
output_file_array=${args[-2]}
output_file_cas=${args[-1]}
unset "args[-1]"
unset "args[-1]"

# Clear the output files if they already exist
> "$output_file_cas"
> "$output_file_array"

# Write Filename and headers
echo -en "Filename\t" >> $output_file_cas
echo -en "Filename\t" >> $output_file_array
sed -n 1p "${args[0]}/TSV/CRISPR-Cas_summary.tsv" >> $output_file_cas
sed -n 1p "${args[0]}/TSV/Crisprs_REPORT.tsv" >> $output_file_array

# loop over arguments and write the lines
for folder in "${args[@]}"
do
    foldername=$(basename $folder)
    array_file="$folder/TSV/Crisprs_REPORT.tsv"
    cas_file="$folder/TSV/CRISPR-Cas_summary.tsv"
    sed -e 1d $array_file | while IFS= read line
    do
        echo -en "$foldername\t" >> $output_file_array
        echo -e "$line" >> $output_file_array
    done
    sed -e 1d $cas_file | while IFS= read line
    do
        echo -en "$foldername\t" >> $output_file_cas
        echo -e "$line" >> $output_file_cas
    done
done
