# PRANCc
: a Pipeline Researching AMR, Neisseria spp., and CRISPR correlations
Copyright (C) 2023  Tyler Hall, Samantha J. Webster

PRANCc is a pipeline **in progress** to find and identify *cas* genes and CRISPR-Cas systems using [CRISPRCasTyper](https://github.com/Russel88/CRISPRCasTyper#) and find and identify anti-microbial resistance (AMR) genes using [AMRFinder++](https://github.com/ncbi/amr) from whole genome sequences(WGS). Then, using that information, run statistical analyses to find any relationships or possible genetic origins between the two. 

This project was started with data from [Pathogenwatch](https://pathogen.watch) and uses the collected metadata as well as inferred AMR types/NG Star data to verify detected genes. Using that metadata we can also conduct analyses on geographic spread, patterns over time and from sexual behaviour of the hosts.

At the moment this project is fixed to run only for Neisseria gonorrhoeae (N.g.) but when it is finished I want to expand it to at least the organisms covered by AMRFinder++ (~20 or so) and automatically run on multiple organisms automatically.

## Installation
Still a work in progress, but you can clone this repository and run the python scripts yourself. Later versions will have automatic workflow management with Snakemake.

## Contact us
If you have any questions, please feel free to contact us! You can reach me at avcloudy@gmail.com, or both of us at research.ng.crispr@gmail.com. This is very much a work in progress!
