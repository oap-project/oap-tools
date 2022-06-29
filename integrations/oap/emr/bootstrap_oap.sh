#!/bin/bash
oap_install_dir=/opt/benchmark-tools/oap
sudo mkdir -p $oap_install_dir
conda_install_dir=/opt/benchmark-tools/conda
sudo yum -y install wget

## Step 1: install conda
sudo wget -c https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh -P /tmp
sudo chmod +x /tmp/Miniconda2-latest-Linux-x86_64.sh
sudo bash /tmp/Miniconda2-latest-Linux-x86_64.sh -b -p ${conda_install_dir}
${conda_install_dir}/bin/conda init
source ~/.bashrc
sudo chown $(whoami):$(whoami) ${oap_install_dir}

if [ -n "$1" ];then
    oap_version=$1
else
    oap_version=1.2.0
fi

## Step 2: install oap
conda create -c conda-forge -c intel-beaver -c intel-bigdata -c intel -y oap=${oap_version} -p ${oap_install_dir}
