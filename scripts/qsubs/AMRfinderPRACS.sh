#!/bin/bash

#PBS -m abe
#PBS -M research.ng.crispr@gmail.com
#PBS -N AMRfinderPRACS
#PBS -l select=1:Ncpus=4:mem=12gb, walltime=220:0:00
#PBS -q routeq

cd /export/home/s2943989/ngbin

module load anaconda3

source activate AMRfinder

for file in *; do
	if [ -f "$file" ]; then
		if [[ $file == *.fasta ]]; then
			amrfinder -n "$file" --organism Neisseria gonorrhoeae --threads 4 -o ~/amrfinderresults/"$file".log
		fi
	fi
done