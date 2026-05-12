#!/usr/bin/env bash
set -euo pipefail

cd /DATA/home/edu135/MNIST

trial_name="${TRIAL_NAME:-libdir_via1_no_track_trim_all_pin_util45_route_rerun3}"
trial_lib="4_Backend_ICC2/2_Output/trials/$trial_name/mnist_npu_icc2_lib"
probe_name="${SEQ_ROUTE_PROBE_NAME:-seq_pintrack1}"
report_dir="4_Backend_ICC2/4_Report/trials/$trial_name/06_route_${probe_name}"
log_dir="4_Backend_ICC2/3_Log/trials/$trial_name/06_route_${probe_name}"

if [ ! -d "$trial_lib" ]; then
  echo "ERROR: Missing trial ICC2 library: $trial_lib"
  exit 1
fi

lock_file="$trial_lib/lib.ndm.master_lock"
if [ -f "$lock_file" ]; then
  echo "ERROR: ICC2 design library is locked. Do not start sequential local route probe."
  echo "Lock file: $lock_file"
  strings "$lock_file" || true
  exit 1
fi

mkdir -p "$report_dir" "$log_dir"

export ICC2_LIB_DIR="/DATA/home/edu135/MNIST/$trial_lib"
export SEQ_ROUTE_REPORT_DIR="/DATA/home/edu135/MNIST/$report_dir"
: "${SEQ_ROUTE_INPUT_BLOCK:=route_eco_offgrid1}"
: "${SEQ_ROUTE_OUTPUT_BLOCK:=route_seq_pintrack1}"
if [ -z "${SEQ_ROUTE_STEPS+x}" ]; then
  SEQ_ROUTE_STEPS="ZBUF_714_1050;ZBUF_851_152;ZBUF_832_2538;n143522"
fi
: "${SEQ_ROUTE_ITERATIONS:=120}"
: "${SEQ_ROUTE_SAVE:=0}"
: "${SEQ_ROUTE_SAVE_ON_CLEAN_ONLY:=1}"
: "${SEQ_SIZE_SWAPS:=}"
: "${SEQ_CELL_MOVES:=}"
: "${SEQ_SWAP_NET_EXCLUDE_REGEX:=^(VDD|VSS)$}"
export SEQ_ROUTE_INPUT_BLOCK
export SEQ_ROUTE_OUTPUT_BLOCK
export SEQ_ROUTE_STEPS
export SEQ_ROUTE_ITERATIONS
export SEQ_ROUTE_SAVE
export SEQ_ROUTE_SAVE_ON_CLEAN_ONLY
export SEQ_SIZE_SWAPS
export SEQ_CELL_MOVES
export SEQ_SWAP_NET_EXCLUDE_REGEX

icc2_shell -f 4_Backend_ICC2/0_Script/06_route/probe_sequential_local_offgrid_route.tcl \
  | tee "$log_dir/run.log"
