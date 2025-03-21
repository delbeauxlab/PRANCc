#!/bin/bash

# download miniforge installer from github
curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-25.1.1-2-Linux-x86_64.sh"
# run install script in non-interactive mode
bash Miniforge3-25.1.1-2-Linux-x86_64.sh -b

# activate conda. non-interactive install doesnt run conda scripts or add to path
~/miniforge3/bin/conda init

# create a new environment based on cctyper on russel88 in bioconda
conda create -n cctyper -c conda-forge -c bioconda -c russel88 cctyper

# download CRISPRCasFinder environment file
curl -L -O "https://github.com/dcouvin/CRISPRCasFinder/blob/master/ccf.environment.yml"

# create a new environment based on the ccf.environment.yml file
conda env create -f ccf.environment.yml -n crisprcasfinder
conda activate crisprcasfinder
# activate mamba. might need to go to a path - ~/miniforge3/bin/mamba int presumably
mamba init
mamba activate
# using mamba, install macysyfinder 2.1.2
mamba install -c bioconda macsyfinder=2.1.2
# using macsyfinder, install CASFinder
macsydata install -u CASFinder==3.1.0

# cleanup
rm -f Miniforge3-25.1.1-2-Linux-x86_64.sh
rm -f ccf.environment.yml

# Download CRISPRcasIdentifier
curl -L -O "https://github.com/BackofenLab/CRISPRcasIdentifier/archive/v1.1.0.tar.gz"
# extract it
tar -xzf v1.1.0.tar.gz

# need to download HMM and ML models from google drive
# https://drive.google.com/file/d/1YbTxkn9KuJP2D7U1-6kL1Yimu_4RqSl1/view?usp=sharing
# https://drive.google.com/file/d/1Nc5o6QVB6QxMxpQjmLQcbwQwkRLk-thM/view?usp=sharing
# a tool exists for this - pip install gdown - but I would rather download these and upload to the server.
# then if i make an ami the extracted files will be included 

# Use conda to install dependencies for CRISPRcasidentifier
cd v1.1.0/
conda env create -f crispr-env.yml -n crispr-env
cd ~

# to run CRISPRcasidentifier: navigate to folder (cd v1.1.0/) and then run python CRISPRcasIdentifier.py with arguments

# download CRISPRidentify environment.yml file and install from .yml
curl -L -O "https://github.com/BackofenLab/CRISPRidentify/environment.yml"
mamba env create -f environment.yml -n crispridentify

# cleanup
rm -f environment.yml

# get docker images on EBS
mkdir /dev/sdb/docker
cd /dev/sdb/docker

# get CRISPRdisco - this is about 3.8GB
git clone https://github.com/CRISPRlab/CRISPRdisco.git
# cd CRISPRdisco
# can run CRISPRdisco from cd /dev/sdb/docker/CRISPRdisco; ./disco.sh

# Install R for R-based programs (CRISPRclassify)
sudo apt update
sudo apt -y upgrade

sudo apt-get install openjdk-18-jdk
sudo apt -y install r-base

# Using R, install package
Rscript -e 'install.packages("devtools", repos="https://cloud.r-project.org")'

# shutdown after we're done
#shutdown