#!/usr/bin/env bash
set -euo pipefail

cd /DATA/home/edu135/MNIST

tech_dir="4_Backend_ICC2/2_Output/00_setup/tech"
ndm_dir="4_Backend_ICC2/2_Output/00_setup/ndm_libdir_via1_no_track_trim_all_pin"
log_dir="4_Backend_ICC2/3_Log/00_setup"
src_tf="/DATA/home/edu135/lib/SAED32_EDK/tech/milkyway/saed32nm_1p9m_mw.tf"
dst_tf="$tech_dir/saed32nm_1p9m_mw.via1_pitch_no_track_trim_all_pin.tf"

mkdir -p "$tech_dir" "$ndm_dir" "$log_dir"

awk '
  BEGIN { in_via1 = 0 }
  /^Layer[[:space:]]+"VIA1"[[:space:]]*\{/ { in_via1 = 1 }
  in_via1 && /\/\*pitch[[:space:]]*=[[:space:]]*0\.36\*\// {
    sub(/\/\*pitch[[:space:]]*=[[:space:]]*0\.36\*\//, "pitch                           = 0.36")
  }
  in_via1 && /^[[:space:]]*onWireTrack[[:space:]]*=/ { next }
  in_via1 && /^[[:space:]]*onGrid[[:space:]]*=/ { next }
  in_via1 && /^}/ { in_via1 = 0 }
  { print }
' "$src_tf" > "$dst_tf"

env \
  MNIST_NDM_TECH_FILE="$dst_tf" \
  MNIST_NDM_DIR="$ndm_dir" \
  lm_shell -f 4_Backend_ICC2/0_Script/00_setup/build_saed32_rvt_ndm_libdir_via1_no_track_trim_all_pin.tcl \
    | tee "$log_dir/build_saed32_rvt_ndm_libdir_via1_no_track_trim_all_pin.log"

echo "MNIST_LIBDIR_VIA1_NO_TRACK_TRIM_ALL_PIN_NDM_DONE ndm_dir=$ndm_dir tech_file=$dst_tf"
