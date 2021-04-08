#!/bin/bash

apt-get update
apt-get install --yes --no-install-recommends --fix-missing  libc6 
rm -rf /var/lib/apt/lists/*
echo 'export USE_DAAL4PY_SKLEARN=YES' >> ~/.bashrc
conda install -c intel python=3.7.9 scikit-learn pandas libffi=3.3  
conda install -c intel icc_rt=2021.1.2
conda uninstall --force  mkl
conda install -c intel mkl=2021.1.1
conda install -c intel daal4py=2021.1
conda install -c intel ipykernel ipython
pip install intel-tensorflow==2.3.0