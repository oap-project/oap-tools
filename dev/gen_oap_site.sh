#!/usr/bin/env bash

#########################################################
# Before build documentation, please use conda to install mkdocs 0.16.3 with commands below.

# wget -c https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh
# chmod +x Miniconda2-latest-Linux-x86_64.sh
# bash Miniconda2-latest-Linux-x86_64.sh
#########################################################
# then close and re-open your current shell, run:
# conda install -c conda-forge mkdocs

#########################################################
# this script is used to generate OAP Project Pages website.
# Usage: run   ./gen_oap_site.sh with version (branch or tag) to build docs
# ./gen_oap_site.sh 1.1.0


set -x

version=$1



if [ -d /home/oap-project/oap-whole ]; then
  rm -rf /home/oap-project/oap-whole/*
  mkdir -p /home/oap-project/oap-whole/oap-project-docs
else
  mkdir -p /home/oap-project/oap-whole/oap-project-docs
fi


cd /home/oap-project/oap-whole
git clone https://github.com/oap-project/oap-tools.git
cp -r  oap-tools/docs/*   ./oap-project-docs/
cd ./oap-project-docs/

mkdocs build
git clone  https://github.com/oap-project/oap-project.github.io.git
rm -rf oap-project.github.io/${version}
cp -r site  oap-project.github.io/${version}
cd oap-project.github.io
git add .
git commit -m "Update ${version} documentation on OAP Project pages web"
git push origin master
