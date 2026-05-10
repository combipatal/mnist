#!/usr/bin/env bash
set -euo pipefail

cd /DATA/home/edu135/MNIST

trial_name="libdir_via1_no_track_route"
trial_lib="4_Backend_ICC2/2_Output/trials/$trial_name/mnist_npu_icc2_lib"
report_dir="4_Backend_ICC2/4_Report/trials/${trial_name}_eco_offgrid1/06_route"
log_dir="4_Backend_ICC2/3_Log/trials/${trial_name}_eco_offgrid1/06_route"

if [ ! -d "$trial_lib" ]; then
  echo "ERROR: Missing trial ICC2 library: $trial_lib"
  exit 1
fi

lock_file="$trial_lib/lib.ndm.master_lock"
if [ -f "$lock_file" ]; then
  echo "ERROR: ICC2 design library is locked. Do not start route ECO repair."
  echo "Lock file: $lock_file"
  strings "$lock_file" || true
  exit 1
fi

mkdir -p "$report_dir" "$log_dir"

export ICC2_LIB_DIR="/DATA/home/edu135/MNIST/$trial_lib"
export ROUTE_ECO_REPORT_DIR="/DATA/home/edu135/MNIST/$report_dir"
export ROUTE_ECO_INPUT_BLOCK="route"
export ROUTE_ECO_OUTPUT_BLOCK="route_eco_offgrid1"

icc2_shell -f 4_Backend_ICC2/0_Script/06_route/run_route_eco_drc1.tcl \
  | tee "$log_dir/run.log"
