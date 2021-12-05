#!/bin/bash

set -e
set -x

mkdir -p $PREFIX/oap_jars
cp $SRC_DIR/*.jar $PREFIX/oap_jars/
