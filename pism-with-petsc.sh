#!/bin/bash

pism_version=${pism_version:-dev}
pism_env=${pism_env:-dbg}
build_dir=${build_dir:-$HOME/pism-dev}

mkdir -p $build_dir

pushd ${build_dir}
git clone git@github.com:/pism/pism.git . || (git checkout main && git pull)
git checkout ${pism_version}
git pull
rm -rf build
mkdir -p build
popd




set -ex

if [[ "${target_platform}" == linux-* ]]; then
    export LDFLAGS="-pthread -fopenmp ${LDFLAGS}"
    export LDFLAGS="${LDFLAGS} -Wl,-rpath-link,${PREFIX}/lib"
fi

optimization_flags="-O3"

export CC="mpicc"
export CXX="mpicxx"


cmake -D CMAKE_CXX_FLAGS="${optimization_flags}" \
      -D CMAKE_C_FLAGS="${optimization_flags}" \
      -D CMAKE_PREFIX_PATH="${PETSC_DIR}/${PETSC_ARCH};${CONDA_PREFIX}" \
      -D CMAKE_INSTALL_PREFIX="${build_dir}" \
      -D CMAKE_INSTALL_LIBDIR=lib \
      -D Python3_EXECUTABLE=${CONDA_PREFIX}/bin/python \
      -D Pism_BUILD_PYTHON_BINDINGS=YES \
      -D Pism_ENABLE_DOCUMENTATION=NO \
      -D Pism_PKG_CONFIG_STATIC=NO \
      -D Pism_USE_JANSSON=NO \
      -D Pism_USE_PARALLEL_NETCDF4=YES \
      -D Pism_USE_PROJ=YES \
      -D Pism_USE_YAC_INTERPOLATION=YES \
      -B ${build_dir}/build \
      -S ${build_dir} \


make -j 8 -C ${build_dir}/build install
