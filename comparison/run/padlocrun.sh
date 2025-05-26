#!/bin/bash

for file in ~/upload/*.fna
do
    filename=$(basename $file .fna)
    cdoutput="/home/ubuntu/cdresults/$filename.1_crispr"
    ploutput="/home/ubuntu/padlocresults"
    run-crisprdetect --input $file --output $cdoutput
    padloc --fna $file --crispr "$cdoutput.gff" --outdir $ploutput --cpu 8
done

tar -cvzf ~/padlocresults.tar.gz ~/padlocresults/*
tar -cvzf ~/cdresults.tar.gz ~/cdresults/*

date > ~/timefinished.txt
