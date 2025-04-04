#!/bin/bash

# download miniforge installer from github
curl -L -O "https://github.com/conda-forge/miniforge/releases/download/25.1.1-2/Miniforge3-25.1.1-2-Linux-x86_64.sh"
# run install script in non-interactive mode
bash Miniforge3-25.1.1-2-Linux-x86_64.sh -b
rm Miniforge3-25.1.1-2-Linux-x86_64.sh

mkdir CRISPRidentify
curl -L -O "https://github.com/BackofenLab/CRISPRidentify/archive/refs/tags/v1.2.1.tar.gz"
tar -xzvf v1.2.1.tar.gz -C CRISPRidentify --strip-components=1
rm v1.2.1.tar.gz
curl -L -O "https://github.com/BackofenLab/CRISPRcasIdentifier/archive/refs/tags/v1.1.0.tar.gz"
tar -xzvf v1.1.0.tar.gz -C CRISPRidentify/tools/CRISPRcasIdentifier/CRISPRcasIdentifier --strip-components=1
rm v1.1.0.tar.gz

# need to download HMM and ML models from google drive
# https://drive.google.com/file/d/1YbTxkn9KuJP2D7U1-6kL1Yimu_4RqSl1/view?usp=sharing
# https://drive.google.com/file/d/1Nc5o6QVB6QxMxpQjmLQcbwQwkRLk-thM/view?usp=sharing
# a tool exists for this - pip install gdown - but I would rather download these and upload to the server.
# then if i make an ami the extracted files will be included 
# they need to live in the double cci folder
# scp -i key.pem ubuntu@123.123.123.123:~/CRISPRidentify/tools/CRISPRcasIdentifier/CRISPRcasIdentifier
# apparently unextracted
