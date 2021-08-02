#!/bin/bash

# set -e
MAVEN_TARGET_VERSION=3.6.3
MAVEN_MIN_VERSION=3.3
CMAKE_TARGET_VERSION=3.16.1
CMAKE_MIN_VERSION=3.16
TARGET_CMAKE_SOURCE_URL=https://cmake.org/files/v3.16/cmake-3.16.1.tar.gz
TARGET_CMAKE_TAR_URL=https://github.com/Kitware/CMake/releases/download/v3.16.1/cmake-3.16.1-linux-x86_64.tar.gz
GCC_MIN_VERSION=7.0
LLVM_MIN_VERSION=7.0
rx='^([0-9]+\.){0,2}(\*|[0-9]+)$'
INTEL_ARROW_REPO="https://github.com/oap-project/arrow.git"
ARROW_BRANCH="arrow-4.0.0-oap-1.2"


OAP_VERSION=1.2.0
OAP_BRANCH="branch-1.2"


declare -A repo_dic
repo_dic=([remote-shuffle]="https://github.com/oap-project/remote-shuffle.git" [gazelle_plugin]="https://github.com/oap-project/gazelle_plugin.git" [pmem-shuffle]="https://github.com/oap-project/pmem-shuffle.git" [oap-mllib]="https://github.com/oap-project/oap-mllib.git" [pmem-spill]="https://github.com/oap-project/pmem-spill.git" [pmem-common]="https://github.com/oap-project/pmem-common.git" [sql-ds-cache]="https://github.com/oap-project/sql-ds-cache.git")


if [ -z "$DEV_PATH" ]; then
  OAP_HOME="$(cd "`dirname "$0"`/../.."; pwd)"
  DEV_PATH=$OAP_HOME/dev/
fi

function check_jdk() {
  if [ -z "$JAVA_HOME" ]; then
    echo "To run this script, you must make sure that Java is installed in your environment and set JAVA_HOME"
    exit 1
  fi
}

function check_os {
  if [  -n "$(uname -a | grep Ubuntu)" ]; then
    install_ubuntu_lib
  else
    install_redhat_lib
  fi  
}

function version_lt() { test "$(echo "$@" | tr " " "\n" | sort -rV | head -n 1)" != "$1"; }

function version_ge() { test "$(echo "$@" | tr " " "\n" | sort -rV | head -n 1)" == "$1"; }

function install_ubuntu_lib() {
  apt-get -y update
  apt-get -y install cmake
  apt-get -y install libcurl4-openssl-dev
  apt-get -y install libssl-dev
  apt-get -y install libboost-all-dev
  apt-get -y install autoconf
  apt-get -y install automake
  apt-get -y install libnuma-dev
  apt-get -y install libndctl-dev
  apt-get -y install numactl
  apt-get -y install libtool
  apt-get -y install unzip
  apt-get -y install asciidoctor
  apt-get -y install libkmod-dev libkmod2 kmod
  apt-get -y install libudev-dev libudev1
  apt-get -y install libdaxctl-dev 
  apt-get -y install build-essential
  apt-get -y install autogen
  apt-get -y install pandoc
  apt-get -y install libkmod2
  apt-get -y install libudev1
  apt-get -y install libjemalloc-dev
  apt-get -y pkg-config
  apt-get -y install uuid-dev libuuid1
  apt-get -y install libjson-c-dev
  apt -y install llvm-7
  apt -y install clang-7
}


function install_redhat_lib() {
  yum -y install autoconf
  yum -y install automake
  yum -y install gcc-c++
  yum -y install libtool
  yum -y install numactl-devel
  yum -y install unzip
  yum -y install make
  yum -y install wget
  yum -y install gmp-devel
  yum -y install mpfr-devel
  yum -y install libmpc-devel
  yum -y install rpm-build
  yum -y install libgsasl
  yum -y install libidn-devel.x86_64
  yum -y install libntlm.x86_64
  yum -y install python3
  yum -y install cmake boost-devel boost-system
  yum -y install  epel-release which bash-completion
  yum -y install asciidoctor kmod-devel.x86_64 libudev-devel libuuid-devel json-c-devel jemalloc-devel
  yum -y groupinstall "Development Tools"
  yum -y install pandoc
}

function check_gcc() {
  CURRENT_GCC_VERSION_STR="$(gcc --version)"
  array=(${CURRENT_GCC_VERSION_STR//,/ })
  CURRENT_GCC_VERSION=${array[2]}
  if version_lt $CURRENT_GCC_VERSION $GCC_MIN_VERSION; then
    if [ ! -f "$DEV_PATH/thirdparty/gcc7/bin/gcc" ]; then
      install_gcc7
    fi
    export CXX=$DEV_PATH/thirdparty/gcc7/bin/g++
    export CC=$DEV_PATH/thirdparty/gcc7/bin/gcc
    export LD_LIBRARY_PATH=$DEV_PATH/thirdparty/gcc7/lib64:$LD_LIBRARY_PATH
  fi
}

function check_maven() {
  CURRENT_MAVEN_VERSION_STR="$(mvn --version)"
  array=(${CURRENT_MAVEN_VERSION_STR//,/ })
  CURRENT_MAVEN_VERSION=${array[2]}
  echo $CURRENT_MAVEN_VERSION
  if version_lt $CURRENT_MAVEN_VERSION $MAVEN_MIN_VERSION; then
    install_maven
  fi
}

function install_maven() {
  cd $DEV_PATH/thirdparty
  if [ ! -f " $DEV_PATH/thirdparty/apache-maven-$MAVEN_TARGET_VERSION-bin.tar.gz" ]; then
        wget -t 0 -c --no-check-certificate https://mirrors.cnnic.cn/apache/maven/maven-3/$MAVEN_TARGET_VERSION/binaries/apache-maven-$MAVEN_TARGET_VERSION-bin.tar.gz
  fi

  cd /usr/local/
  if [ ! -d "maven" ]; then
    rm -rf /usr/local/maven
    mkdir -p /usr/local/maven
    INSTALL_PATH=/usr/local/maven
  else
    rm -rf /usr/local/maven_oap
    mkdir -p /usr/local/maven_oap
    INSTALL_PATH=/usr/local/maven_oap
  fi
  cd $DEV_PATH/thirdparty
  tar -xzvf apache-maven-$MAVEN_TARGET_VERSION-bin.tar.gz
  mv apache-maven-$MAVEN_TARGET_VERSION/* $INSTALL_PATH
  echo 'export MAVEN_HOME='$INSTALL_PATH >> ~/.bashrc
  echo 'export PATH=$MAVEN_HOME/bin:$PATH' >> ~/.bashrc
  source ~/.bashrc
  rm -rf apache-maven*
  cd $DEV_PATH/thirdparty
}

function prepare_maven() {
  echo "Check maven version......"
  CURRENT_MAVEN_VERSION_STR="$(mvn --version)"
  if [[ "$CURRENT_MAVEN_VERSION_STR" == "Apache Maven"* ]]; then
    echo "mvn is installed"
    array=(${CURRENT_MAVEN_VERSION_STR//,/ })
    CURRENT_MAVEN_VERSION=${array[2]}
    if version_lt $CURRENT_MAVEN_VERSION $MAVEN_MIN_VERSION; then
      install_maven
    fi
  else
    echo "mvn is not installed"
    install_maven
  fi
}

function install_cmake_redhat() {
  mkdir -p $DEV_PATH/thirdparty
  cd $DEV_PATH/thirdparty
  echo " $DEV_PATH/thirdparty/cmake-$CMAKE_TARGET_VERSION.tar.gz"
  if [ ! -f " $DEV_PATH/thirdparty/cmake-$CMAKE_TARGET_VERSION.tar.gz" ]; then
    wget -t 0 -c --no-check-certificate $TARGET_CMAKE_SOURCE_URL
  fi
  tar xvf cmake-$CMAKE_TARGET_VERSION.tar.gz
  cd cmake-$CMAKE_TARGET_VERSION/
  ./bootstrap
  gmake
  gmake install
  rm -f /usr/bin/cmake
  ln -s /usr/local/bin/cmake /usr/bin/
  cd  $DEV_PATH
}



function install_cmake_ubuntu() {
  mkdir -p $DEV_PATH/thirdparty
  cd $DEV_PATH/thirdparty
  wget -t 0 -c --no-check-certificate $TARGET_CMAKE_TAR_URL
  tar -xzf cmake-$CMAKE_TARGET_VERSION-linux-x86_64.tar.gz
  mkdir -p  /usr/local/cmake
  cp -r cmake-$CMAKE_TARGET_VERSION-Linux-x86_64/* /usr/local/cmake

  echo 'export PATH=/usr/local/cmake/bin:$PATH' >> ~/.bashrc
  source ~/.bashrc
  cd  $DEV_PATH
}

function install_cmake {
  if [  -n "$(uname -a | grep Ubuntu)" ]; then
    install_cmake_ubuntu
  else
    install_cmake_redhat
  fi  
}

function prepare_cmake() {
  CURRENT_CMAKE_VERSION_STR="$(cmake --version)"
  cd  $DEV_PATH

  if [[ "$CURRENT_CMAKE_VERSION_STR" == "cmake version"* ]]; then
    echo "cmake is installed"
    array=(${CURRENT_CMAKE_VERSION_STR//,/ })
    CURRENT_CMAKE_VERSION=${array[2]}
    if version_lt $CURRENT_CMAKE_VERSION $CMAKE_MIN_VERSION; then
      echo "$CURRENT_CMAKE_VERSION is less than $CMAKE_MIN_VERSION,install cmake $CMAKE_TARGET_VERSION"
      
      install_cmake
    fi
  else
    echo "cmake is not installed"
    install_cmake
  fi
}

function prepare_memkind() {
  memkind_repo="https://github.com/memkind/memkind.git"
  echo $memkind_repo

  mkdir -p $DEV_PATH/thirdparty
  cd $DEV_PATH/thirdparty
  if [ ! -d "memkind" ]; then
    git clone $memkind_repo
  fi
  cd memkind/
  git pull
  git checkout v1.10.1

  ./autogen.sh
  ./configure
  make
  make install
  cd  $DEV_PATH

}

function prepare_vmemcache() {
  if [ -n "$(rpm -qa | grep libvmemcache)" ]; then
    echo "libvmemcache is installed"
    return
  elif [ -n "$(dpkg -l|grep libvmemcache)" ]; then
    echo "libvmemcache is installed"
    return
  fi

  vmemcache_repo="https://github.com/pmem/vmemcache.git"
  prepare_cmake
  cd  $DEV_PATH
  mkdir -p $DEV_PATH/thirdparty
  cd $DEV_PATH/thirdparty
  if [ ! -d "vmemcache" ]; then
    git clone $vmemcache_repo
  fi
  cd vmemcache
  git pull
  mkdir -p build
  cd build
  if [  -n "$(uname -a | grep Ubuntu)" ]; then
    cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DCPACK_GENERATOR=deb
    make package
    sudo dpkg -i libvmemcache*.deb
  else
    cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DCPACK_GENERATOR=rpm
    make package
    rpm -i libvmemcache*.rpm
  fi  
  
}

function install_gcc7() {
  #for gcc7

  cd $DEV_PATH/thirdparty

  if [ ! -d "gcc-7.3.0" ]; then
    if [ ! -f "gcc-7.3.0.tar" ]; then
      if [ ! -f "gcc-7.3.0.tar.xz" ]; then
        wget -t 0 -c  --no-check-certificate https://bigsearcher.com/mirrors/gcc/releases/gcc-7.3.0/gcc-7.3.0.tar.xz
      fi
      xz -d gcc-7.3.0.tar.xz
    fi
    tar -xvf gcc-7.3.0.tar
  fi

  cd gcc-7.3.0/
  mkdir -p $DEV_PATH/thirdparty/gcc7
  ./configure --prefix=$DEV_PATH/thirdparty/gcc7 --disable-multilib
  make -j
  make install
}

function prepare_llvm() {
  check_gcc
  CURRENT_LLVM_VERSION_STR=`export LD_LIBRARY_PATH=$DEV_PATH/thirdparty/gcc7/lib64:$LD_LIBRARY_PATH;llvm-config --version`
  if [[ $CURRENT_LLVM_VERSION_STR =~ $rx  ]]; then
    if version_ge $CURRENT_LLVM_VERSION_STR $LLVM_MIN_VERSION; then
      echo "llvm is installed"
      return
    fi
  fi
  echo "Start to build and install llvm7....."
  cd $DEV_PATH
  mkdir -p $DEV_PATH/thirdparty/llvm
  cd $DEV_PATH/thirdparty/llvm
  if [ ! -d "llvm-7.0.1.src" ]; then
    if [ ! -f "llvm-7.0.1.src.tar.xz" ]; then
      wget -t 0 -c --no-check-certificate http://releases.llvm.org/7.0.1/llvm-7.0.1.src.tar.xz
    fi
    tar xf llvm-7.0.1.src.tar.xz
  fi
  cd llvm-7.0.1.src/
  mkdir -p tools
  cd tools

  if [ ! -d "clang" ]; then
    if [ ! -f "cfe-7.0.1.src.tar.xz" ]; then
      wget -t 0 -c --no-check-certificate http://releases.llvm.org/7.0.1/cfe-7.0.1.src.tar.xz
      tar xf cfe-7.0.1.src.tar.xz
    fi
    mv cfe-7.0.1.src clang
  fi
  cd ..
  mkdir -p build
  cd build


  cmake -DCMAKE_BUILD_TYPE=Release ..
  cmake --build .
  cmake --build . --target install

}

function prepare_intel_arrow() {
  prepare_cmake
  if [  -z "$(uname -a | grep Ubuntu)" ]; then
    prepare_llvm
  fi  

  cd $DEV_PATH
  mkdir -p $DEV_PATH/thirdparty/
  cd $DEV_PATH/thirdparty/
  if [ ! -d "arrow" ]; then
    git clone $INTEL_ARROW_REPO -b $ARROW_BRANCH
    cd arrow
  else
    cd arrow
    git checkout -f $ARROW_BRANCH
    git pull
  fi
  git branch
#  exit 0
  current_arrow_path=$(pwd)
  mkdir -p cpp/release-build
  check_gcc

  cd cpp/release-build
  cmake -DCMAKE_BUILD_TYPE=Release -DARROW_PLASMA_JAVA_CLIENT=on -DARROW_PLASMA=on -DARROW_DEPENDENCY_SOURCE=BUNDLED -DARROW_GANDIVA_JAVA=ON -DARROW_GANDIVA=ON -DARROW_PARQUET=ON -DARROW_HDFS=ON -DARROW_BOOST_USE_SHARED=ON -DARROW_JNI=ON -DARROW_WITH_SNAPPY=ON -DARROW_FILESYSTEM=ON -DARROW_JSON=ON -DARROW_WITH_PROTOBUF=ON -DARROW_DATASET=ON -DARROW_WITH_LZ4=ON -DARROW_WITH_FASTPFOR=ON -DARROW_CSV=ON -DARROW_S3=ON -DARROW_WITH_ZSTD=OFF -DARROW_WITH_BROTLI=OFF -DARROW_WITH_ZLIB=OFF -DARROW_FLIGHT=OFF -DARROW_JEMALLOC=ON -DARROW_SIMD_LEVEL=AVX2 -DARROW_RUNTIME_SIMD_LEVEL=MAX -DARROW_COMPUTE=ON ..
  make -j
  make install
  cd ../../java
  mvn clean install -P arrow-jni -am -Darrow.cpp.build.dir=$current_arrow_path/cpp/release-build/release/ -DskipTests -Dcheckstyle.skip
}


function prepare_intel_conda_arrow() {
  cd /root/miniconda2/envs/oapbuild/lib/
  ln -snf libarrow_dataset_jni.so.400 libarrow_dataset_jni.so
  ln -snf libarrow_dataset.so.400 libarrow_dataset.so
  ln -snf libarrow.so.400 libarrow.so
  ln -snf libgandiva.so.400 libgandiva.so
  ln -snf libgandiva_jni.so.400 libgandiva_jni.so
  cd $DEV_PATH
  mkdir -p $DEV_PATH/thirdparty/
  cd $DEV_PATH/thirdparty/
  if [ ! -d "arrow" ]; then
    git clone $INTEL_ARROW_REPO -b $ARROW_BRANCH
    cd arrow
  else
    cd arrow
    git checkout -f $ARROW_BRANCH
    git pull
  fi
  current_arrow_path=$(pwd)

  cd java/
  mvn clean install  -P arrow-jni -am -Darrow.cpp.build.dir=/root/miniconda2/envs/oapbuild/lib/ -DskipTests -Dcheckstyle.skip
}


function prepare_libfabric() {
  mkdir -p $DEV_PATH/thirdparty
  cd $DEV_PATH/thirdparty
  if [ ! -d "libfabric" ]; then
    git clone https://github.com/ofiwg/libfabric.git
  fi
  cd libfabric
  git checkout v1.6.0
  ./autogen.sh

  if [ -z "$ENABLE_RDMA" ]; then
    ENABLE_RDMA=false
  fi

  if $ENABLE_RDMA
  then
      ./configure --disable-sockets --enable-verbs --disable-mlx
  else
      ./configure --disable-sockets --disable-verbs --disable-mlx
  fi

  make -j &&  make install
}

function prepare_HPNL(){
  prepare_libfabric
  mkdir -p $DEV_PATH/thirdparty
  cd $DEV_PATH/thirdparty
  if [ ! -d "HPNL" ]; then
    git clone https://github.com/Intel-bigdata/HPNL.git
  fi
  cd HPNL
  git checkout origin/spark-pmof-test --track
  git submodule update --init --recursive
  mkdir build
  cd build
  cmake -DWITH_VERBS=ON -DWITH_JAVA=ON ..
  make -j && make install
  cd ../java/hpnl
  mvn  install -DskipTests
}

function prepare_ndctl() {

  mkdir -p $DEV_PATH/thirdparty
  cd $DEV_PATH/thirdparty
  if [ ! -d "ndctl" ]; then
    git clone https://github.com/pmem/ndctl.git
  fi
  cd ndctl
  git checkout v63
  ./autogen.sh
  ./configure CFLAGS='-g -O2' --prefix=/usr --sysconfdir=/etc --libdir=/usr/lib64
  make -j
  make check
  make install
}

function prepare_PMDK() {
  prepare_ndctl
  mkdir -p $DEV_PATH/thirdparty
  cd $DEV_PATH/thirdparty
  if [ ! -d "pmdk" ]; then
    git clone https://github.com/pmem/pmdk.git
  fi
  cd pmdk
  git checkout tags/1.8
  if [  -n "$(uname -a | grep Ubuntu)" ]; then
    make NDCTL_ENABLE=n
    make NDCTL_ENABLE=n install
  else
    make -j && make install
  fi 
  
  export PKG_CONFIG_PATH=/usr/local/lib64/pkgconfig/:$PKG_CONFIG_PATH
  echo 'export PKG_CONFIG_PATH=/usr/local/lib64/pkgconfig/:$PKG_CONFIG_PATH' > /etc/profile.d/pmdk.sh
  source /etc/profile
}

function prepare_libcuckoo() {
  mkdir -p $DEV_PATH/thirdparty
  cd $DEV_PATH/thirdparty
  git clone https://github.com/efficient/libcuckoo
  cd libcuckoo
  mkdir build
  cd build
  cmake -DCMAKE_INSTALL_PREFIX=/usr/local -DBUILD_EXAMPLES=1 -DBUILD_TESTS=1 ..
  make all && make install
}

function prepare_PMoF() {
  prepare_libfabric
  prepare_HPNL
  prepare_ndctl
  prepare_PMDK
  prepare_libcuckoo
  cd $DEV_PATH
}

function prepare_oneAPI() {
  cd $DEV_PATH/
  cd ../oap-mllib/dev/
  
  if [  -n "$(uname -a | grep Ubuntu)" ]; then
    sh install-build-deps-ubuntu.sh
  else
    sh install-build-deps-centos.sh
  fi 
}

function clone_all(){
    echo "Start to git clone all OAP modules ..."
    for key in $(echo ${!repo_dic[*]})
    do
        echo "$key : ${repo_dic[$key]}"
        cd $OAP_HOME
        if [ ! -d $key ]; then
            git clone ${repo_dic[$key]} -b $OAP_BRANCH 
        else
            cd $key
            git pull
            git checkout  $OAP_BRANCH 
        fi
    
    done
}

function  prepare_conda_build() {
  prepare_maven
  prepare_memkind
  prepare_cmake
  prepare_vmemcache
  prepare_intel_conda_arrow
  prepare_PMoF
  prepare_oneAPI
}

function  prepare_all() {
  prepare_maven
  prepare_memkind
  prepare_cmake
  prepare_vmemcache
  prepare_intel_arrow
  prepare_PMoF
  prepare_oneAPI
}

function oap_build_help() {
    echo " --prepare_maven            function to install Maven"
    echo " --prepare_memkind          function to install Memkind"
    echo " --prepare_cmake            function to install Cmake"
    echo " --install_gcc7             function to install GCC 7.3.0"
    echo " --prepare_vmemcache        function to install Vmemcache"
    echo " --prepare_intel_arrow      function to install intel Arrow"
    echo " --prepare_HPNL             function to install intel HPNL"
    echo " --prepare_PMDK             function to install PMDK "
    echo " --prepare_PMoF             function to install PMoF"
    echo " --prepare_all              function to install all the above"
}

check_jdk

while [[ $# -gt 0 ]]
do
key="$1"
case $key in
    --prepare_all)
    shift 1 
    echo "Start to install all compile-time dependencies for OAP ..."
    clone_all
    check_os
    prepare_all
    exit 0
    ;;
    --prepare_conda_build)
    shift 1
    echo "Start to install all conda compile-time dependencies for OAP ..."
    clone_all
    check_os
    prepare_conda_build
    exit 0
    ;;
    --prepare_maven)
    shift 1 
    prepare_maven
    exit 0
    ;;
    --prepare_memkind)
    shift 1 
    prepare_memkind
    exit 0
    ;;
    --prepare_cmake)
    shift 1 
    prepare_cmake
    exit 0
    ;;
    --install_gcc7)
    shift 1 
    install_gcc7
    exit 0
    ;;
    --prepare_vmemcache)
    shift 1 
    prepare_vmemcache
    exit 0
    ;;
    --prepare_intel_arrow)
    shift 1 
    prepare_intel_arrow
    exit 0
    ;;
    --prepare_HPNL)
    shift 1 
    prepare_HPNL
    exit 0
    ;;
    --prepare_PMDK)
    shift 1 
    prepare_PMDK
    exit 0
    ;;
    --prepare_PMoF)
    shift 1 
    prepare_PMoF
    exit 0
    ;;
    --prepare_llvm)
    shift 1 
    prepare_llvm
    exit 0
    ;;
    *)    # unknown option
    echo "Unknown option "
    echo "usage: sh prepare_oap_env.sh [options]"
    echo "Options: "
    oap_build_help
    exit 1
    ;;
esac
done
