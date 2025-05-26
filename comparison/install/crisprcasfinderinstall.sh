#!/bin/bash

# download miniforge installer from github
curl -L -O "https://github.com/conda-forge/miniforge/releases/download/25.1.1-2/Miniforge3-25.1.1-2-Linux-x86_64.sh"
# run install script in non-interactive mode
bash Miniforge3-25.1.1-2-Linux-x86_64.sh -b
rm Miniforge3-25.1.1-2-Linux-x86_64.sh

~/miniforge3/bin/conda init

# download ccf tool
mkdir crisprcasfinder
curl -L -O "https://github.com/dcouvin/CRISPRCasFinder/archive/refs/tags/release-4.3.2.tar.gz"
tar -xvzf release-4.3.2.tar.gz -C crisprcasfinder --strip-components=1
rm release-4.3.2.tar.gz
cd crisprcasfinder
# create a new environment based on the ccf.environment.yml file
conda env create -f ccf.environment.yml -n crisprcasfinder
conda activate crisprcasfinder
# activate mamba. might need to go to a path - ~/miniforge3/bin/mamba int presumably
mamba init
mamba activate
conda activate crisprcasfinder
# using mamba, install macysyfinder 2.1.2
mamba install -c bioconda macsyfinder=2.1.2
# using macsyfinder, install CASFinder
macsydata install -u CASFinder==3.1.0

