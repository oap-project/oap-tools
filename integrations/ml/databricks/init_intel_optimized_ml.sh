#!/bin/bash

VERSION_8_P='^8.[0-3]$'
VERSION_9_P='^9.*$'

if [[ $DATABRICKS_RUNTIME_VERSION == "7.3" ]]; then
  if [ -n $DATABRICKS_ROOT_CONDA_ENV ]; then
    echo 'export USE_DAAL4PY_SKLEARN=YES' >> ~/.bashrc
    conda install -c intel scikit-learn pandas 
    pip install intel-tensorflow==2.3.0 
  else
    pip install intel-tensorflow==2.3.0
    pip install scikit-learn-intelex
  fi
elif [[ $DATABRICKS_RUNTIME_VERSION == "9.1" ]] || [[ $DATABRICKS_RUNTIME_VERSION == "10.1" ]]; then
    pip install intel-tensorflow==2.6.0
    pip install scikit-learn-intelex
elif [[ $DATABRICKS_RUNTIME_VERSION == "10.2" ]] || [[ $DATABRICKS_RUNTIME_VERSION == "10.3" ]]; then
    pip install intel-tensorflow==2.7.0
    pip install scikit-learn-intelex
elif [[ $DATABRICKS_RUNTIME_VERSION == "10.4" ]] || [[ $DATABRICKS_RUNTIME_VERSION =~ $VERSION_11_P ]]; then
    pip install intel-tensorflow==2.8.0
    pip install scikit-learn-intelex
fi