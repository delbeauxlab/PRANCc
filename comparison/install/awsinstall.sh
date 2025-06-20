#!/bin/bash

apt-get update
apt-get install build-essential
apt-get unzip

curl -L -O "https://github.com/conda-forge/miniforge/releases/download/25.3.0-3/Miniforge3-25.3.0-3-Linux-x86_64.sh"
# run install script in non-interactive mode
./Miniforge3-25.3.0-3-Linux-x86_64.sh -b
rm Miniforge3-25.3.0-3-Linux-x86_64.sh

eval "$(conda shell.bash activate)"
conda create -n snakemake -c conda-forge -c bioconda snakemake


