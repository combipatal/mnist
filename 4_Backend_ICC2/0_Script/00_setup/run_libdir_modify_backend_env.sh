#!/usr/bin/env bash
set -euo pipefail

cd /DATA/home/edu135/MNIST

export NDM_RVT=/DATA/home/edu135/MNIST/4_Backend_ICC2/2_Output/00_setup/ndm_libdir_modify/saed32rvt_tt.ndm
export ICC2_LIB_DIR=/DATA/home/edu135/MNIST/4_Backend_ICC2/2_Output/01_init_design/mnist_npu_icc2_lib_libdir_modify

exec "$@"
