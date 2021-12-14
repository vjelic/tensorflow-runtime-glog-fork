#!/usr/bin/env bash

set -eux

apt-get update --allow-insecure-repositories && \
  apt-get install -y --allow-unauthenticated \
  git \
  lsb-release \
  software-properties-common \
  wget && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

CLANG_VERSION=$1

wget https://apt.llvm.org/llvm.sh
chmod +x llvm.sh
./llvm.sh $CLANG_VERSION

update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-${CLANG_VERSION} ${CLANG_VERSION}
update-alternatives --install /usr/bin/clang clang /usr/bin/clang-${CLANG_VERSION} ${CLANG_VERSION}
