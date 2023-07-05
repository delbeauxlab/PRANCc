#!/bin/bash

#PBS -m abe
#PBS -M research.ng.crispr@gmail.com
#PBS -N tarFastas
#PBS -l select=1:Ncpus=4:mem=12gb, walltime=6:00:0

cd /export/home/s2943989/ngbin

tar -czf ~/tar/ngfastas.tar.gz *.fasta
