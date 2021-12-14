#!/bin/bash

# exit immediately on failure, or if an undefined variable is used
set -eux

BASE_IMAGE="rocm/tensorflow-autobuilds:ubuntu18.04-rocm4.5.0"

DOCKER_IMAGE="rocm/tensorflow-private:ubuntu18.04-rocm4.5.0-tfrt"

DOCKER_BUILD_ARGS=" \
  --build-arg BASE_IMAGE=$BASE_IMAGE \
"

DOCKERFILE=Dockerfile.ubuntu18.04-rocm-tfrt

docker build -t $DOCKER_IMAGE -f $DOCKERFILE $DOCKER_BUILD_ARGS .
