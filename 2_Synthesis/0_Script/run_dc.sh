#!/usr/bin/env bash
set -euo pipefail

cd /DATA/home/edu135/MNIST
mkdir -p 2_Synthesis/3_Log

dc_shell -f 2_Synthesis/0_Script/run_dc.tcl | tee 2_Synthesis/3_Log/run_dc.log

