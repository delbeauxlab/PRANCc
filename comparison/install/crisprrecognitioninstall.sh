#!/bin/bash

sudo apt update
sudo apt install default-jre
sudo apt install default-jdk
sudo apt install unzip

mkdir crisprrecognition
cd crisprrecognition
curl -L -O "http://www.room220.com/crt/CRT1.2-CLI_src.zip"
unzip CRT1.2-CLI_src.zip
