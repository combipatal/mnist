#!/usr/bin/env bash
set -euo pipefail

cd /DATA/home/edu135/MNIST

trial_name="${TRIAL_NAME:-libdir_via1_no_track_trim_all_pin_util45_route_rerun3}"
trial_lib="4_Backend_ICC2/2_Output/trials/$trial_name/mnist_npu_icc2_lib"
probe_name="${LOCAL_ROUTE_PROBE_NAME:-local_pintrack1}"
report_dir="4_Backend_ICC2/4_Report/trials/$trial_name/06_route_${probe_name}"
log_dir="4_Backend_ICC2/3_Log/trials/$trial_name/06_route_${probe_name}"

if [ ! -d "$trial_lib" ]; then
  echo "ERROR: Missing trial ICC2 library: $trial_lib"
  exit 1
fi

lock_file="$trial_lib/lib.ndm.master_lock"
if [ -f "$lock_file" ]; then
  echo "ERROR: ICC2 design library is locked. Do not start local route probe."
  echo "Lock file: $lock_file"
  strings "$lock_file" || true
  exit 1
fi

mkdir -p "$report_dir" "$log_dir"

export ICC2_LIB_DIR="/DATA/home/edu135/MNIST/$trial_lib"
export LOCAL_ROUTE_REPORT_DIR="/DATA/home/edu135/MNIST/$report_dir"
: "${LOCAL_ROUTE_INPUT_BLOCK:=route_eco_offgrid1}"
: "${LOCAL_ROUTE_OUTPUT_BLOCK:=route_local_pintrack1}"
: "${LOCAL_ROUTE_TARGET_NETS:=ZBUF_832_2538 ZBUF_714_1050 ZBUF_851_152 n143522}"
: "${LOCAL_ROUTE_ITERATIONS:=120}"
: "${LOCAL_ROUTE_EXTRA_OFFGRID_PIN_TRACKS:=true}"
: "${LOCAL_ROUTE_CONNECT_WITHIN_PINS:=}"
: "${LOCAL_ROUTE_SAVE:=0}"
export LOCAL_ROUTE_INPUT_BLOCK
export LOCAL_ROUTE_OUTPUT_BLOCK
export LOCAL_ROUTE_TARGET_NETS
export LOCAL_ROUTE_ITERATIONS
export LOCAL_ROUTE_EXTRA_OFFGRID_PIN_TRACKS
export LOCAL_ROUTE_CONNECT_WITHIN_PINS
export LOCAL_ROUTE_SAVE

icc2_shell -f 4_Backend_ICC2/0_Script/06_route/probe_local_offgrid_pintrack_route.tcl \
  | tee "$log_dir/run.log"
