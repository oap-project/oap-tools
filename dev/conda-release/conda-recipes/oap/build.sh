#!/bin/bash

set -e
set -x
export http_proxy=http://child-prc.intel.com:913
export https_proxy=http://child-prc.intel.com:913
mkdir cpp/build
pushd cpp/build

EXTRA_CMAKE_ARGS=""

# Include g++'s system headers
if [ "$(uname)" == "Linux" ]; then
  SYSTEM_INCLUDES=$(echo | ${CXX} -E -Wp,-v -xc++ - 2>&1 | grep '^ ' | awk '{print "-isystem;" substr($1, 1)}' | tr '\n' ';')
  EXTRA_CMAKE_ARGS=" -DARROW_GANDIVA_PC_CXX_FLAGS=${SYSTEM_INCLUDES}"
fi

cmake \
    -DARROW_WITH_FASTPFOR=ON \
    -DARROW_PLASMA_JAVA_CLIENT=on \
    -DARROW_PLASMA=ON \
    -DARROW_GANDIVA_JAVA=ON \
    -DARROW_GANDIVA=ON \
    -DARROW_PARQUET=ON \
    -DARROW_HDFS=ON \
    -DARROW_BOOST_USE_SHARED=ON \
    -DARROW_JNI=ON \
    -DARROW_WITH_SNAPPY=ON \
    -DARROW_FILESYSTEM=ON \
    -DARROW_JSON=ON \
    -DARROW_WITH_PROTOBUF=ON \
    -DARROW_DATASET=ON \
    -DARROW_WITH_LZ4=ON \
    -DARROW_CSV=ON \
    -DARROW_S3=ON \
    -DARROW_WITH_ZSTD=OFF \
    -DARROW_WITH_BROTLI=OFF \
    -DARROW_WITH_ZLIB=OFF \
    -DARROW_FLIGHT=OFF \
    -DARROW_JEMALLOC=ON \
    -DARROW_RUNTIME_SIMD_LEVEL=MAX \
    -DARROW_COMPUTE=ON \
    -DARROW_PACKAGE_PREFIX=$PREFIX \
    -DCMAKE_BUILD_TYPE=release \
    -DCMAKE_INSTALL_LIBDIR=$PREFIX/lib \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_RANLIB=${RANLIB} \
    -DLLVM_TOOLS_BINARY_DIR=$PREFIX/bin \
    -GNinja \
    ${EXTRA_CMAKE_ARGS} \
    ..
ninja install
popd
mkdir -p $PREFIX/oap_jars
cp $SRC_DIR/cpp/build/release/libplasma_java.so $PREFIX/lib/
cp $SRC_DIR/oap/*.jar $PREFIX/oap_jars/
cp -r $SRC_DIR/pmdk/lib/* $PREFIX/lib/
mkdir -p $PREFIX/bin
cp -r $SRC_DIR/pmdk/bin/* $PREFIX/bin/
cd $PREFIX/lib/
ln -snf libarrow_dataset_jni.so.400 libarrow_dataset_jni.so
ln -snf libarrow_dataset.so.400 libarrow_dataset.so
ln -snf libarrow.so.400 libarrow.so