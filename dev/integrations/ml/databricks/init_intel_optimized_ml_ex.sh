#!/bin/bash

if [ -z $DATABRICKS_ROOT_CONDA_ENV ]; then
	pip install intel-tensorflow==2.3.0
  pip install scikit-learn-intelex
else
  if [ $DATABRICKS_RUNTIME_VERSION == "8.0" ]; then
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