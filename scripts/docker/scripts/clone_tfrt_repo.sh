#!/usr/bin/env bash
set -eux

cd $HOME
git clone https://github.com/tensorflow/runtime tfrt

cd tfrt
git remote add rocm_fork https://github.com/ROCmSoftwarePlatform/tensorflow-runtime
git fetch rocm_fork
