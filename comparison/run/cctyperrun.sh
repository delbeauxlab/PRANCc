#!/bin/bash

for file in ~/upload/*.fna
do
    filename=$(basename $file .fna)
    output="~/cctyperresults/$filename"
    cctyper --threads 8 ~/upload/$filename.fna ~/cctyperresults/$filename
done

tar -cvf ~/cctyperresults.tar.gz ~/cctyperresults/* 
