#!/usr/bin/env bash

set -eux

apt-get update --allow-insecure-repositories && \
  apt-get install -y --allow-unauthenticated \
  curl \
  unzip && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

BAZEL_VERSION=$1

curl -fSsL -O https://github.com/bazelbuild/bazel/releases/download/$BAZEL_VERSION/bazel-$BAZEL_VERSION-installer-linux-x86_64.sh
chmod +x ./bazel-$BAZEL_VERSION-installer-linux-x86_64.sh
./bazel-$BAZEL_VERSION-installer-linux-x86_64.sh


