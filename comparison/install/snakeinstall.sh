#!/bin/bash

# need to have already installed:
# conda
# mamba
# snakemake (conda create -n snakemake -c conda-forge -c bioconda snakemake)

# need to have run:
# sudo apt-get update
# sudo apt-get install build-essentials

pip install gdown

mkdir prancc/bin
mkdir prancc/bin/ccfinder
mkdir prancc/bin/cidentify
curl -LOZ "https://github.com/dcouvin/CRISPRCasFinder/archive/refs/tags/release-4.3.2.tar.gz" \
 "https://github.com/BackofenLab/CRISPRidentify/archive/refs/tags/v1.2.1.tar.gz" \
 "https://github.com/BackofenLab/CRISPRcasIdentifier/archive/refs/tags/v1.1.0.tar.gz"

gdown https://drive.google.com/file/d/1YbTxkn9KuJP2D7U1-6kL1Yimu_4RqSl1
gdown https://drive.google.com/file/d/1Nc5o6QVB6QxMxpQjmLQcbwQwkRLk-thM

tar -xvzf release-4.3.2.tar.gz -C prancc/bin/ccfinder --strip-components=1
tar -xzvf v1.2.1.tar.gz -C prancc/bin/cidentify --strip-components=1
tar -xzvf v1.1.0.tar.gz -C prancc/bin/cidentify/tools/CRISPRcasIdentifier/CRISPRcasIdentifier --strip-components=1
mv -t prancc/bin/cidentify/tools/CRISPRcasIdentifier/CRISPRcasIdentifier HMM_sets.tar.gz trained_models.tar.gz
rm release-4.3.2.tar.gz v1.2.1.tar.gz v1.1.0.tar.gz

conda init
# create a new environment based on the ccf.environment.yml file
conda env create -f prancc/bin/ccf/ccf.environment.yml -n crisprcasfinder

conda activate crisprcasfinder
# using mamba, install macysyfinder 2.1.2
mamba install -c bioconda macsyfinder=2.1.2
# using macsyfinder, install CASFinder
macsydata install -u CASFinder==3.1.0

conda deactivate
# install padloc
conda create -n padloc -c conda-forge -c bioconda -c padlocbio padloc=2.0.0
# Activate the environment
conda activate padloc
# Download the latest database
padloc --db-update

install-crisprdetect

conda deactivate
