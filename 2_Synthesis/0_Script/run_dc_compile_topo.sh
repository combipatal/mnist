#!/usr/bin/env bash
set -euo pipefail

cd /DATA/home/edu135/MNIST

dc_shell -topographical_mode -f 2_Synthesis/0_Script/run_dc_compile_topo.tcl \
  | tee 2_Synthesis/3_Log/run_dc_compile_topo.log

