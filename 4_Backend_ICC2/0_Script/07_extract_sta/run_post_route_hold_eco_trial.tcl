################################################################################
# Post-route hold ECO trial from the saved route-plus-PG clean candidate.
#
# The source block is copied first. The input block remains available for
# comparison; all ECO changes happen on HOLD_ECO_OUTPUT_BLOCK.
################################################################################

source 4_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set HOLD_ECO_INPUT_BLOCK route_pg_ladder_vdd50_vss20_path507x55_h015
if {[info exists ::env(HOLD_ECO_INPUT_BLOCK)] && $::env(HOLD_ECO_INPUT_BLOCK) ne ""} {
  set HOLD_ECO_INPUT_BLOCK $::env(HOLD_ECO_INPUT_BLOCK)
}

set HOLD_ECO_OUTPUT_BLOCK route_pg_ladder_hold_eco_open_site_m0
if {[info exists ::env(HOLD_ECO_OUTPUT_BLOCK)] && $::env(HOLD_ECO_OUTPUT_BLOCK) ne ""} {
  set HOLD_ECO_OUTPUT_BLOCK $::env(HOLD_ECO_OUTPUT_BLOCK)
}

set HOLD_ECO_REPORT_DIR $PROJECT_ROOT/4_Backend_ICC2/4_Report/07_extract_sta_hold_eco
if {[info exists ::env(HOLD_ECO_REPORT_DIR)] && $::env(HOLD_ECO_REPORT_DIR) ne ""} {
  set HOLD_ECO_REPORT_DIR $::env(HOLD_ECO_REPORT_DIR)
}

set HOLD_ECO_OUTPUT_DIR $PROJECT_ROOT/4_Backend_ICC2/2_Output/07_extract_sta_hold_eco
if {[info exists ::env(HOLD_ECO_OUTPUT_DIR)] && $::env(HOLD_ECO_OUTPUT_DIR) ne ""} {
  set HOLD_ECO_OUTPUT_DIR $::env(HOLD_ECO_OUTPUT_DIR)
}

set HOLD_MARGIN 0.00
if {[info exists ::env(HOLD_MARGIN)] && $::env(HOLD_MARGIN) ne ""} {
  set HOLD_MARGIN $::env(HOLD_MARGIN)
}

set PHYSICAL_MODE open_site
if {[info exists ::env(PHYSICAL_MODE)] && $::env(PHYSICAL_MODE) ne ""} {
  set PHYSICAL_MODE $::env(PHYSICAL_MODE)
}

set PT_EXEC /tools/synopsys/prime/W-2024.09-SP5-3/bin/pt_shell
if {[info exists ::env(PT_EXEC)] && $::env(PT_EXEC) ne ""} {
  set PT_EXEC $::env(PT_EXEC)
}

set SESSION_DIR $HOLD_ECO_OUTPUT_DIR/pt_eco_session
set PT_WORK_DIR $HOLD_ECO_OUTPUT_DIR/pt_work
file mkdir $HOLD_ECO_REPORT_DIR
file mkdir $HOLD_ECO_OUTPUT_DIR
file mkdir $SESSION_DIR
file mkdir $PT_WORK_DIR

if {![file exists $ICC2_LIB_DIR]} {
  puts "ERROR: Missing ICC2 library: $ICC2_LIB_DIR"
  exit 1
}

proc run_report {label file_name command_text} {
  global status_fh
  if {[catch {redirect -file $file_name {uplevel #0 $command_text}} err]} {
    set fh [open $file_name w]
    puts $fh "ERROR: $err"
    close $fh
    puts $status_fh "$label\tFAIL\t$file_name\t$err"
    return 0
  }
  puts $status_fh "$label\tPASS\t$file_name\t"
  return 1
}

puts "HOLD_ECO lib=$ICC2_LIB_DIR"
puts "HOLD_ECO input_block=$HOLD_ECO_INPUT_BLOCK"
puts "HOLD_ECO output_block=$HOLD_ECO_OUTPUT_BLOCK"
puts "HOLD_ECO report_dir=$HOLD_ECO_REPORT_DIR"
puts "HOLD_ECO margin=$HOLD_MARGIN"
puts "HOLD_ECO physical_mode=$PHYSICAL_MODE"
puts "HOLD_ECO pt_exec=$PT_EXEC"

set status_fh [open $HOLD_ECO_REPORT_DIR/report_status.tsv w]
puts $status_fh "step\tstatus\tpath\tmessage"

open_lib $ICC2_LIB_DIR

set copy_status [catch {
  copy_block -from_block $HOLD_ECO_INPUT_BLOCK -to_block $HOLD_ECO_OUTPUT_BLOCK
} copy_msg]
puts $status_fh "copy_block\t[expr {$copy_status == 0 ? "PASS" : "FAIL"}]\t$HOLD_ECO_OUTPUT_BLOCK\t$copy_msg"
if {$copy_status != 0} {
  close $status_fh
  error "copy_block failed: $copy_msg"
}

current_block $HOLD_ECO_OUTPUT_BLOCK
set_voltage $DEFAULT_VOLTAGE

set_ignored_layers \
  -min_routing_layer M1 \
  -max_routing_layer M8

connect_pg_net -net VDD [get_pins -hierarchical -quiet */VDD]
connect_pg_net -net VSS [get_pins -hierarchical -quiet */VSS]

run_report check_routes_before \
  $HOLD_ECO_REPORT_DIR/check_routes.before_hold_eco.rpt \
  {check_routes}

run_report check_legality_before \
  $HOLD_ECO_REPORT_DIR/check_legality.before_hold_eco.rpt \
  {check_legality}

run_report qor_before \
  $HOLD_ECO_REPORT_DIR/qor.before_hold_eco.rpt \
  {report_qor}

run_report global_timing_before \
  $HOLD_ECO_REPORT_DIR/global_timing.before_hold_eco.rpt \
  {report_global_timing}

run_report constraints_before \
  $HOLD_ECO_REPORT_DIR/constraints.before_hold_eco.rpt \
  {report_constraint -all_violators}

run_report timing_min_before \
  $HOLD_ECO_REPORT_DIR/timing.min.before_hold_eco.rpt \
  {report_timing -delay_type min -max_paths 50}

set pt_status [catch {
  set_pt_options -pt_exec $PT_EXEC -work_dir $PT_WORK_DIR
} pt_msg]
puts $status_fh "set_pt_options\t[expr {$pt_status == 0 ? "PASS" : "FAIL"}]\t$PT_WORK_DIR\t$pt_msg"
run_report pt_options \
  $HOLD_ECO_REPORT_DIR/pt_options.rpt \
  {report_pt_options}

set starrc_status [catch {
  set_app_options -name extract.starrc_mode -value false
} starrc_msg]
puts $status_fh "set_extract_starrc_mode\t[expr {$starrc_status == 0 ? "PASS" : "FAIL"}]\t\t$starrc_msg"

set eco_status [catch {
  eco_opt \
    -types hold \
    -hold_margin $HOLD_MARGIN \
    -physical_mode $PHYSICAL_MODE \
    -save_session $SESSION_DIR
} eco_msg]
puts $status_fh "eco_opt_hold\t[expr {$eco_status == 0 ? "PASS" : "FAIL"}]\t$SESSION_DIR\t$eco_msg"

connect_pg_net -net VDD [get_pins -hierarchical -quiet */VDD]
connect_pg_net -net VSS [get_pins -hierarchical -quiet */VSS]

run_report check_routes_after \
  $HOLD_ECO_REPORT_DIR/check_routes.after_hold_eco.rpt \
  {check_routes}

run_report check_legality_after \
  $HOLD_ECO_REPORT_DIR/check_legality.after_hold_eco.rpt \
  {check_legality}

run_report pg_connectivity_after \
  $HOLD_ECO_REPORT_DIR/pg_connectivity.after_hold_eco.rpt \
  "check_pg_connectivity -nets \[get_nets {VDD VSS}\] -write_connectivity_file $HOLD_ECO_REPORT_DIR/pg_connectivity_detail.after_hold_eco.rpt"

if {[catch {
  check_pg_drc \
    -nets [get_nets {VDD VSS}] \
    -no_gui \
    -output $HOLD_ECO_REPORT_DIR/pg_drc.after_hold_eco.rpt
} pg_drc_msg]} {
  set fh [open $HOLD_ECO_REPORT_DIR/pg_drc.after_hold_eco.rpt w]
  puts $fh "ERROR: $pg_drc_msg"
  close $fh
  puts $status_fh "pg_drc_after\tFAIL\t$HOLD_ECO_REPORT_DIR/pg_drc.after_hold_eco.rpt\t$pg_drc_msg"
} else {
  puts $status_fh "pg_drc_after\tPASS\t$HOLD_ECO_REPORT_DIR/pg_drc.after_hold_eco.rpt\t"
}

run_report qor_after \
  $HOLD_ECO_REPORT_DIR/qor.after_hold_eco.rpt \
  {report_qor}

run_report global_timing_after \
  $HOLD_ECO_REPORT_DIR/global_timing.after_hold_eco.rpt \
  {report_global_timing}

run_report constraints_after \
  $HOLD_ECO_REPORT_DIR/constraints.after_hold_eco.rpt \
  {report_constraint -all_violators}

run_report constraint_hold_after \
  $HOLD_ECO_REPORT_DIR/constraint.hold.after_hold_eco.rpt \
  {report_constraint -all_violators -min_delay}

run_report constraint_max_transition_after \
  $HOLD_ECO_REPORT_DIR/constraint.max_transition.after_hold_eco.rpt \
  {report_constraint -all_violators -max_transition}

run_report constraint_max_capacitance_after \
  $HOLD_ECO_REPORT_DIR/constraint.max_capacitance.after_hold_eco.rpt \
  {report_constraint -all_violators -max_capacitance}

run_report timing_max_after \
  $HOLD_ECO_REPORT_DIR/timing.max.after_hold_eco.rpt \
  {report_timing -delay_type max -max_paths 50}

run_report timing_min_after \
  $HOLD_ECO_REPORT_DIR/timing.min.after_hold_eco.rpt \
  {report_timing -delay_type min -max_paths 50}

run_report reference_after \
  $HOLD_ECO_REPORT_DIR/reference.after_hold_eco.rpt \
  {report_reference}

run_report design_physical_after \
  $HOLD_ECO_REPORT_DIR/design_physical.after_hold_eco.rpt \
  {report_design -physical}

run_report utilization_after \
  $HOLD_ECO_REPORT_DIR/utilization.after_hold_eco.rpt \
  {report_utilization}

set manifest_fh [open $HOLD_ECO_OUTPUT_DIR/hold_eco_manifest.txt w]
puts $manifest_fh "source_block=$HOLD_ECO_INPUT_BLOCK"
puts $manifest_fh "output_block=$HOLD_ECO_OUTPUT_BLOCK"
puts $manifest_fh "icc2_lib=$ICC2_LIB_DIR"
puts $manifest_fh "report_dir=$HOLD_ECO_REPORT_DIR"
puts $manifest_fh "output_dir=$HOLD_ECO_OUTPUT_DIR"
puts $manifest_fh "command=eco_opt -types hold -hold_margin $HOLD_MARGIN -physical_mode $PHYSICAL_MODE"
puts $manifest_fh "hold_margin=$HOLD_MARGIN"
puts $manifest_fh "physical_mode=$PHYSICAL_MODE"
puts $manifest_fh "pt_exec=$PT_EXEC"
puts $manifest_fh "pt_work_dir=$PT_WORK_DIR"
puts $manifest_fh "session_dir=$SESSION_DIR"
puts $manifest_fh "set_pt_options_status=$pt_status"
puts $manifest_fh "set_pt_options_message=$pt_msg"
puts $manifest_fh "set_extract_starrc_mode_status=$starrc_status"
puts $manifest_fh "set_extract_starrc_mode_message=$starrc_msg"
puts $manifest_fh "eco_status=$eco_status"
puts $manifest_fh "eco_message=$eco_msg"
close $manifest_fh

save_block
save_lib

close $status_fh

if {$pt_status != 0 || $eco_status != 0} {
  error "hold ECO failed. See $HOLD_ECO_OUTPUT_DIR/hold_eco_manifest.txt"
}

puts "HOLD_ECO DONE"
exit
