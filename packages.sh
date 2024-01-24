#!/bin/bash

sudo apt-get update
sudo apt install -y htop
sudo apt install -y screen

miniconda_path=~/miniconda3
mkdir -p $miniconda_path
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O $miniconda_path/miniconda.sh
bash $miniconda_path/miniconda.sh -b -u -p $miniconda_path
rm -rf $miniconda_path/miniconda.sh

conda_bin=$miniconda_path/bin/conda
if [ -e "$conda_bin" ]; then
	$miniconda_path/bin/conda init bash
	echo "miniconda installation successful"
else
	echo "Error conda installation"
fi

