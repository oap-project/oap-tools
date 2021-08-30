#!/bin/bash
sudo yum -y install git
SOFTWARE_HOME=/opt/benchmark-tools
sudo mkdir -p $SOFTWARE_HOME
sudo chown $(whoami):$(whoami) $SOFTWARE_HOME

function install_sbt() {
  cd ${SOFTWARE_HOME}
  sudo rm -f /etc/yum.repos.d/bintray-rpm.repo
  curl -L https://www.scala-sbt.org/sbt-rpm.repo > sbt-rpm.repo
  sudo mv sbt-rpm.repo /etc/yum.repos.d/
  sudo yum -y install sbt
}

function install_maven() {
  cd ${SOFTWARE_HOME}
  sudo yum -y install wget
  sudo wget http://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo
  sudo yum -y install maven
}

function install_spark_sql_perf() {
  install_sbt
  cd ${SOFTWARE_HOME}
  if [ ! -d "spark-sql-perf" ]; then
    git clone https://github.com/haojinIntel/spark-sql-perf.git && cd spark-sql-perf
  else
    cd spark-sql-perf && git pull
  fi
  sbt package
}

function install_tpcds_kit() {
  sudo yum -y install gcc make flex bison byacc git
  cd ${SOFTWARE_HOME} && git clone https://github.com/databricks/tpcds-kit.git
  cd tpcds-kit/tools
  make OS=LINUX
}

function install_tpch_dbgen() {
  sudo yum -y install make patch unzip
  cd ${SOFTWARE_HOME} && git clone https://github.com/databricks/tpch-dbgen
  cd tpch-dbgen && make clean && make;
}

function install_hibench() {
  install_maven
  cd ${SOFTWARE_HOME}
  if [ ! -d "HiBench" ]; then
    git clone https://github.com/Intel-bigdata/HiBench.git && cd HiBench
  else
    cd HiBench && git pull
  fi
  mvn -Psparkbench -Dmodules -Pml -Pmicro -Dspark=3.0 -Dscala=2.12 -DskipTests clean package
}

function install_tpcds() {
  install_spark_sql_perf
  install_tpcds_kit
}

function install_tpch() {
  install_spark_sql_perf
  install_tpch_dbgen
}

function usage() {
  echo "Usage: $0 --all|--tpcds|--tpch|--hibench|-h|--help" >&2
}


while [[ $# -ge 0 ]]
do
key="$1"
case $key in
    "")
    shift 1
    echo "Start to deploy all benchmark for OAP ..."
    install_hibench
    install_tpcds
    install_tpch
    exit 0
    ;;
    --tpcds)
    shift 1
    install_tpcds
    exit 0
    ;;
    --tpch)
    shift 1
    install_tpch
    exit 0
    ;;
    --hibench)
    shift 1
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
