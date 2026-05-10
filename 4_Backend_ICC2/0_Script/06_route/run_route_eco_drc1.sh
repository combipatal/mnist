#!/usr/bin/env bash
set -euo pipefail

cd /DATA/home/edu135/MNIST

mkdir -p 4_Backend_ICC2/3_Log/06_route_eco_drc1

lock_file=4_Backend_ICC2/2_Output/01_init_design/mnist_npu_icc2_lib/lib.ndm.master_lock
if [ -f "$lock_file" ]; then
  echo "ERROR: ICC2 design library is locked. Do not start route ECO DRC repair."
  echo "Lock file: $lock_file"
  strings "$lock_file" || true
  exit 1
fi

icc2_shell -f 4_Backend_ICC2/0_Script/06_route/run_route_eco_drc1.tcl \
  | tee 4_Backend_ICC2/3_Log/06_route_eco_drc1/run_route_eco_drc1.log
