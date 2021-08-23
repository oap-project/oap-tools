#!/bin/bash
VERSION_8_P='^8.*$'

if [[ $DATABRICKS_RUNTIME_VERSION == "7.3" ]]; then
    pip install intel-tensorflow==2.3.0
    pip install scikit-learn-intelex
elif [[ $DATABRICKS_RUNTIME_VERSION =~ $VERSION_8_P ]]; then
    pip install intel-tensorflow==2.4.0
    pip install scikit-learn-intelex
fi
