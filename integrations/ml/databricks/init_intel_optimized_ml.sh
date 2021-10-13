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
elif [[ $DATABRICKS_RUNTIME_VERSION =~ $VERSION_8_P ]]; then
    pip install intel-tensorflow==2.4.0
    pip install scikit-learn-intelex
elif [[ $DATABRICKS_RUNTIME_VERSION =~ "9.0" ]] || [[ $DATABRICKS_RUNTIME_VERSION == "8.4" ]]; then
    pip install intel-tensorflow==2.5.0
    pip install scikit-learn-intelex
elif [[ $DATABRICKS_RUNTIME_VERSION =~ $VERSION_9_P ]]; then
    pip install intel-tensorflow==2.6.0
    pip install scikit-learn-intelex
fi