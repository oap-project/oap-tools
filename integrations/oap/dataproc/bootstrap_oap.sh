#!/bin/bash

oap_install_dir=/opt/benchmark-tools/oap
sudo mkdir -p $oap_install_dir
conda_install_dir=/opt/benchmark-tools/conda
sudo chown $(whoami):$(whoami) ${oap_install_dir}

## conda install oap

conda create -p ${oap_install_dir}  -c conda-forge -c intel-beaver -c intel -c intel-bigdata -y oap=1.2.0.dataproc20

