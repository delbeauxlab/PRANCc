#!/bin/bash

##########
# rebatchify.sh
# ./rebatchify.sh [INPUT_DIR] [BATCH_FILE]
# takes a directory of fastas and a [BATCH_FILE] such as created from batchify.sh and 
# recreates those tarballs then compresses tarballs in folder with gzip
#
# uses bsd tar from a mac, hence removing mac-specific headers
#########

input_dir=${1}

batch_file=${2:-"$input_dir/batches.tsv"}

cd $input_dir

while read filename batch
do
    tar -rvf $batch.tar $filename
done < <(sed 1d $batch_file)

echo "gzip -v " *.tar
gzip -v *.tar