#!/usr/bin/env bash
set -euo pipefail

cd /DATA/home/edu135/MNIST

trial_name="${TRIAL_NAME:-libdir_via1_no_track_trim_all_pin_util45_route_rerun3}"
trial_lib="4_Backend_ICC2/2_Output/trials/$trial_name/mnist_npu_icc2_lib"
repair_name="${PG_REPAIR_NAME:-pg_reapply1}"
report_dir="4_Backend_ICC2/4_Report/trials/$trial_name/03_powerplan_${repair_name}"
log_dir="4_Backend_ICC2/3_Log/trials/$trial_name/03_powerplan_${repair_name}"

if [ ! -d "$trial_lib" ]; then
  echo "ERROR: Missing trial ICC2 library: $trial_lib"
  exit 1
fi

lock_file="$trial_lib/lib.ndm.master_lock"
if [ -f "$lock_file" ]; then
  echo "ERROR: ICC2 design library is locked. Do not start PG repair."
  echo "Lock file: $lock_file"
  strings "$lock_file" || true
  exit 1
fi

mkdir -p "$report_dir" "$log_dir"

export ICC2_LIB_DIR="/DATA/home/edu135/MNIST/$trial_lib"
export PG_REPAIR_REPORT_DIR="/DATA/home/edu135/MNIST/$report_dir"
: "${PG_REPAIR_INPUT_BLOCK:=route_seq_size_swap_dff2_oa1_move_u77942_xp152_pintrack}"
: "${PG_REPAIR_OUTPUT_BLOCK:=route_pg_repair1}"
: "${PG_REPAIR_SAVE:=0}"
export PG_REPAIR_INPUT_BLOCK
export PG_REPAIR_OUTPUT_BLOCK
export PG_REPAIR_SAVE

icc2_shell -f 4_Backend_ICC2/0_Script/03_powerplan/repair_pg_connectivity_from_block.tcl \
  | tee "$log_dir/run.log"
