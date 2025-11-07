#!/bin/bash

##########
# meta_compiler.sh
# ./meta_compiler.sh [INPUT_DIRECTORY]
#
# Goes through all directories in [INPUT_DIRECTORY] and searches for:
#        amr-snps-genes.csv
#        amr.csv
#        cgmlst.csv
#        core_stats.csv
#        inctyper.csv
#        metadata.csv
#        mlst-pubmlst.csv
#        ngmast.csv
#        ngstar.csv
#        speciator.csv
#        stats.csv
# and compiles them end to end to [INPUT_DIRECTORY/compiled_metadata]
#########

# list of sheets
sheets=( "amr-snps-genes" "amr" "cgmlst" "core_stats" "inctyper" "metadata" "mlst-pubmlst" "ngmast" "ngstar" "speciator" "stats" )

for sheet in ${sheets[@]}
do
    counter=0
    for file in $1/*/$sheet".csv"
    do
        if [ $counter -eq 0 ]
        then
            mkdir -p $1/compiled_metadata
            sed -n 1p $file > $1/compiled_metadata/$sheet".csv"
            counter=1
            echo "This should only run like 9 times"
        fi
        sed -e 1d $file >> $1/compiled_metadata/$sheet".csv"
        echo "doing $sheet"
    done
done
