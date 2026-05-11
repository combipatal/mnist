#!/usr/bin/env bash
set -euo pipefail

cd /DATA/home/edu135/MNIST

trial_name="${TRIAL_NAME:-libdir_via1_no_track_trim_all_pin_util45_route_rerun2}"
trial_output_root="4_Backend_ICC2/2_Output/trials/$trial_name"
trial_report_root="4_Backend_ICC2/4_Report/trials/$trial_name"
trial_log_root="4_Backend_ICC2/3_Log/trials/$trial_name"

tech_file="4_Backend_ICC2/2_Output/00_setup/tech/saed32nm_1p9m_mw.via1_pitch_no_track_trim_all_pin.tf"
ndm_rvt="4_Backend_ICC2/2_Output/00_setup/ndm_libdir_via1_no_track_trim_all_pin/saed32rvt_tt.ndm"
icc2_lib_dir="$trial_output_root/mnist_npu_icc2_lib"
lock_file="$icc2_lib_dir/lib.ndm.master_lock"

if [ ! -d "$icc2_lib_dir/placement" ]; then
  echo "ERROR: Missing placement block in trial library: $icc2_lib_dir/placement"
  exit 1
fi

if [ -f "$lock_file" ]; then
  echo "ERROR: ICC2 design library is locked. Confirm no ICC2 process is running and remove the stale lock before recovery."
  echo "Lock file: $lock_file"
  strings "$lock_file" || true
  exit 1
fi

export TECH_FILE="/DATA/home/edu135/MNIST/$tech_file"
export NDM_RVT="/DATA/home/edu135/MNIST/$ndm_rvt"
export ICC2_LIB_DIR="/DATA/home/edu135/MNIST/$icc2_lib_dir"
export CORE_UTILIZATION="0.45"

export CTS_LOG_DIR="/DATA/home/edu135/MNIST/$trial_log_root/05_cts_build_only"
export CTS_REPORT_DIR="/DATA/home/edu135/MNIST/$trial_report_root/05_cts_build_only"
export ROUTE_LOG_DIR="/DATA/home/edu135/MNIST/$trial_log_root/06_route_from_cts_build_only"
export ROUTE_REPORT_DIR="/DATA/home/edu135/MNIST/$trial_report_root/06_route_from_cts_build_only"

mkdir -p "$CTS_LOG_DIR" "$CTS_REPORT_DIR" "$ROUTE_LOG_DIR" "$ROUTE_REPORT_DIR"

icc2_shell -f 4_Backend_ICC2/0_Script/05_cts/run_cts_build_only.tcl \
  | tee "$CTS_LOG_DIR/run.log"

icc2_shell -f 4_Backend_ICC2/0_Script/06_route/run_route_initial.tcl \
  | tee "$ROUTE_LOG_DIR/run.log"

echo "MNIST_TRIM_ALL_PIN_CTS_BUILD_ONLY_ROUTE_DONE report_root=$trial_report_root"
