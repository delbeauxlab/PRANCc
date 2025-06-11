# PRANCc
: a Pipeline Researching AMR, Neisseria spp., and CRISPR correlations
v0.2.2-beta

Copyright (C) 2023, 2024-2025  Tyler Hall, Samantha J. Webster

PRANCc is a pipeline **in progress** to find and identify *cas* genes and CRISPR-Cas systems using [CRISPRCasTyper](https://github.com/Russel88/CRISPRCasTyper#) and find and identify anti-microbial resistance (AMR) genes using [AMRFinder++](https://github.com/ncbi/amr) from whole genome sequences(WGS). Then, using that information, run statistical analyses to find any relationships or possible genetic origins between the two. 

This project was started with data from [Pathogenwatch](https://pathogen.watch) and uses the collected metadata as well as inferred AMR types/NG Star data to verify detected genes. Using that metadata we can also conduct analyses on geographic spread, patterns over time and from sexual behaviour of the hosts.

## Installation
To install, install the prerequisites, or ask your system admin to. comparison/install/awsinstall.sh is how I installed these prereqs, but that script is provided as-is and is Ubuntu/Debian specific. For compatibility reasons, it's best to install this on a clean slate. Due to the HMM model requirements of CRISPRIdentify, this installer will download about 1GB.

### Installs

* [CrisprCasFinder](https://github.com/dcouvin/CRISPRCasFinder) (into Conda environment 'crisprcasfinder')
    * [MacSyFinder](https://github.com/gem-pasteur/macsyfinder)
    * [CasFinder](https://github.com/macsy-models/CasFinder)
* [PADLOC](https://github.com/padlocbio/padloc/tree/master) (into Conda environment 'padloc')
    * [CrisprDetect](https://github.com/ambarishbiswas/CRISPRDetect_2.2)
* [CrisprCasTyper](https://github.com/Russel88/CRISPRCasTyper)
* [CRISPRIdentify](https://github.com/BackofenLab/CRISPRidentify)
* [gdown](https://github.com/wkentaro/gdown)
* the various prereqs of those programs

### Prerequisites

* Linux
* Conda
* Mamba (I recommend installing Miniforge which includes both Conda and Mamba. You can find it at https://github.com/conda-forge/miniforge)
* Snakemake
* build-essential (or your Linux flavour of `make`, if not installed by default)
* unzip
 
### Setup

1. Download and extract this repository 
1. Make sure the preequisites are installed and ready to use (make sure Conda and Mamba are initialised, particularly!)
1. Run comparison/install/snakeinstall.sh
1. You're done!

## Run

1. Add all the .fna files you want to analyse to the prancc/upload folder
1. Activate the snakemake environment (if you used my install script, `conda activate snakemake`)
1. Navigate to where the PRANCc folder was extracted
1. `snakemake`

See https://snakemake.readthedocs.io/en/v5.1.4/executable.html for more information about executing snakemake workflows.

## Output
Produces a tarball results.tar.gz in the prancc folder containing:

* The raw output of:
    * CrisprCasFinder
    * CrisprCasTyper
    * CRISPRIdentify
    * CrisprDetect
    * PADLOC
* .tsv sheets of the summarised output of:
    * CrisprCasFinder (crispr and cas)
    * CrisprCasTyper
    * CRISPRIdentify
    * PADLOC
    * version logs of all environments and conda

## Contact us
If you have any questions, please feel free to contact us! You can reach me at avcloudy@gmail.com, or both of us at delbeauxlab@gmail.com. This is very much a work in progress!
