#!/usr/bin/env bash
set -euo pipefail

cd /DATA/home/edu135/MNIST

trial_name="libdir_via1_no_track_util45_route"
trial_output_root="4_Backend_ICC2/2_Output/trials/$trial_name"
trial_report_root="4_Backend_ICC2/4_Report/trials/$trial_name"
trial_log_root="4_Backend_ICC2/3_Log/trials/$trial_name"

tech_file="4_Backend_ICC2/2_Output/00_setup/tech/saed32nm_1p9m_mw.via1_pitch_no_track.tf"
ndm_rvt="4_Backend_ICC2/2_Output/00_setup/ndm_libdir_via1_no_track/saed32rvt_tt.ndm"
icc2_lib_dir="$trial_output_root/mnist_npu_icc2_lib"

if [ ! -f "$tech_file" ]; then
  echo "ERROR: Missing patched tech file: $tech_file"
  echo "Run 4_Backend_ICC2/0_Script/00_setup/build_saed32_rvt_ndm_libdir_via1_no_track.sh first."
  exit 1
fi

if [ ! -d "$ndm_rvt" ]; then
  echo "ERROR: Missing trial NDM: $ndm_rvt"
  echo "Run 4_Backend_ICC2/0_Script/00_setup/build_saed32_rvt_ndm_libdir_via1_no_track.sh first."
  exit 1
fi

if [ -f "$icc2_lib_dir/lib.ndm.master_lock" ]; then
  echo "ERROR: ICC2 design library is locked. Do not start a second trial run."
  echo "Lock file: $icc2_lib_dir/lib.ndm.master_lock"
  strings "$icc2_lib_dir/lib.ndm.master_lock" || true
  exit 1
fi

export TECH_FILE="/DATA/home/edu135/MNIST/$tech_file"
export NDM_RVT="/DATA/home/edu135/MNIST/$ndm_rvt"
export ICC2_LIB_DIR="/DATA/home/edu135/MNIST/$icc2_lib_dir"
export CORE_UTILIZATION="0.45"

mkdir -p "$trial_output_root" "$trial_report_root" "$trial_log_root"

run_stage() {
  local stage="$1"
  local script="$2"
  local log_dir="$trial_log_root/$stage"
  mkdir -p "$log_dir" "$trial_report_root/$stage"

  export INIT_LOG_DIR="/DATA/home/edu135/MNIST/$trial_log_root/01_init_design"
  export FLOORPLAN_LOG_DIR="/DATA/home/edu135/MNIST/$trial_log_root/02_floorplan"
  export POWER_LOG_DIR="/DATA/home/edu135/MNIST/$trial_log_root/03_powerplan"
  export PLACE_LOG_DIR="/DATA/home/edu135/MNIST/$trial_log_root/04_place"
  export CTS_LOG_DIR="/DATA/home/edu135/MNIST/$trial_log_root/05_cts"
  export ROUTE_LOG_DIR="/DATA/home/edu135/MNIST/$trial_log_root/06_route"

  export INIT_REPORT_DIR="/DATA/home/edu135/MNIST/$trial_report_root/01_init_design"
  export FLOORPLAN_REPORT_DIR="/DATA/home/edu135/MNIST/$trial_report_root/02_floorplan"
  export POWER_REPORT_DIR="/DATA/home/edu135/MNIST/$trial_report_root/03_powerplan"
  export PLACE_REPORT_DIR="/DATA/home/edu135/MNIST/$trial_report_root/04_place"
  export CTS_REPORT_DIR="/DATA/home/edu135/MNIST/$trial_report_root/05_cts"
  export ROUTE_REPORT_DIR="/DATA/home/edu135/MNIST/$trial_report_root/06_route"

  icc2_shell -f "$script" | tee "$log_dir/run.log"
}

run_stage 01_init_design 4_Backend_ICC2/0_Script/01_init_design/run_init_design_check.tcl
run_stage 02_floorplan 4_Backend_ICC2/0_Script/02_floorplan/run_floorplan_initial.tcl
run_stage 03_powerplan 4_Backend_ICC2/0_Script/03_powerplan/run_powerplan_initial.tcl
run_stage 04_place 4_Backend_ICC2/0_Script/04_place/run_place_initial.tcl
run_stage 05_cts 4_Backend_ICC2/0_Script/05_cts/run_cts_initial.tcl
run_stage 06_route 4_Backend_ICC2/0_Script/06_route/run_route_initial.tcl

echo "MNIST_LIBDIR_VIA1_NO_TRACK_UTIL45_BACKEND_DONE report_root=$trial_report_root"
