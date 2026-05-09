#!/usr/bin/env bash
set -euo pipefail

cd /DATA/home/edu135/MNIST

fm_shell -f 3_Formality/0_Script/run_fm_r2n_topo.tcl \
  | tee 3_Formality/3_Log/run_fm_r2n_topo.log

