#!/bin/bash

# PADLOC also has patched versions of infernal and CRISPRDetect - for compatibility with PADLOC, this is also going to be the server
# setup for infernal (if used need to research) and CRISPRDetect

# because PADLOC relies on having CRISPRDetect files for output of crispr cas genes - and i want that test output
# need to run CRISPRDetect first

# download miniforge installer from github
curl -L -O "https://github.com/conda-forge/miniforge/releases/download/25.1.1-2/Miniforge3-25.1.1-2-Linux-x86_64.sh"
# run install script in non-interactive mode
bash Miniforge3-25.1.1-2-Linux-x86_64.sh -b
rm Miniforge3-25.1.1-2-Linux-x86_64.sh

sudo apt-get update
sudo apt-get install build-essentials

~/miniforge3/bin/conda init

# Install PADLOC into a new conda environment
conda create -n padloc -c conda-forge -c bioconda -c padlocbio padloc=2.0.0
# Activate the environment
conda activate padloc
# Download the latest database
padloc --db-update

install-crisprdetect

# run-crisprdetect --input test/GCF_004358345.1.fna --output test/GCF_004358345.1_crispr
# padloc --fna genome.fna --crispr genome.crispr
