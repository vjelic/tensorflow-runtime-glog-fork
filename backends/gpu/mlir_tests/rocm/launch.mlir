// Copyright 2020 The TensorFlow Runtime Authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// RUN: bef_executor_lite %s.bef | FileCheck %s

// CHECK-LABEL: --- Running 'noop_kernel'
func @noop_kernel() {
  %ordinal = tfrt.constant.i32 0
  %device = tfrt_gpu.device.get ROCm, %ordinal
  %context = tfrt_gpu.context.create %device
  %stream = tfrt_gpu.stream.create %context

  %module = tfrt_gpu.module.load %context {
    // raw string for empty_kernel.
    data = "extern \"C\" __global__ void empty_kernel() { }\00"
  }

  %func = tfrt_gpu.module.get_function %module { name = "empty_kernel" }

  %blk_dim = tfrt.constant.ui32 1
  %grid_dim = tfrt.constant.ui32 1
  %shared_mem_size = tfrt.constant.ui32 0

  %ch = tfrt.new.chain
  %ch7 = tfrt_gpu.function.launch %stream, %func,
             blocks in (%grid_dim, %grid_dim, %grid_dim),
             threads in (%blk_dim, %blk_dim, %blk_dim),
             %shared_mem_size, %ch

  tfrt.return
}

// CHECK-LABEL: --- Running 'vector_add_kernel'
func @vector_add_kernel() {
  %ordinal = tfrt.constant.i32 0
  %device = tfrt_gpu.device.get ROCm, %ordinal
  %context = tfrt_gpu.context.create %device
  %stream = tfrt_gpu.stream.create %context
  %allocator = tfrt_gpu.allocator.create %context

  %module = tfrt_gpu.module.load %context {
    data = "extern \"C\" __global__ void vector_add(int nums, float* a, float* b){int tid = blockIdx.x * blockDim.x + threadIdx.x;\n if (tid<nums) b[tid]+=a[tid];}\00"
  }

  %func = tfrt_gpu.module.get_function %module { name = "vector_add" }

  // Create source dense host tensors.
  %ch2 = tfrt.new.chain
  %x_host = tfrt_dht.create_uninitialized_tensor.f32.1 [8 : i64]
  %ch7 = tfrt_dht.fill_tensor_with_constant.f32 %x_host, %ch2 1.0 : f32
  // CHECK: shape = [8], values = [1.000000e+00, 1.000000e+00, 1.000000e+00, 1.000000e+00, 1.000000e+00, 1.000000e+00, 1.000000e+00, 1.000000e+00]
  %ch8 = tfrt_dht.print_tensor %x_host, %ch7

  %y_host = tfrt_dht.create_uninitialized_tensor.f32.1 [8 : i64]
  %ch9 = tfrt_dht.fill_tensor_with_constant.f32 %y_host, %ch8 1.0 : f32
  // CHECK: shape = [8], values = [1.000000e+00, 1.000000e+00, 1.000000e+00, 1.000000e+00, 1.000000e+00, 1.000000e+00, 1.000000e+00, 1.000000e+00]
  %ch10 = tfrt_dht.print_tensor %y_host, %ch9


  // Extract buffers.
  %x_host_buffer, %ch11 = tfrt_dht.get_buffer %x_host, %ch10
  // CHECK: HostBuffer<pointer={{0x[[:xdigit:]]*}}, size=32>
  %ch12 = tfrt_dht.print_buffer %x_host_buffer, %ch11
  %y_host_buffer, %ch13 = tfrt_dht.get_buffer %y_host, %ch12
  // CHECK: HostBuffer<pointer={{0x[[:xdigit:]]*}}, size=32>
  %ch14 = tfrt_dht.print_buffer %y_host_buffer, %ch13

  %size = tfrt.constant.i64 32
  %x_device = tfrt_gpu.mem.allocate %allocator, %stream, %size, %ch14
  %y_device = tfrt_gpu.mem.allocate %allocator, %stream, %size, %ch14

  // Copy host to device.
  %ch17 = tfrt_gpu.mem.copy %x_device, %x_host_buffer, %stream, %ch14 : !tfrt_gpu.buffer, !ht.host_buffer
  %ch18 = tfrt_gpu.mem.copy %y_device, %y_host_buffer, %stream, %ch14 : !tfrt_gpu.buffer, !ht.host_buffer

  %one = tfrt.constant.ui32 1
  %eight = tfrt.constant.ui32 8
  %shared_mem_size = tfrt.constant.ui32 0
  %len = tfrt.constant.i32 8

  %ch_kernel = tfrt_gpu.function.launch %stream, %func,
                   blocks in (%eight, %one, %one),
                   threads in (%eight, %one, %one),
                   %shared_mem_size, %ch18,
                   args(%len, %x_device, %y_device) : (i32, !tfrt_gpu.buffer, !tfrt_gpu.buffer)

  // Copy back to host buffer and synchronize.
  %ch19 = tfrt_gpu.mem.copy %y_host_buffer, %y_device, %stream, %ch_kernel : !ht.host_buffer, !tfrt_gpu.buffer
  %sync_ch = tfrt_gpu.stream.synchronize %stream, %ch19

  // CHECK: shape = [8], values = [2.000000e+00, 2.000000e+00, 2.000000e+00, 2.000000e+00, 2.000000e+00, 2.000000e+00, 2.000000e+00, 2.000000e+00]
  %ch25 = tfrt_dht.print_tensor %y_host, %sync_ch

  tfrt.return
}

// CHECK-LABEL: --- Running 'float_arg_kernel'
func @float_arg_kernel() {
  %ordinal = tfrt.constant.i32 0
  %device = tfrt_gpu.device.get ROCm, %ordinal
  %context = tfrt_gpu.context.create %device
  %stream = tfrt_gpu.stream.create %context
  %allocator = tfrt_gpu.allocator.create %context

  %module = tfrt_gpu.module.load %context {
    data = "extern \"C\" __global__ void add(float* ptr, float val) { *ptr = val + 1.0; }\00"
  }
  %func = tfrt_gpu.module.get_function %module { name = "add" }

  // Create source dense host tensors.
  %ch0 = tfrt.new.chain
  %host_tensor = tfrt_dht.create_uninitialized_tensor.f32.0 []

  // Setup output buffer.
  %host_buffer, %ch1 = tfrt_dht.get_buffer %host_tensor, %ch0
  %device_buffer = tfrt_gpu.mem.register %context, %host_buffer

  %one = tfrt.constant.ui32 1
  %shared_mem_size = tfrt.constant.ui32 0
  %val_to_add = tfrt.constant.f32 2.0

  %ch2 = tfrt_gpu.function.launch %stream, %func,
                   blocks in (%one, %one, %one),
                   threads in (%one, %one, %one),
                   %shared_mem_size, %ch1,
                   args(%device_buffer, %val_to_add) : (!tfrt_gpu.buffer, f32)

  %ch3 = tfrt_gpu.stream.synchronize %stream, %ch2

  // CHECK: shape = [], values = [3.000000e+00]
  %ch4 = tfrt_dht.print_tensor %host_tensor, %ch3

  tfrt.return
}
