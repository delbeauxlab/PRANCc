#!/bin/bash

##########
# batchify.sh
# ./batchify.sh [INPUT_DIR] [BATCH_SIZE]
# takes a single directory as input and generates a number of output tarballs each
# containing less than or equal to [BATCH_SIZE] fastas in [INPUT_DIR] and a list of the 
# files in [INPUT_DIR] and what batch tarball they were added to
# then compresses all tarballs in [INPUT_DIR] with gzip
#
# uses bsd tar from a mac, hence removing mac-specific headers
#########

input_dir=${1}

batch_size=${2:-500}

cd $input_dir
num_fastas=$(ls -1 *.fasta 2>/dev/null | wc -l)

num_batches=$(( ($num_fastas + $batch_size - 1) / $batch_size ))

counter=0
echo -e "Filename\tBatch" > $input_dir/batches.tsv
for fasta in *.fasta
do
    value=$(printf "%02d" $(( ($counter % $num_batches) + 1 )))
    echo -e $(basename $fasta) '\t' $value >> $input_dir/batches.tsv
    tar --disable-copyfile --no-xattrs -rvf $value.tar $fasta
    counter=$(($counter+1))
done

echo "gzip -v" *.tar
gzip -v *.tar