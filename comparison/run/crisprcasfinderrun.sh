#!/bin/bash

for file in ~/upload/*.fna
do
    perl CRISPRCasFinder.pl --in $file --out ~/crisprcasfinderresults/$(basename $file .fna)
done
