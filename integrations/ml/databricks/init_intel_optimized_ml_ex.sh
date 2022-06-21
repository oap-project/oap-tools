#!/bin/bash
VERSION_11_P='^11.*$'
if [[ $DATABRICKS_RUNTIME_VERSION == "7.3" ]]; then
    pip install intel-tensorflow==2.3.0
    pip install scikit-learn-intelex
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