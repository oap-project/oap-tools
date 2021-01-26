# How to build documentation 

Before we build documentation on Github Pages web with scripts, some requeirements need to be satisfied.

## Building oap-project.github.io 
Before build documentation, please use conda to install mkdocs 0.16.3 with commands below.

```
$ wget -c https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh
$ chmod +x Miniconda2-latest-Linux-x86_64.sh
$ bash Miniconda2-latest-Linux-x86_64.sh
```
For changes to take effect, close and re-open your current shell.

Then install mkdocs 0.16.3 

```
conda install -c conda-forge mkdocs
```

Use script to generate OAP Project Pages website. `./gen_oap_site.sh` with version (branch or tag) to build docs

```
$  git clone https://github.com/oap-project/oap-tools.git
$  ./oap-tools/dev/gen_oap_site.sh  v1.1.0
```

## Building feature repo web

Before build documentation of oap-project feature repositories, please make sure your Python version >= 3.6.

Run commands below to generate OAP Project feature website. `./gen_component_site.sh` with version (branch or tag) 

```
$  git clone https://github.com/oap-project/oap-tools.git
$  ./oap-tools/dev/gen_component_site.sh   v1.1.0
```
