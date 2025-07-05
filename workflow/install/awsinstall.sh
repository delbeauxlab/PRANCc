#!/bin/bash

###########
#  awsinstall.sh
# sudo prancc/workflow/install/awsinstall.sh
#
# a quick installer for some prereqs and conda and mamba for personal use
# but may be useful for others to install the prereqs for prancc
# because of apt-get calls, needs to be run as superuser
###########

apt-get update
apt-get install build-essential
apt install unzip

curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
# run install script in non-interactive mode

bash Miniforge3-$(uname)-$(uname -m).sh -b -p "/home/${SUDO_USER}/conda"
rm Miniforge3-$(uname)-$(uname -m).sh
source "/home/${SUDO_USER}/conda/etc/profile.d/conda.sh"
# For mamba support also run the following command
source "/home/${SUDO_USER}/conda/etc/profile.d/mamba.sh"

conda activate
conda create -n snakemake -c conda-forge -c bioconda snakemake -y


