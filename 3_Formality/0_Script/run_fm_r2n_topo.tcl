################################################################################
# MNIST NPU Formality R2N check for the DC topographical synthesis handoff.
#
# Reference      : RTL filelist
# Implementation : DC topo mapped gate netlist
# Guidance       : DC topo SVF
################################################################################

set PROJECT_ROOT /DATA/home/edu135/MNIST
set TOP_NAME nn_top

cd $PROJECT_ROOT

set RTL_FILELIST 1_Input/filelists/rtl.f
set RVT_TT_DB /DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_rvt/db_nldm/saed32rvt_tt1p05v25c.db
set NETLIST 2_Synthesis/2_Output/topo_10ns/${TOP_NAME}.topo_10ns.mapped.vg
set SVF_FILE 2_Synthesis/2_Output/svf/${TOP_NAME}.topo_10ns.mapped.svf

set OUT_DIR 3_Formality/2_Output/r2n_topo_10ns
set RPT_DIR 3_Formality/4_Report/r2n_topo_10ns

file mkdir $OUT_DIR
file mkdir 3_Formality/3_Log
file mkdir $RPT_DIR

remove_container r
remove_container i
remove_guidance
remove_constant -all
remove_black_box -all
remove_user_match -all
remove_dont_verify_point -all
remove_library -all

set synopsys_auto_setup true
set hdlin_error_on_mismatch_message false
set hdlin_warning_on_mismatch_message {FMR_ELAB-147 FMR_ELAB-116 FMR_ELAB-115}
set hdlin_ignore_full_case false
set hdlin_ignore_parallel_case false
set hdlin_unresolved_modules black_box
set verification_clock_gate_reverse_gating true
set verification_failing_point_limit 1000
set verification_timeout_limit 08:00:00
set verification_effort_level high
set svf_presto_parameter_naming true
set verification_set_undriven_signals synthesis

set_svf $SVF_FILE

read_db -technology_library [list $RVT_TT_DB]

set RTL_FILES {}
set fp [open $RTL_FILELIST r]
while {[gets $fp line] >= 0} {
  set line [string trim $line]
  if {$line eq ""} {
    continue
  }
  if {[string match "#*" $line]} {
    continue
  }
  lappend RTL_FILES $line
}
close $fp

puts "INFO: Reading reference RTL files:"
foreach rtl_file $RTL_FILES {
  puts "INFO:   $rtl_file"
}

read_sverilog -r -12 -libname WORK $RTL_FILES
set_top r:/WORK/$TOP_NAME
set_clock r:/WORK/$TOP_NAME/clk

read_verilog -i -netlist -libname WORK $NETLIST
set_top i:/WORK/$TOP_NAME
set_clock i:/WORK/$TOP_NAME/clk

match

report_unmatched_points > ${RPT_DIR}/r2n_topo_10ns.unmatched_points.rpt
report_user_matches > ${RPT_DIR}/r2n_topo_10ns.user_matches.rpt
report_passing_points > ${RPT_DIR}/r2n_topo_10ns.passing_points.pre_verify.rpt

if {[verify]} {
  puts "FM_R2N_RESULT: PASS"
} else {
  puts "FM_R2N_RESULT: FAIL"
}

report_failing_points > ${RPT_DIR}/r2n_topo_10ns.failing_points.rpt
report_aborted_points > ${RPT_DIR}/r2n_topo_10ns.aborted_points.rpt
report_unverified_points > ${RPT_DIR}/r2n_topo_10ns.unverified_points.rpt
report_black_boxes > ${RPT_DIR}/r2n_topo_10ns.black_boxes.rpt
report_constants > ${RPT_DIR}/r2n_topo_10ns.constants.rpt
report_dont_verify_points > ${RPT_DIR}/r2n_topo_10ns.dont_verify_points.rpt
report_unmatched_points > ${RPT_DIR}/r2n_topo_10ns.unmatched_points.post_verify.rpt
report_passing_points > ${RPT_DIR}/r2n_topo_10ns.passing_points.post_verify.rpt

save_session -replace ${OUT_DIR}/r2n_topo_10ns_fm_session

exit

