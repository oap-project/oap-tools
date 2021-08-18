#!/bin/bash

if [ -n $DATABRICKS_ROOT_CONDA_ENV ]; then
  if [ $DATABRICKS_RUNTIME_VERSION == "7.6" ] ; then

    echo 'export USE_DAAL4PY_SKLEARN=YES' >> ~/.bashrc
    conda install -c intel scikit-learn pandas 
    pip install intel-tensorflow==2.3.0
  fi
fi