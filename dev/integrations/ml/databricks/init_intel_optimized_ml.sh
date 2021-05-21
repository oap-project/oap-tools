#!/bin/bash

if [ -z $DATABRICKS_ROOT_CONDA_ENV ]; then
	pip install intel-tensorflow==2.3.0
  pip install scikit-learn-intelex
else
  if [ $DATABRICKS_RUNTIME_VERSION == "7.5" ] || [ $DATABRICKS_RUNTIME_VERSION == "7.6" ] ; then
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
  elif [ $DATABRICKS_RUNTIME_VERSION == "8.0" ]; then
    pip install intel-tensorflow==2.3.0
    pip install scikit-learn-intelex
  elif [ $DATABRICKS_RUNTIME_VERSION == "8.1" ]; then
    pip install intel-tensorflow==2.3.0
    pip install scikit-learn-intelex
  elif [ $DATABRICKS_RUNTIME_VERSION == "8.2" ]; then
    pip install intel-tensorflow==2.3.0
    pip install scikit-learn-intelex
  fi
fi