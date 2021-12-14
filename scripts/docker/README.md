# Description

Script to build a docker container which has all the pre-requisites installed for building TFRT (TensorFlow RunTime) with ROCm (or CUDA)

The Dockerfile in this directory
* takes the base image as an argument (default : `rocm/tensorflow-private:ubuntu18.04-rocm4.2.0`),
* installs all the pre-requisites for building TFRT from source, and
* adds some utility scripts (to the `/scripts` dir) to the docker image to build TFRT, install TFRT and run unit tests

# How to build?

* __ROCm version__ Edit (if needed) the script `build_docker_image.sh`, and then run it
* __CUDA version__ Edit (if needed) the script `build_docker_image_cuda.sh`, and then run it

