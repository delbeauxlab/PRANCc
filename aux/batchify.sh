#!/bin/bash

##########
# batchify.sh
# ./batchify.sh [INPUT_DIR] [NUM_BATCHES]
# takes a single directory as input and generates a number of output directories each
# containing [NUM_BATCHES] fastas in [INPUT_DIR] and a list of the files in [INPUT_DIR]
# and what batch folder they were copied to
#########

input_dir=${1}

num_batches=${2}

counter=0
echo -e "Filename\tBatch" > $input_dir/batches.tsv
for number in $(seq 1 $num_batches)
    do
        value=$(printf "%02d" $number)
        mkdir -p $input_dir/$value
    done
for fasta in $input_dir/*.fasta
do
    value=$(printf "%02d" $(($counter % $num_batches + 1)))
    cp $fasta $input_dir/$value
    echo -e $(basename $fasta) '\t' $value >> $input_dir/batches.tsv
    counter=$(($counter+1))
done