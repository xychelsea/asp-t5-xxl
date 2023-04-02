#!/bin/bash

ANACONDA_PATH=/opt/anaconda3
ANACONDA_BIN=${ANACONDA_PATH}/bin
ANACONDA_ENV=asp

# add our condabin path now
export PATH=${ANACONDA_BIN}:${PATH}

# update and install dependencies
sudo apt update
sudo apt install -y \
    git \
    unzip \
    wget

# download and install Miniforge3
wget -O ~/Miniforge3-23.1.0-1-Linux-x86_64.sh \
    https://github.com/conda-forge/miniforge/releases/download/23.1.0-1/Miniforge3-23.1.0-1-Linux-x86_64.sh
chmod +x ~/Miniforge3-23.1.0-1-Linux-x86_64.sh
/bin/bash ~/Miniforge3-23.1.0-1-Linux-x86_64.sh -b -u -p ${ANACONDA_PATH}
rm -rvf ~/Miniforge3-23.1.0-1-Linux-x86_64.sh

# prepare our environment
echo ". ${ANACONDA_PATH}/etc/profile.d/conda.sh" >> ~/.bashrc \
echo "conda activate \${ANACONDA_ENV}" >> ~/.bashrc \

# we need to reload bash profile
source ~/.bashrc

# update conda
${ANACONDA_BIN}/conda update -n base -c conda-forge conda

# download our repository
git clone https://github.com/xychelsea/asp-t5-xxl ~/asp-t5-xxl
cd ~/asp-t5-xxl

export ASP=$PWD

# initialize conda environment
${ANACONDA_BIN}/conda env create -f environment.yml

# enter our environment
${ANACONDA_BIN}/conda activate ${ANACONDA_ENV}

# download and decompress dataset
wget -O ./data/conll03_ner.zip https://polybox.ethz.ch/index.php/s/bFf8vJBonIT7sr8/download
unzip ./data/conll03_ner.zip -d ./data
rm ./data/conll03_ner.zip

# update tokenizers
${ANACONDA_BIN}/conda update -n ${ANACONDA_ENV} tokenizers

# prepare dataset
${ANACONDA_BIN}/conda run -n ${ANACONDA_ENV} python ./data/conll03_ner/conll03_to_json.py

# finalize preparation for named entity recognition
${ANACONDA_BIN}/conda run -n ${ANACONDA_ENV} python ./data/t5minimize_ner.py ./data/conll03_ner ./data/conll03_ner
