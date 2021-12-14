#!/usr/bin/env bash

set -eux

mkdir -p /root/cuda && cd /root/cuda

CUDA_INSTALL_PATH=/usr/local/cuda

wget http://developer.download.nvidia.com/compute/cuda/11.2.2/local_installers/cuda_11.2.2_460.32.03_linux.run
sh cuda_11.2.2_460.32.03_linux.run --silent --toolkit --installpath=$CUDA_INSTALL_PATH

# Only install the Toolkit and nothing else

echo "$CUDA_INSTALL_PATH/lib64" > /etc/ld.so.conf.d/cuda.conf
ldconfig

wget http://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1604/x86_64/libcudnn8_8.0.4.30-1+cuda11.1_amd64.deb
chmod a+x *.deb
apt install ./libcudnn8_8.0.4.30-1+cuda11.1_amd64.deb
