#!/bin/zsh

##########
# get_fasta_lengths.sh
# ./get_fasta_lengths.sh [INPUT_FASTAS] [ACCESSION_LIST] [LOGS_DIR] [OUTPUT_1.txt] [OUTPUT_2.txt]
# relies on fasta_tools and thus perl
# takes a list of fastas [INPUT_FASTAS] and returns a list of fastas with the number of base 
# pairs, the number of nodes, the size on disk, and outputs that to [OUTPUT.txt]
#########

# get arguments from command line
args=( "$@" )
output_file=${args[-2]}
acc_list=${args[-4]}
output_file_2=${args[-1]}
logs_dir=${args[-3]}
args[-4]=()
args[-3]=()
args[-2]=()
args[-1]=()

echo -e "Filename\tNum_base_pairs\tFile_size_(bytes)" > $output_file

counter=0

for fasta in $args[@]
do
    sequence=$(basename $fasta .fna)
    echo $fasta
    while IFS= read line
    do
        if [[ $line = '>'* ]]
        then
            counter=1
        else
            if [[ $line = [[:digit:]]* ]]
            then
                if [[ $counter = 0 ]]
                then
                    bp_length=$line
                    counter=-1
                else
                    counter=$(($counter-1))
                fi
            fi
        fi
    done <<< $(fasta_length -e $fasta)

    fasta_size=$(stat -f%z $fasta)
    echo $sequence '\t' $bp_length '\t' $fasta_size >> $output_file
done
echo -e 'Accession\tFilename\tStrain_Name\tNum_base_pairs\tSize' > $output_file_2
setopt kshglob
counter=0
while read -r sequence bp size
do 
        while read -r accession strain_name
        do
            if [[ $accession = ${sequence%%_!(*.*)_genomic} ]]
            then
                strain_name=${strain_name//$'\r'/}
                
                printstring=$(echo $accession '\t' $sequence '\t' $strain_name '\t' $bp '\t' $size)
                printstring=${printstring//$' '/}

                echo $printstring >> $output_file_2
            fi
        done < <(sed 1d $acc_list)
done < <(sed 1d $output_file)

# echo -e 'Accession\tFilename\tStrain_Name\tNum_base_pairs\tSize\ts\th:m:s\tmax_rss\tmax_vms\tmax_uss\tmax_pss\tio_in\tio_out\tmean_load\tcpu_time' |
#     tee $logsdir/ccf_$filename.txt $logsdir/cct_$filename.txt $logsdir/ci_$filename.txt\
#     $logsdir/cd_$filename.txt $logsdir/padloc_$filename.txt
toolarray=( ccf cct ci cd padloc )
while read -r accession filename strain_name num_base_pairs size
do
    for tool in $toolarray[@]
    do
        output=$tool
        output+='_full'
        # echo -e 'Accession\tFilename\tStrain_Name\tNum_base_pairs\tSize\ts\th:m:s\tmax_rss\tmax_vms\tmax_uss\tmax_pss\tio_in\tio_out\tmean_load\tcpu_time' > ~/$output.txt
        output2=$tool
        output2+='_'
        output2+=$filename
        output2+='.txt'
        while read -r s hms maxrss maxvms maxuss maxpss in out mean cpu
        do
            printstring=$(echo $accession '\t' $filename '\t' $strain_name '\t' $num_base_pairs '\t' $size'\t' $s'\t' $hms'\t' $maxrss'\t' $maxvms'\t' $maxuss'\t' $maxpss'\t' $in'\t'$out'\t' $mean'\t' $cpu)
            printstring=${printstring//$' '/}
            echo $printstring >> ~/$output.txt
        done < <(sed 1d $logs_dir/$output2)
    done
done < <(sed 1d $output_file_2)