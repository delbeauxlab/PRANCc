#!/bin/bash

python CRISPRidentify.py --input_folder ~/upload --result_folder ~/crispridentifyresults

tar -czvf ~/crispridentifyresults.tar.gz ~/crispridentifyresults/*
