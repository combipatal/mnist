#!/usr/bin/env bash
set -euo pipefail

cd /DATA/home/edu135/MNIST

trial_name="${TRIAL_NAME:-libdir_via1_no_track_trim_all_pin_util45_route_rerun3}"
trial_lib="4_Backend_ICC2/2_Output/trials/$trial_name/mnist_npu_icc2_lib"
eco_name="${ELECTRICAL_ECO_NAME:-07_extract_sta_electrical_eco_open_site1}"
report_dir="4_Backend_ICC2/4_Report/trials/$trial_name/$eco_name"
log_dir="4_Backend_ICC2/3_Log/trials/$trial_name/$eco_name"
output_dir="4_Backend_ICC2/2_Output/trials/$trial_name/$eco_name"

if [ ! -d "$trial_lib" ]; then
  echo "ERROR: Missing trial ICC2 library: $trial_lib"
  exit 1
fi

lock_file="$trial_lib/lib.ndm.master_lock"
if [ -f "$lock_file" ]; then
  echo "ERROR: ICC2 design library is locked. Do not start electrical ECO trial."
  echo "Lock file: $lock_file"
  strings "$lock_file" || true
  exit 1
fi

mkdir -p "$report_dir" "$log_dir" "$output_dir"

export ICC2_LIB_DIR="/DATA/home/edu135/MNIST/$trial_lib"
export ELECTRICAL_ECO_REPORT_DIR="/DATA/home/edu135/MNIST/$report_dir"
export ELECTRICAL_ECO_OUTPUT_DIR="/DATA/home/edu135/MNIST/$output_dir"
: "${ELECTRICAL_ECO_INPUT_BLOCK:=route_pg_ladder_hold_eco_repair1_hold2_clean_occ1}"
: "${ELECTRICAL_ECO_OUTPUT_BLOCK:=route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco1}"
: "${DRC_ECO_TYPES:=drc}"
: "${PHYSICAL_MODE:=open_site}"
: "${SIZE_ONLY:=0}"
: "${PT_EXEC:=/tools/synopsys/prime/W-2024.09-SP5-3/bin/pt_shell}"
export ELECTRICAL_ECO_INPUT_BLOCK
export ELECTRICAL_ECO_OUTPUT_BLOCK
export DRC_ECO_TYPES
export PHYSICAL_MODE
export SIZE_ONLY
export PT_EXEC

icc2_shell -f 4_Backend_ICC2/0_Script/07_extract_sta/run_post_route_electrical_eco_trial.tcl \
  | tee "$log_dir/run.log"
