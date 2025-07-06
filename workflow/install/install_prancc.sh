#!/bin/bash

###########
# install_prancc.sh
# ./prancc/workflow/install/awsinstall.sh
#
# prereqs: build-essentials, unzip, conda, mamba, snakemake
# see workflow/install/awsinstall.sh for more details

# a simple installer to download trained models and HMM sets for crispridentify/crisprcasidentifier
# as well as install crisprcasfinder/crispridentify and create needed conda environments
# installs conda environments: crisprcasfinder, padloc, crisprdetect
# will throw errors if you already have conda environments of those names
# 
# installs: gdown
#
# runs crisprcasidentifier to initialise it for crispridentify, sends output to /dev/null
###########


source "${HOME}/conda/etc/profile.d/conda.sh"
# For mamba support also run the following command
source "${HOME}/conda/etc/profile.d/mamba.sh"

conda create -n gdown -c conda-forge gdown -y
conda activate gdown
gdown --fuzzy https://drive.google.com/file/d/1YbTxkn9KuJP2D7U1-6kL1Yimu_4RqSl1/view?usp=sharing
gdown --fuzzy https://drive.google.com/file/d/1Nc5o6QVB6QxMxpQjmLQcbwQwkRLk-thM/view?usp=sharing
conda deactivate
conda remove -n gdown --all -y

mkdir -p prancc/bin
mkdir -p prancc/bin/ccfinder
mkdir -p prancc/bin/cidentify
curl -LO "https://github.com/dcouvin/CRISPRCasFinder/archive/refs/tags/release-4.3.2.tar.gz"
curl -LO "https://github.com/BackofenLab/CRISPRidentify/archive/refs/tags/v1.2.1.tar.gz"
curl -LO "https://github.com/BackofenLab/CRISPRcasIdentifier/archive/refs/tags/v1.1.0.tar.gz"

tar -xvzf release-4.3.2.tar.gz -C prancc/bin/ccfinder --strip-components=1
tar -xzvf v1.2.1.tar.gz -C prancc/bin/cidentify --strip-components=1
tar -xzvf v1.1.0.tar.gz -C prancc/bin/cidentify/tools/CRISPRcasIdentifier/CRISPRcasIdentifier --strip-components=1
mv -t prancc/bin/cidentify/tools/CRISPRcasIdentifier/CRISPRcasIdentifier HMM_sets.tar.gz trained_models.tar.gz
rm release-4.3.2.tar.gz v1.2.1.tar.gz v1.1.0.tar.gz

# create a new environment based on the ccf.environment.yml file
conda env create -f prancc/bin/ccfinder/ccf.environment.yml -n crisprcasfinder -y

conda activate crisprcasfinder
# using mamba, install macysyfinder 2.1.2
mamba install -c bioconda macsyfinder=2.1.2 -y
# using macsyfinder, install CASFinder
macsydata install -u CASFinder==3.1.0

conda deactivate
# install padloc
conda create -n padloc -c conda-forge -c bioconda -c padlocbio padloc=2.0.0 -y
# Activate the environment
conda activate padloc
# Download the latest database
padloc --db-update

install-crisprdetect

conda deactivate

conda env create -f prancc/bin/cidentify/environment.yml -y
cd prancc/bin/cidentify/tools/CRISPRcasIdentifier/CRISPRcasIdentifier/
conda activate crispr_identify_env
python CRISPRcasIdentifier.py -f ../../../../../upload/GCF_040370845.1_WHO_U_2024_genomic.fasta -st dna -sc complete -o /dev/null
cd ../../../../../..
conda deactivate
conda remove -n crispr_identify_env --all -y
