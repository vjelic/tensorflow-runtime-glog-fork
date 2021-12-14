#!/usr/bin/env bash
set -eux

cd $HOME/tfrt

# bazel test --test_filter=*/ROCm //backends/gpu/cpp_tests...


# bazel test --test_filter=*/ROCm //backends/gpu/cpp_tests:gpu_types_test  # PASSED
# bazel test --test_filter=*/ROCm //backends/gpu/cpp_tests:wrapper/blas_wrapper_test  # PASSED
# bazel test --test_filter=*/ROCm //backends/gpu/cpp_tests:wrapper/dnn_wrapper_test  # PASS
# bazel test --test_filter=*/ROCm //backends/gpu/cpp_tests:wrapper/driver_wrapper_test  # TIMEOUT
# bazel test --test_filter=*/ROCm //backends/gpu/cpp_tests:wrapper/fft_wrapper_test  # PASSED
# bazel test --test_filter=*/ROCm //backends/gpu/cpp_tests:wrapper/runtime_wrapper_test  # PASSED
# bazel test --test_filter=*/ROCm //backends/gpu/cpp_tests:wrapper/solver_wrapper_test  # FAILED
