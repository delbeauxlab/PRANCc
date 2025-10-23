#!/bin/bash

##########
# compiler.sh
# ./compiler.sh [INPUT_DIRECTORY]
#
# Goes through all directories in [INPUT_DIRECTORY] and searches for:
#       tables.xlsx
#       qclog.tsv
#       results.tsv
#       summary.tsv
# and extracts the versions.tsv from tables.xlsx
# convert versions.tsv into a flat format and adds country code from folder name then
#   outputs versions_v2.tsv
# adds country code to all other .tsvs and exports _v2.tsv versions
# compiles them all end to end
#
# Prerequisites: xlsx2csv in path
#
##########

# list of tables
tables=( "summary" "results" "qclog" )

# creates headers for sheets
summary_headers=""

# extract versions.tsv from tables.xlsx
for file in $1/*/tables.xlsx
do
    path=$(dirname $file)
    xlsx2csv -s 4 -d 'tab' $file > $path/versions.tsv
done

# invert versions.tsv and add country code into versions_v2.tsv
for file in $1/*/versions.tsv
do
    path=$(dirname $file)
    country=$(basename $path)
    country=${country#"ng"}
    country=${country%"results"}
    echo -e "snakemake\tmultiqc\tabricate\tspades\tminimap\tsamtools\tquast\tpyngoST\tclaMLST\tngpipe\tcountry" > $path/versions_v2.tsv

    while IFS=$'\t' read tool version
    do
        echo -n $version >> $path/versions_v2.tsv
        echo -en "\t" >> $path/versions_v2.tsv
    done <$file
    echo $country >> $path/versions_v2.tsv
done

counter=0

# add country codes to other tables and export to _v2.tsv
for table in ${tables[@]}
do
    for file in $1/*/$table.tsv
    do
        path=$(dirname $file)
        country=$(basename $path)
        country=${country#"ng"}
        country=${country%"results"}
        sed -n 1p $file | while IFS=$'\t' read filename rest
        do
            echo -e "$filename\tcountry\t$rest" > $path/$table"_v2.tsv"
        done
        sed -e 1d $file | while IFS=$'\t' read filename rest
        do
            echo -e "$filename\t$country\t$rest" >> $path/$table"_v2.tsv"
        done
    done
done

counter=0
# compiles all of them together end to end to [INPUT_DIRECTORY]/compiled_results/*_compiled_v1.tsv
for file in $1/*/*_v2.tsv
do
    if [ $counter -eq 0 ]
    then
        path=$(dirname $file)
        mkdir -p $1/compiled_results
        sed -n 1p $path/summary_v2.tsv > $1/compiled_results/summary_compiled_v1.tsv
        sed -n 1p $path/results_v2.tsv > $1/compiled_results/results_compiled_v1.tsv
        sed -n 1p $path/qclog_v2.tsv > $1/compiled_results/qclog_compiled_v1.tsv
        sed -n 1p $path/versions_v2.tsv > $1/compiled_results/versions_compiled_v1.tsv
        counter=1
    fi
    table=$(basename $file _v2.tsv)
    sed -e 1d $file >> $1/compiled_results/$table"_compiled_v1.tsv"
done