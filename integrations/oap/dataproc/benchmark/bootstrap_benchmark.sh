#!/bin/bash

SOFTWARE_HOME=/opt/benchmark-tools
mkdir -p $SOFTWARE_HOME 

function install_ubuntu_debian_lib() {
  apt-get -y update
  apt-get install apt-transport-https curl gnupg -yqq
  echo "deb https://repo.scala-sbt.org/scalasbt/debian all main" | tee /etc/apt/sources.list.d/sbt.list
  echo "deb https://repo.scala-sbt.org/scalasbt/debian /" | tee /etc/apt/sources.list.d/sbt_old.list
  curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/scalasbt-release.gpg --import
  chmod 644 /etc/apt/trusted.gpg.d/scalasbt-release.gpg
  apt-get -y update
  apt-get -y install sbt
  apt -y install maven
  apt -y install libjemalloc-dev
  apt-get -y install flex bison byacc
}


function install_centos_lib() {
  cd $SOFTWARE_HOME
  rm -f /etc/yum.repos.d/bintray-rpm.repo
  curl -L https://www.scala-sbt.org/sbt-rpm.repo > sbt-rpm.repo
  mv sbt-rpm.repo /etc/yum.repos.d/
  yum -y install sbt
  yum -y install wget
  wget http://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo
  yum -y install maven
  yum -y install flex bison byacc
  yum -y install jemalloc-devel
}

function check_os() {
  if [  -f  "/etc/debian_version" ]; then
    install_ubuntu_debian_lib
  else
    install_centos_lib
  fi  
}

 
function install_spark_sql_perf() {
  cd $SOFTWARE_HOME
  git clone https://github.com/databricks/spark-sql-perf.git && cd spark-sql-perf
  wget https://raw.githubusercontent.com/oap-project/oap-tools/master/integrations/oap/dataproc/spark-sql-perf.patch
  git apply spark-sql-perf.patch
  sbt package
}


function install_tpcds_kit() {
  cd $SOFTWARE_HOME && git clone https://github.com/databricks/tpcds-kit.git
  cd tpcds-kit/tools
  make OS=LINUX
}


function install_hibench() {
   cd $SOFTWARE_HOME
   git clone https://github.com/Intel-bigdata/HiBench.git && cd HiBench
   mvn -Psparkbench -Dmodules -Pml -Pmicro -Dspark=3.1 -Dscala=2.12 -DskipTests clean package
}


function install_tpcds() {
  install_spark_sql_perf
  install_tpcds_kit
}


function usage() {
  echo "Usage: $0 --all|--tpcds|--hibench|-h|--help" >&2
}


while [[ $# -ge 0 ]]
do
key="$1"
case $key in
    "")
    shift 1
    echo "Start to deploy all benchmark for OAP ..."
    check_os
    install_hibench
    install_tpcds
    exit 0
    ;;
    --tpcds)
    shift 1
    check_os
    install_tpcds
    exit 0
    ;;
    --hibench)
    shift 1
    check_os
    install_hibench
    exit 0
    ;;
    -h|--help)
    shift 1
    usage
    exit 0
    ;;
    *)    # unknown option
    echo "Unknown option"
    usage
    exit 1
    ;;
esac
done

