#!/bin/zsh

##########
# bp_sizer.sh
# ./bp_sizer.sh [INPUT_FASTAS_DIR] [BENCHMARKS_DIR] [OUTPUT_DIR]
#########

# get arguments from command line
args=( "$@" )
input_fasta_dir=${args[1]}
benchmarks_dir=${args[2]}
output_dir=${args[3]}
bp_length=0
fasta_size=0

get_fasta_length () {
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
    done < <(fasta_length -e $1)
    fasta_size=$(stat -f%z $1)
    echo $1
}

toolarray=( ccf cct ci cd padloc )
strain_name="Neisseria_gonorrhoeae"

for tool in $toolarray[@]
do
    output=$output_dir
    output+='/'
    output+=$tool
    output+="_full.txt"
    echo -e "Accession\tFilename\tStrain_Name\tNum_base_pairs\tFasta_size\ts\th:m:s\tmax_rss\tmax_vms\tmax_uss\tmax_pss\tio_in\tio_out\tmean_load\tcpu_time" > $output
    while read -r accession filename s hms rss vms uss pss in out mean cpu
    do
        # echo $input_fasta_dir/$filename.fasta
        output=$output_dir
        output+='/'
        output+=$tool
        output+="_full.txt"
        get_fasta_length $input_fasta_dir/$filename.fasta
        echo $accession '\t' $filename '\t' $strain_name '\t' $bp_length '\t' $fasta_size '\t' $s '\t' $hms '\t' $rss '\t' $vms '\t' $uss '\t' $pss '\t' $in '\t' $out '\t' $mean '\t' $cpu >> $output
        echo "written to "$output
    done < <(sed 1d $benchmarks_dir/$tool.txt)
done