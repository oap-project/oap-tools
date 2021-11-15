#!/bin/bash

set -e
set -x

mkdir -p $PREFIX/oap_jars
cp $SRC_DIR/oap/*.jar $PREFIX/oap_jars/
