#!/bin/bash

set -e
set -x

mkdir -p $PREFIX/oap_jars
cp -r $SRC_DIR/* $PREFIX/oap_jars/
