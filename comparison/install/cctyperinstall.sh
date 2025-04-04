#!/bin/bash
# download miniforge installer from github
curl -L -O "https://github.com/conda-forge/miniforge/releases/download/25.1.1-2/Miniforge3-25.1.1-2-Linux-x86_64.sh"
# run install script in non-interactive mode
bash Miniforge3-25.1.1-2-Linux-x86_64.sh -b


~/miniforge3/bin/conda init
# have to manually exit shell here and restart - need to investigate to find a way to do
# this inside shell script
# potentially conda create becomes ~/miniforge3/bin/conda create?
# test
# either way initialises for use of cctyperrun.sh script

conda create -n cctyper -c conda-forge -c bioconda -c russel88 cctyper
