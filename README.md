[![License: GPL-3.0](https://img.shields.io:/github/license/pism/pypac)](https://opensource.org/licenses/GPL-3.0)

# pism-conda

Repository to build and test PISM conda packages


## Installation

Get pism-conda source from GitHub:

    $ git clone git@github.com:pism/pism-conda.git
    $ cd pism-conda

Now create a conda environment named *pism-dev*. This installs a barebones environment suitable to build *staged-recipies*.

    $ conda env create -f environment-conda.yml
    $ conda activate pism-conda


## Clone pism/staged-recipies. How can I just checkout pism-channel?

    $ cd ..
    $ mkdir -p pism-staged-recipies
    $ git clone git@github.com:pism/staged-recipes.git . || (git checkout pism-channel && git pull)
    $ cd pism-staged-recipies
    $ pixi install
    
    
    
## PISM packages

The *pism-channel* currently has packages for *yaxt*, *yac*, and *pism* (stable). Change into the *recipies/package* directory, where *package* is the package you want to update. Edit the *build.sh* and *meta.yml* files.

### Linting

Before building, lint your changes:

    $ pixi run lint

### Build locally

Depending on your architecture, run

    $ pixi run build-linux
 
or 

    $ pixi run build-osx




