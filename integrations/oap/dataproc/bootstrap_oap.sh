#!/bin/bash

oap_install_dir=/opt/benchmark-tools/oap
mkdir -p $oap_install_dir
conda_install_dir=/opt/benchmark-tools/conda


## Step 1: install conda
wget -c https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh -P /tmp
chmod +x /tmp/Miniconda2-latest-Linux-x86_64.sh
bash /tmp/Miniconda2-latest-Linux-x86_64.sh -b -p ${conda_install_dir}
${conda_install_dir}/bin/conda init
source ~/.bashrc

## Step 2: conda install oap

conda create -p ${oap_install_dir} -c conda-forge -c intel -y oap=1.3.1.dataproc20
