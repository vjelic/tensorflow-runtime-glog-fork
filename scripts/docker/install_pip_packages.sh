#!/usr/bin/env bash

set -eux

apt-get update --allow-insecure-repositories && \
  apt-get install -y --allow-unauthenticated \
  python3-dev \
  wget && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*
  
wget https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py
rm -f get-pip.py

pip3 install clang

cd /usr/lib/x86_64-linux-gnu/
ln -s libclang-11.so.1 libclang-11.so
