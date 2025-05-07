export pism_env=dev-with-petsc
export pism_version=dev

rm -rf ${CONDA_DIR}/envs/$pism_env
mamba env create -f ~/base/pism-conda/environment-${pism_env}.yml

eval "$(mamba shell hook --shell bash)"
mamba activate
mamba activate $pism_env

export PETSC_DIR=$HOME/petsc-${pism_env}
export PETSC_ARCH=64bit

sh petsc.sh
export PYTHONPATH=${PETSC_DIR}/${PETSC_ARCH}/lib:$PYTHONPATH
export build_dir=$HOME/pism-${pism_env}
sh pism-with-petsc.sh
export PISM_DIR=${build_dir}
export PYTHONPATH=${PISM_DIR}/lib/python3.11/site-packages:$PYTHONPATH
export PATH=${PISM_DIR}/bin:$PATH

