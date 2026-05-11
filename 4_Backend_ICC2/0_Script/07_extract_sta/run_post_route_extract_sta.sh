#!/usr/bin/env bash
set -euo pipefail

cd /DATA/home/edu135/MNIST

trial_name="${TRIAL_NAME:-libdir_via1_no_track_trim_all_pin_util45_route_rerun3}"
trial_lib="4_Backend_ICC2/2_Output/trials/$trial_name/mnist_npu_icc2_lib"
extract_name="${EXTRACT_NAME:-07_extract_sta_pg_ladder_vdd50_vss20_path507x55_h015}"
report_dir="4_Backend_ICC2/4_Report/trials/$trial_name/$extract_name"
log_dir="4_Backend_ICC2/3_Log/trials/$trial_name/$extract_name"

if [ ! -d "$trial_lib" ]; then
  echo "ERROR: Missing trial ICC2 library: $trial_lib"
  exit 1
fi

lock_file="$trial_lib/lib.ndm.master_lock"
if [ -f "$lock_file" ]; then
  echo "ERROR: ICC2 design library is locked. Do not start post-route extraction."
  echo "Lock file: $lock_file"
  strings "$lock_file" || true
  exit 1
fi

mkdir -p "$report_dir" "$log_dir"

export ICC2_LIB_DIR="/DATA/home/edu135/MNIST/$trial_lib"
export EXTRACT_REPORT_DIR="/DATA/home/edu135/MNIST/$report_dir"
: "${EXTRACT_INPUT_BLOCK:=route_pg_ladder_vdd50_vss20_path507x55_h015}"
export EXTRACT_INPUT_BLOCK

icc2_shell -f 4_Backend_ICC2/0_Script/07_extract_sta/run_post_route_extract_sta.tcl \
  | tee "$log_dir/run.log"
