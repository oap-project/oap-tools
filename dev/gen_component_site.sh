#!/usr/bin/env bash

#########################################################
# this script is used to generate OAP Project Pages website.
# Usage: run   ./gen_component_site.sh with version (branch or tag) to build docs
# ./gen_component_site.sh   v1.1.0


set -x

echo "#################################"
echo "Please use Python >= 3.6  ...... "


function checkPythonVersion() {
   # Require use Python version >= 3.6

    V1=3
    V2=6

    echo Require Python version above $V1.$V2

    # Get current Python version
    U_V1=`python -V 2>&1|awk '{print $2}'|awk -F '.' '{print $1}'`
    U_V2=`python -V 2>&1|awk '{print $2}'|awk -F '.' '{print $2}'`
    U_V3=`python -V 2>&1|awk '{print $2}'|awk -F '.' '{print $3}'`


    echo Curent Python version is : $U_V1.$U_V2.$U_V3

    if [ $U_V1 -lt $V1 ];then
        echo 'Curent Python version is too low to install mkdocs and mkdocs-versioning, Please install higher version above 3.6'
        exit 1
    elif [ $U_V1 -eq $V1 ];then
        if [ $U_V2 -lt $V2 ];then
            echo 'Curent Python version is too low to install mkdocs and mkdocs-versioning, Please install higher version above 3.6 '
            exit 1
        else
            echo Curent Python version is OK!
        fi
    else
        echo Curent Python version is OK!
    fi


}

checkPythonVersion


version=$1

pip install mkdocs
pip install mkdocs-versioning

if [ -d /home/oap-project/component ]; then
  rm -rf /home/oap-project/component/*
else
  mkdir -p /home/oap-project/component/
fi


echo "Update oap-mllib ${version} documentation on website ... "

cd /home/oap-project/component/
git clone -b ${version} https://github.com/oap-project/oap-mllib.git
cd oap-mllib
echo "update the doc version for release"
mkdocs build
git clone -b gh-pages https://github.com/oap-project/oap-mllib.git
rm -rf oap-mllib/${version}
cp -r site/${version}  oap-mllib/
cd oap-mllib
git add .
git commit -m "Update ${version} documentation  on pages web"
git push origin gh-pages

echo "Update oap-mllib ${version} documentation on website ... "

cd /home/oap-project/component/
git clone -b ${version} https://github.com/oap-project/pmem-spill.git
cd pmem-spill
echo "update the doc version for release"
mkdocs build
git clone -b gh-pages https://github.com/oap-project/pmem-spill.git
rm -rf pmem-spill/${version}
cp -r site/${version}  pmem-spill/
cd pmem-spill
git add .
git commit -m "Update ${version} documentation  on pages web"
git push origin gh-pages


cd /home/oap-project/component/
git clone -b ${version} https://github.com/oap-project/pmem-common.git
cd pmem-common
echo "update the doc version for release"
mkdocs build
git clone -b gh-pages https://github.com/oap-project/pmem-common.git
rm -rf pmem-common/${version}
cp -r site/${version}  pmem-common/
cd pmem-common
git add .
git commit -m "Update ${version} documentation  on pages web"
git push origin gh-pages


cd /home/oap-project/component/
git clone -b ${version} https://github.com/oap-project/pmem-shuffle.git
cd pmem-shuffle
echo "update the doc version for release"
mkdocs build
git clone -b gh-pages https://github.com/oap-project/pmem-shuffle.git
rm -rf pmem-shuffle/${version}
cp -r site/${version}  pmem-shuffle/
cd pmem-shuffle
git add .
git commit -m "Update ${version} documentation  on pages web"
git push origin gh-pages

cd /home/oap-project/component/
git clone -b ${version} https://github.com/oap-project/native-sql-engine.git
cd native-sql-engine
echo "update the doc version for release"
mkdocs build
git clone -b gh-pages https://github.com/oap-project/native-sql-engine.git
rm -rf native-sql-engine/${version}
cp -r site/${version}  native-sql-engine/
cd native-sql-engine
git add .
git commit -m "Update ${version} documentation  on pages web"
git push origin gh-pages

cd /home/oap-project/component/
git clone -b ${version} https://github.com/oap-project/arrow-data-source.git
cd arrow-data-source
echo "update the doc version for release"
mkdocs build
git clone -b gh-pages https://github.com/oap-project/arrow-data-source.git
rm -rf arrow-data-source/${version}
cp -r site/${version}  arrow-data-source/
cd arrow-data-source
git add .
git commit -m "Update ${version} documentation  on pages web"
git push origin gh-pages



cd /home/oap-project/component/
git clone -b ${version} https://github.com/oap-project/remote-shuffle.git
cd remote-shuffle
echo "update the doc version for release"
mkdocs build
git clone -b gh-pages https://github.com/oap-project/remote-shuffle.git
rm -rf remote-shuffle/${version}
cp -r site/${version}  remote-shuffle/
cd remote-shuffle
git add .
git commit -m "Update ${version} documentation  on pages web"
git push origin gh-pages

cd /home/oap-project/component/
git clone -b ${version} https://github.com/oap-project/sql-ds-cache.git
cd sql-ds-cache
echo "update the doc version for release"
mkdocs build
git clone -b gh-pages https://github.com/oap-project/sql-ds-cache.git
rm -rf sql-ds-cache/${version}
cp -r site/${version}  sql-ds-cache/
cd sql-ds-cache
git add .
git commit -m "Update ${version} documentation  on pages web"
git push origin gh-pages


