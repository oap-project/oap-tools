#!/bin/bash

# set -e

OAP_HOME="$(cd "`dirname "$0"`/.."; pwd)"

DEV_PATH=$OAP_HOME/dev

OAP_VERSION=1.2.0

SPARK_VERSION=3.1.1

GCC_MIN_VERSION=7.0

function version_lt() { test "$(echo "$@" | tr " " "\n" | sort -rV | head -n 1)" != "$1"; }

function version_ge() { test "$(echo "$@" | tr " " "\n" | sort -rV | head -n 1)" == "$1"; }


function install_gcc7() {
  #for gcc7
  yum -y install gmp-devel
  yum -y install mpfr-devel
  yum -y install libmpc-devel
  yum -y install wget

  cd $DEV_PATH/thirdparty

  if [ ! -d "gcc-7.3.0" ]; then
    if [ ! -f "gcc-7.3.0.tar" ]; then
      if [ ! -f "gcc-7.3.0.tar.xz" ]; then
        wget https://bigsearcher.com/mirrors/gcc/releases/gcc-7.3.0/gcc-7.3.0.tar.xz
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
  fi
}




function gather() {
  cd  $DEV_PATH
  package_name=oap-$OAP_VERSION-bin-spark-$SPARK_VERSION
  rm -rf $DEV_PATH/release-package/*
  target_path=$DEV_PATH/release-package/$package_name/jars/
  mkdir -p $target_path
  cp ../sql-ds-cache/Plasma-based-cache/target/*spark-*.jar $target_path
  cp ../sql-ds-cache/HCFS-based-cache/target/*.jar $target_path
  cp ../pmem-common/target/*.jar $target_path
  cp ../native-sql-engine/arrow-data-source/standard/target/*with-dependencies.jar $target_path
  cp ../native-sql-engine/native-sql-engine/core/target/*with-dependencies.jar $target_path
  cp ../remote-shuffle/shuffle-daos/target/*.jar $target_path
  cp ../remote-shuffle/shuffle-hadoop/target/*.jar $target_path
  cp ../pmem-shuffle/core/target/*with-dependencies.jar $target_path
  cp ../pmem-spill/RDD-Cache/target/*.jar $target_path
  cp ../oap-mllib/mllib-dal/target/*.jar $target_path

  find $target_path -name "*test*"|xargs rm -rf
  cd $target_path
  rm -f oap-cache-$OAP_VERSION.jar
  cd $DEV_PATH/thirdparty
  if [ ! -d "arrow" ]; then
    sh $DEV_PATH/scripts/prepare_oap_env.sh --prepare_intel_arrow
  fi
  cp $DEV_PATH/thirdparty/arrow/java/plasma/target/arrow-plasma-4.0.0.jar $target_path
  mkdir -p $DEV_PATH/thirdparty/arrow/oap
  rm -rf $DEV_PATH/thirdparty/arrow/oap/*
  cp $target_path/* $DEV_PATH/thirdparty/arrow/oap/
  cd  $DEV_PATH/release-package
  tar -czf $package_name.tar.gz $package_name/
  echo "Please check the result in  $DEV_PATH/release-package!"
}

function build_oap(){
    case $1 in
    arrow-data-source)
    cd $OAP_HOME/arrow-data-source
    mvn clean package -DskipTests
    ;;

    native-sql-engine)
    cd $OAP_HOME/native-sql-engine/
    mvn clean package -am -DskipTests -Dcpp_tests=OFF -Dbuild_arrow=OFF -Dstatic_arrow=OFF  -Dbuild_protobuf=ON
    ;;

    oap-mllib )
    cd $OAP_HOME/oap-mllib/mllib-dal
    source /opt/intel/oneapi/setvars.sh
    source /tmp/oneCCL/build/_install/env/setvars.sh
    mvn clean package  -DskipTests  -Pspark-3.1.1
    ;;

    pmem-common)    
    cd $OAP_HOME/pmem-common
    mvn clean package -Pvmemcache  -Ppersistent-memory  -DskipTests
    ;;

    pmem-shuffle)
    cd $OAP_HOME/pmem-shuffle
    mvn clean package  -DskipTests
    cd $OAP_HOME
    ;;

    pmem-spill)
    cd $OAP_HOME/pmem-common
    mvn clean install -Pvmemcache  -Ppersistent-memory  -DskipTests
    cd $OAP_HOME/pmem-spill
    mvn clean package  -DskipTests
    cd $OAP_HOME
    ;;

    remote-shuffle)
    cd $OAP_HOME/remote-shuffle
    mvn clean package  -DskipTests
    ;;

    sql-ds-cache)
    cd $OAP_HOME/pmem-common
    mvn clean install -Pvmemcache  -Ppersistent-memory  -DskipTests
    cd $OAP_HOME/sql-ds-cache
    mvn clean package  -DskipTests
    ;;

    *)    # unknown option
    echo "Unknown option "
    exit 1
    ;;
esac
}

check_gcc
cd $OAP_HOME
while [[ $# -ge 0 ]]
do
key="$1"
case $key in
    "")
    shift 1
    echo "Start to compile all modules of OAP ..."
    build_oap native-sql-engine
    build_oap oap-mllib
    build_oap pmem-shuffle
    build_oap pmem-spill
    build_oap remote-shuffle
    build_oap sql-ds-cache
    gather
    exit 0
    ;;
    --arrow-data-source)
    shift 1
    build_oap arrow-data-source
    exit 0
    ;;
    --native-sql-engine)
    shift 1
    build_oap native-sql-engine
    exit 0
    ;;
    --oap-mllib )
    shift 1
    build_oap oap-mllib
    exit 0
    ;;
    --pmem-common)
    shift 1
    build_oap pmem-common
    exit 0
    ;;
    --pmem-shuffle)
    shift 1
    build_oap pmem-shuffle
    exit 0
    ;;
    --pmem-spill)
    shift 1
    build_oap pmem-spill
    exit 0
    ;;
    --remote-shuffle)
    shift 1
    build_oap remote-shuffle
    exit 0
    ;;
    --sql-ds-cache)
    shift 1
    build_oap sql-ds-cache
    exit 0
    ;;
    --oap-conda)
    shift 1
    build_oap oap-mllib
    build_oap pmem-shuffle
    build_oap pmem-spill
    build_oap remote-shuffle
    build_oap sql-ds-cache
    gather
    exit 0
    ;;
    --gather)
    gather
    exit 0
    ;;
    *)    # unknown option
    echo "Unknown option "
    exit 1
    ;;
esac
done

