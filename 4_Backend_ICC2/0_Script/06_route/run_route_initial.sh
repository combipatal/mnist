#!/usr/bin/env bash
set -euo pipefail

cd /DATA/home/edu135/MNIST

mkdir -p 4_Backend_ICC2/3_Log/06_route

lock_file=4_Backend_ICC2/2_Output/01_init_design/mnist_npu_icc2_lib/lib.ndm.master_lock
if [ -f "$lock_file" ]; then
  echo "ERROR: ICC2 design library is locked. Do not start a second route run."
  echo "Lock file: $lock_file"
  strings "$lock_file" || true
  exit 1
fi

icc2_shell -f 4_Backend_ICC2/0_Script/06_route/run_route_initial.tcl \
  | tee 4_Backend_ICC2/3_Log/06_route/run_route_initial.log
