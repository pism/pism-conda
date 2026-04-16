#!/bin/bash
set -ex

export PATH=~/miniforge3/bin:/usr/bin:/bin:/usr/sbin:/sbin
unset PYTHONPATH
unset CONDA_PREFIX

pism_version=${1:-main}
build_dir=$HOME/pism-dbg
env_name=pism-dbg

# ── Create / update conda environment ──────────────────────────────────
mamba env create -f ~/base/pism-conda/environment-dbg.yml
eval "$(mamba shell hook --shell bash)"
mamba activate ${env_name}

# ── Clone / update PISM source ─────────────────────────────────────────
mkdir -p ${build_dir}
pushd ${build_dir}
git clone git@github.com:pism/pism.git . 2>/dev/null || (git checkout main && git pull)
git checkout ${pism_version}
git pull
rm -rf build
mkdir -p build
popd

# ── Platform-specific flags ────────────────────────────────────────────
if [[ "$(uname)" == "Linux" ]]; then
    export LDFLAGS="-pthread -fopenmp ${LDFLAGS}"
    export LDFLAGS="${LDFLAGS} -Wl,-rpath-link,${CONDA_PREFIX}/lib"
elif [[ "$(uname)" == "Darwin" ]]; then
    export LDFLAGS="${LDFLAGS} -undefined dynamic_lookup"
    # Python extension modules must not link libpython directly on macOS
    sed -i.bak 's|${Python3_LIBRARIES} ||g' \
        "${build_dir}/src/pythonbindings/CMakeLists.txt"
fi

export CC="mpicc"
export CXX="mpicxx"

# ── Configure ──────────────────────────────────────────────────────────
cmake -D CMAKE_CXX_FLAGS="-g -O0" \
      -D CMAKE_C_FLAGS="-g -O0" \
      -D CMAKE_BUILD_TYPE="Debug" \
      -D CMAKE_PREFIX_PATH="${CONDA_PREFIX}" \
      -D CMAKE_INSTALL_PREFIX="${build_dir}" \
      -D CMAKE_INSTALL_LIBDIR=lib \
      -D Python3_EXECUTABLE="${CONDA_PREFIX}/bin/python" \
      -D Pism_DEBUG=YES \
      -D Pism_BUILD_DOCS=YES \
      -D Pism_BUILD_PYTHON_BINDINGS=YES \
      -D Pism_ENABLE_DOCUMENTATION=NO \
      -D Pism_PKG_CONFIG_STATIC=NO \
      -D Pism_USE_PARALLEL_NETCDF4=YES \
      -D Pism_USE_PROJ=YES \
      -D Pism_USE_YAC=YES \
      -B "${build_dir}/build" \
      -S "${build_dir}"

# ── Build & install ───────────────────────────────────────────────────
make -j"$(sysctl -n hw.ncpu 2>/dev/null || nproc)" -C "${build_dir}/build" install

# ── Print environment setup instructions ──────────────────────────────
python_version=$(python -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
cat <<EOF

── Done ──────────────────────────────────────────────────────────────
To use this build, run:

  mamba activate ${env_name}
  export PISM_DIR=${build_dir}
  export PYTHONPATH=${build_dir}/lib/python${python_version}/site-packages:\$PYTHONPATH
  export PATH=${build_dir}/bin:\$PATH

EOF
