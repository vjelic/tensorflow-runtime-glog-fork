#!/usr/bin/env bash

set -eux

GCC_VERSION=$1

add-apt-repository -y ppa:ubuntu-toolchain-r/test 
apt-get update
apt-get install -y gcc-${GCC_VERSION} g++-${GCC_VERSION}

update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-${GCC_VERSION} ${GCC_VERSION}
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-${GCC_VERSION} ${GCC_VERSION}
