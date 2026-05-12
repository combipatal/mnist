#!/usr/bin/env bash
set -euo pipefail

cd /DATA/home/edu135/MNIST

trial_name="${TRIAL_NAME:-libdir_via1_no_track_trim_all_pin_util45_route_rerun3}"
trial_lib="4_Backend_ICC2/2_Output/trials/$trial_name/mnist_npu_icc2_lib"
fill_lib="4_Backend_ICC2/2_Output/trials/$trial_name/mnist_npu_icc2_lib_fill1"
run_name="${RUN_NAME:-08_fill_gds_route_a20_eopen4_fill2}"
output_dir="4_Backend_ICC2/2_Output/trials/$trial_name/$run_name"
report_dir="4_Backend_ICC2/4_Report/trials/$trial_name/$run_name"
log_dir="4_Backend_ICC2/3_Log/trials/$trial_name/$run_name"

if [ ! -d "$trial_lib" ]; then
  echo "ERROR: Missing source trial ICC2 library: $trial_lib"
  exit 1
fi

if [ ! -d "$fill_lib" ]; then
  echo "INFO: Creating fill working copy: $fill_lib"
  rsync -a \
    --exclude 'lib.ndm.master_lock*' \
    "$trial_lib/" \
    "$fill_lib/"
fi

lock_file="$fill_lib/lib.ndm.master_lock"
if [ -f "$lock_file" ]; then
  echo "ERROR: Fill working ICC2 library is locked. Do not start filler insertion."
  echo "Lock file: $lock_file"
  strings "$lock_file" || true
  exit 1
fi

mkdir -p "$output_dir" "$report_dir" "$log_dir"

export ICC2_LIB_DIR="/DATA/home/edu135/MNIST/$fill_lib"
export FILL_REPORT_DIR="/DATA/home/edu135/MNIST/$report_dir"
export GDS_OUTPUT_DIR="/DATA/home/edu135/MNIST/$output_dir"
: "${FILL_INPUT_BLOCK:=route_a20_eopen4}"
: "${FILL_OUTPUT_BLOCK:=route_a20_eopen4_fill2}"
export FILL_INPUT_BLOCK
export FILL_OUTPUT_BLOCK

icc2_shell -f 4_Backend_ICC2/0_Script/08_gds/run_insert_fillers_and_gds.tcl \
  | tee "$log_dir/run.log"
