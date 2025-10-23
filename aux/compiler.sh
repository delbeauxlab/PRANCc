#!/bin/bash

##########
# compiler.sh
# ./compiler.sh [INPUT_DIRECTORY]
#
# Goes through all directories in [INPUT_DIRECTORY] and searches for:
#        results/ccfcas.tsv
#        results/ccfcrispr.tsv
#        results/cctyper.tsv
#        results/cidentify.tsv
#        results/cidentify_cas.tsv
#        results/padloc.tsv
#        results/version.log
# and does the following steps:
#       checks if the headers for cidentify.tsv are correct, and outputs cidentify_v2.tsv
#           with correct headers
#       checks if Filename data in padloc.tsv has file extensions in data and outputs 
#           padloc_v2.tsv with no file extensions in Filename
#       check for empty lines in all sheets and output *_v3.tsv version of all sheets with no empty
#           lines
#       outputs *_v4.tsv version of all sheets with country code column from name of containing folder
#       creates *_compiled_v1.tsv versions of all sheets in [INPUT_DIRECTORY]/compiled by joining
#           all sheets end to end
#########

# Erroneous CI prefix to remove
ci_prefix="Filename*No arrays found"

# Correct CI header row
ci_header="Filename\tName\tGlobal ID\tID\tRegion index\tStart\tEnd\t"
ci_header+="Length\tConsensus repeat\tRepeat Length\tAverage Spacer Length\t"
ci_header+="Number of spacers\tStrand\tCategory\tScore"

# list of sheets
sheets=( "ccfcas" "ccfcrispr" "cctyper" "cidentify" "cidentify_cas" "padloc" )

# Create cidentify_v2.tsv with fixed header row
for file in $1/*/results/cidentify.tsv
do
    path=$(dirname $file)
    sed -n 1p $file | while IFS= read line
    do
        echo -e $ci_header > $path/cidentify_v2.tsv
        echo -e "${line#$ci_prefix}" >> $path/cidentify_v2.tsv
    done
    sed -e 1d $file >> $path/cidentify_v2.tsv
done

# remove .fasta from first column entries in padloc.tsv and output to padloc_v2.tsv
for file in $1/*/results/padloc.tsv
do
    path=$(dirname $file)
    > $path/padloc_v2.tsv
    while IFS=$'\t' read sequence rest
    do
        newseq=${sequence%".fasta"}
        echo -e "$newseq\t$rest" >> $path/padloc_v2.tsv
    done < $file
done

# check for empty entries in third row of every sheet and export _v3.tsv versions
for prelim_sheet in ${sheets[@]}
do
    if [ $prelim_sheet == "padloc" ]
    then
        sheet="padloc_v2"
    elif [ $prelim_sheet == "cidentify" ]
    then
        sheet="cidentify_v2"
    else
        sheet=$prelim_sheet
    fi
    for file in $1/*/results/$sheet.tsv
    do
        path=$(dirname $file)
        > $path/$prelim_sheet"_v3".tsv
        while IFS=$'\t' read sequence space test rest
        do
            if [ -n "$test" ]
            then
                echo -e "$sequence\t$test\t$rest" >> $path/$prelim_sheet"_v3".tsv
            fi
        done < $file
    done
done