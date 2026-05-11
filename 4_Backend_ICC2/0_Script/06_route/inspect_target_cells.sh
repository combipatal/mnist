#!/usr/bin/env bash
set -euo pipefail

cd /DATA/home/edu135/MNIST

trial_name="${TRIAL_NAME:-libdir_via1_no_track_trim_all_pin_util45_route_rerun3}"
trial_lib="4_Backend_ICC2/2_Output/trials/$trial_name/mnist_npu_icc2_lib"
probe_name="${TARGET_PROBE_NAME:-target_cells}"
report_dir="4_Backend_ICC2/4_Report/trials/$trial_name/06_route_${probe_name}"
log_dir="4_Backend_ICC2/3_Log/trials/$trial_name/06_route_${probe_name}"

if [ ! -d "$trial_lib" ]; then
  echo "ERROR: Missing trial ICC2 library: $trial_lib"
  exit 1
fi

lock_file="$trial_lib/lib.ndm.master_lock"
if [ -f "$lock_file" ]; then
  echo "ERROR: ICC2 design library is locked. Do not start target cell inspection."
  echo "Lock file: $lock_file"
  strings "$lock_file" || true
  exit 1
fi

mkdir -p "$report_dir" "$log_dir"

export ICC2_LIB_DIR="/DATA/home/edu135/MNIST/$trial_lib"
export TARGET_REPORT_DIR="/DATA/home/edu135/MNIST/$report_dir"
: "${TARGET_INPUT_BLOCK:=route_eco_offgrid1}"
: "${TARGET_CELLS:=U77942}"
: "${TARGET_NETS:=n143522}"
: "${TARGET_MARGIN:=0.60}"
export TARGET_INPUT_BLOCK
export TARGET_CELLS
export TARGET_NETS
export TARGET_MARGIN

icc2_shell -f 4_Backend_ICC2/0_Script/06_route/inspect_target_cells.tcl \
  | tee "$log_dir/run.log"
