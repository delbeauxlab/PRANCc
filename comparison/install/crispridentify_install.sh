#!/bin/bash

# this is an elaborate setup to get the CRISPRcasIdentifier tool in the right place
# yes, thats right, CRISPRidentify/tools/CRISPRcasIdentifier/CRISPRcasIdentifier
# i just work here
curl -L -O "https://github.com/BackofenLab/CRISPRidentify/archive/refs/tags/v1.2.1.tar.gz"
tar -xvf v1.2.1.tar.gz
rm v1.2.1.tar.gz
cd CRISPRidentify-1.2.1
cd tools/CRISPRcasIdentifier
curl -L -O "https://github.com/BackofenLab/CRISPRcasIdentifier/archive/refs/tags/v1.1.0.tar.gz"
tar -xvf "v1.1.0.tar.gz"
rm v1.1.0.tar.gz
rm -r CRISPRcasIdentifier
mv CRISPRcasIdentifier-1.1.0 CRISPRcasIdentifier
cd

curl -L -O "https://github.com/conda-forge/miniforge/releases/download/25.1.1-2/Miniforge3-25.1.1-2-Linux-x86_64.sh"
bash Miniforge3-25.1.1-2-Linux-x86_64.sh -b
rm Miniforge3-25.1.1-2-Linux-x86_64.sh

~/miniforge3/bin/conda init

#mamba not actually initialised here
#mamba env create -f environment.yml -n crispridentify

#run command
#python CRISPRidentify.py --input_folder ~/upload --result_folder ~/crispridentifyresults
