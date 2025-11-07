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

echo "doing the v2 sheets"
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

echo "doing the v3 sheets"
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
            if [[ $test != "0" && -n $test ]]
            then
                echo -e "$sequence\t$test\t$rest" >> $path/$prelim_sheet"_v3".tsv
            fi

        done < $file
    done
done

echo "doing the v4 sheets"
# output _v4.tsv versions with country code
for sheet in ${sheets[@]}
do
    for file in $1/*/results/$sheet"_v3.tsv"
    do
        path=$(dirname $file)
        country=$(dirname $path)
        country=$(basename $country)
        country=${country#"ng"}
        country=${country%"results"}
        sed -n 1p $file | while IFS=$'\t' read filename rest
        do
            echo -e "$filename\tcountry\t$rest" > $path/$sheet"_v4".tsv
        done
        sed -e 1d $file | while IFS=$'\t' read filename rest
        do
            echo -e "$filename\t$country\t$rest" >> $path/$sheet"_v4".tsv
        done
    done
done

echo "doing the version sheets"
# read version.log and make a sheet versions_v4.tsv
for file in $1/*/results/version.log
do
    path=$(dirname $file)
    pranccver=""
    condaver=""
    padlocver=""
    snakemakever=""
    ccfver="4.3.2"
    cctver="1.8.0"
    civer="1.2.1"
    cdver="2.2"
    while IFS= read line version rest
    do
        if [[ $line == "PRANCc version"* ]]
        then
            pranccver=${line#"PRANCc version "}
        elif [[ $line == "conda "* ]]
        then
            condaver=${line#"conda "}
        elif [[ $line == padloc* ]]
        then 
            padlocver=$line
            padlocver=${line#"padloc"}
            padlocver=$(echo $padlocver | xargs)
            padlocver=${padlocver%% *}
        elif [[ $line == "snakemake "* ]]
        then
            snakemakever=$line
            snakemakever=${line#"snakemake"}
            snakemakever=$(echo $snakemakever | xargs)
            snakemakever=${snakemakever%% *}
        fi
    done < $file
    verheader="PRANCc version\tConda version\tSnakemake version\tCrisprCasFinder version\t"
    verheader+="CrisprCasTyper version\tCrisprIdentify version\tCrisprDetect version\t"
    verheader+="PADLOC version"
    echo -e $verheader > $path/versions_v4.tsv
    echo -e "$pranccver\t$condaver\t$snakemakever\t$ccfver\t$cctver\t$civer\t$cdver\t$padlocver" >> $path/versions_v4.tsv
done

counter=0
echo "compiling them all together"
# compiles all of them together end to end to [INPUT_DIRECTORY]/compiled_results/*_compiled_v1.tsv
for file in $1/*/results/*_v4.tsv
do
    if [ $counter -eq 0 ]
    then
        path=$(dirname $file)
        mkdir -p $1/compiled_results
        for sheet in ${sheets[@]}
        do
            sed -n 1p $path/$sheet"_v4.tsv" > $1/compiled_results/$sheet"_compiled_v1.tsv"
        done
        sed -n 1p $path/versions_v4.tsv > $1/compiled_results/versions_compiled_v1.tsv
        counter=1
    fi
    sheet=$(basename $file _v4.tsv)
    sed -e 1d $file >> $1/compiled_results/$sheet"_compiled_v1.tsv"
done

> $1/compiled_results/ccfcas_compiled_v2.tsv

while IFS=$'\t' read a b c d e f g h i j k l m n o
do
    echo -e "$a\t$b\t$c\t$d\t$e\t$f\t$g\t$h\t$i\t$j\t$k\t$l\t$o" >> $1/compiled_results/ccfcas_compiled_v2.tsv
done < $1/compiled_results/ccfcas_compiled_v1.tsv
