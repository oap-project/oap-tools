#!/bin/bash
sudo yum -y install git
SOFTWARE_HOME=/opt/benchmark-tools
sudo mkdir -p $SOFTWARE_HOME
sudo chown $(whoami):$(whoami) $SOFTWARE_HOME

function install_sbt() {
  cd ${SOFTWARE_HOME}
  sudo yum -y install curl
  curl https://bintray.com/sbt/rpm/rpm | sudo tee /etc/yum.repos.d/bintray-sbt-rpm.repo
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
  cp hadoopbench/mahout/pom.xml hadoopbench/mahout/pom.xml.bak
  cat hadoopbench/mahout/pom.xml \
      | sed 's|<repo2>http://archive.cloudera.com</repo2>|<repo2>https://archive.apache.org</repo2>|' \
      | sed 's|cdh5/cdh/5/mahout-0.9-cdh5.1.0.tar.gz|dist/mahout/0.9/mahout-distribution-0.9.tar.gz|' \
      | sed 's|aa953e0353ac104a22d314d15c88d78f|09b999fbee70c9853789ffbd8f28b8a3|' \
      > ./pom.xml.tmp
  mv ./pom.xml.tmp hadoopbench/mahout/pom.xml
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
