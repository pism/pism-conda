[![License: GPL-3.0](https://img.shields.io:/github/license/pism/pypac)](https://opensource.org/licenses/GPL-3.0)

# pism-conda

Repository to build and test PISM conda packages


## Installation

Get pism-conda source from GitHub:

    git clone git@github.com:pism/pism-conda.git
    cd pism-conda

Now create a conda environment named *pism-conda*. This installs a bare bones environment suitable to build *staged-recipes*.

    conda env create -f environment.yml
    conda activate pism-conda


## Clone pism/staged-recipes. How can I just checkout pism-channel?

    cd ..
    mkdir -p pism-staged-recipes
    git clone git@github.com:pism/staged-recipes.git . || (git checkout pism-channel && git pull)
    cd pism-staged-recipes
    pixi install
    
    
    
## PISM packages

The *pism-channel* currently has packages for *yaxt*, *yac*, and *pism* (stable). Change into the *recipies/package* directory, where *package* is the package you want to update. Edit the *build.sh* and *meta.yml* files.

### Updating a package

To bump the version of, e.g., *yac*, set the new version number in *meta.yml*:

    {% set version = "3.7.0" %}

Download the tarball and extract sha256:

    openssl sha256 yac-v3.7.0.tar.gz 
    
Update the sha256 in *meta.yml*.


### Linting

Before building, lint your changes:

    pixi run lint

### Build locally

Depending on your architecture, run

    pixi run build-linux
 
or 

    pixi run build-osx

You may need to clean your path first, though

    export PATH=/Users/andy/miniforge3/envs/pism-conda/bin:/usr/bin:/bin:/usr/sbin:/sbin
    unset PYTHONPATH
    unset CONDA_PREFIX
    
### Uploading

    anaconda upload build_artifacts/linux-64/*.conda

or

    anaconda upload build_artifacts/osx-arm64/*.conda


## PISM Dev

Say you want to create a development environment that installs all prerequisites from *conda* and compiles PISM from sources. Build from main branch

    conda env create -f environment-dbg.yml
    git clone https://github.com/pism/pism.git
    cd pism
    CMAKE_BUILD_PARALLEL_LEVEL=8 pip install --no-build-isolation -v .

where N=8 is the number of parallel builds.
