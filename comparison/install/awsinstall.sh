#!/bin/bash

apt-get update
apt-get install build-essential
apt install unzip

curl -L -O "https://github.com/conda-forge/miniforge/releases/download/25.3.0-3/Miniforge3-25.3.0-3-Linux-x86_64.sh"
# run install script in non-interactive mode
chmod +x Miniforge3-25.3.0-3-Linux-x86_64.sh
./Miniforge3-25.3.0-3-Linux-x86_64.sh -b
rm Miniforge3-25.3.0-3-Linux-x86_64.sh

miniforge3/bin/conda init bash
miniforge3/bin/conda create -n snakemake -c conda-forge -c bioconda snakemake


