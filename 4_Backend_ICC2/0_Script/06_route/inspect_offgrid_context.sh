#!/usr/bin/env bash
set -euo pipefail

cd /DATA/home/edu135/MNIST

trial_name="${TRIAL_NAME:-libdir_via1_no_track_trim_all_pin_util45_route_rerun3}"
trial_lib="4_Backend_ICC2/2_Output/trials/$trial_name/mnist_npu_icc2_lib"
context_subdir="${DRC_CONTEXT_SUBDIR:-06_route_context}"
report_dir="4_Backend_ICC2/4_Report/trials/$trial_name/$context_subdir"
log_dir="4_Backend_ICC2/3_Log/trials/$trial_name/$context_subdir"

if [ ! -d "$trial_lib" ]; then
  echo "ERROR: Missing trial ICC2 library: $trial_lib"
  exit 1
fi

lock_file="$trial_lib/lib.ndm.master_lock"
if [ -f "$lock_file" ]; then
  echo "ERROR: ICC2 design library is locked. Do not start DRC context extraction."
  echo "Lock file: $lock_file"
  strings "$lock_file" || true
  exit 1
fi

mkdir -p "$report_dir" "$log_dir"

export ICC2_LIB_DIR="/DATA/home/edu135/MNIST/$trial_lib"
export DRC_CONTEXT_REPORT_DIR="/DATA/home/edu135/MNIST/$report_dir"
: "${DRC_CONTEXT_INPUT_BLOCK:=route_eco_offgrid1}"
: "${DRC_CONTEXT_TYPE:=Off-grid}"
: "${DRC_CONTEXT_MARGIN:=0.35}"
export DRC_CONTEXT_INPUT_BLOCK
export DRC_CONTEXT_TYPE
export DRC_CONTEXT_MARGIN

icc2_shell -f 4_Backend_ICC2/0_Script/06_route/inspect_offgrid_context.tcl \
  | tee "$log_dir/run.log"
