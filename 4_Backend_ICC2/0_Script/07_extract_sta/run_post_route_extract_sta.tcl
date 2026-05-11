################################################################################
# Post-route report extraction from a saved ICC2 block.
#
# This script does not route or edit the design. It reopens the saved route-plus-
# PG candidate and records timing, route, PG, legality, and electrical reports.
################################################################################

source 4_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set EXTRACT_INPUT_BLOCK route_pg_ladder_vdd50_vss20_path507x55_h015
if {[info exists ::env(EXTRACT_INPUT_BLOCK)] && $::env(EXTRACT_INPUT_BLOCK) ne ""} {
  set EXTRACT_INPUT_BLOCK $::env(EXTRACT_INPUT_BLOCK)
}

set EXTRACT_REPORT_DIR $PROJECT_ROOT/4_Backend_ICC2/4_Report/07_extract_sta_pg_ladder
if {[info exists ::env(EXTRACT_REPORT_DIR)] && $::env(EXTRACT_REPORT_DIR) ne ""} {
  set EXTRACT_REPORT_DIR $::env(EXTRACT_REPORT_DIR)
}

file mkdir $EXTRACT_REPORT_DIR

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

proc run_optional_report {label file_name command_text} {
  global status_fh
  if {[catch {redirect -file $file_name {uplevel #0 $command_text}} err]} {
    set fh [open $file_name w]
    puts $fh "OPTIONAL_REPORT_FAILED: $err"
    close $fh
    puts $status_fh "$label\tOPTIONAL_FAIL\t$file_name\t$err"
    return 0
  }
  puts $status_fh "$label\tPASS\t$file_name\t"
  return 1
}

puts "EXTRACT lib=$ICC2_LIB_DIR"
puts "EXTRACT input_block=$EXTRACT_INPUT_BLOCK"
puts "EXTRACT report_dir=$EXTRACT_REPORT_DIR"

set status_fh [open $EXTRACT_REPORT_DIR/report_status.tsv w]
puts $status_fh "report\tstatus\tpath\tmessage"

open_lib $ICC2_LIB_DIR
open_block $EXTRACT_INPUT_BLOCK

set_voltage $DEFAULT_VOLTAGE

set_ignored_layers \
  -min_routing_layer M1 \
  -max_routing_layer M8

catch {
  report_ignored_layers > $EXTRACT_REPORT_DIR/ignored_layers.rpt
}

connect_pg_net -net VDD [get_pins -hierarchical -quiet */VDD]
connect_pg_net -net VSS [get_pins -hierarchical -quiet */VSS]

run_report check_routes \
  $EXTRACT_REPORT_DIR/check_routes.rpt \
  {check_routes}

run_report antenna \
  $EXTRACT_REPORT_DIR/antenna.rpt \
  {check_routes -antenna true}

run_report report_qor \
  $EXTRACT_REPORT_DIR/qor.rpt \
  {report_qor}

run_report report_global_timing \
  $EXTRACT_REPORT_DIR/global_timing.rpt \
  {report_global_timing}

run_report timing_max \
  $EXTRACT_REPORT_DIR/timing.max.rpt \
  {report_timing -delay_type max -max_paths 50}

run_report timing_min \
  $EXTRACT_REPORT_DIR/timing.min.rpt \
  {report_timing -delay_type min -max_paths 50}

run_report timing_min_violators \
  $EXTRACT_REPORT_DIR/timing.min.violators.rpt \
  {report_timing -delay_type min -max_paths 100 -slack_lesser_than 0.0}

run_report constraint_all_violators \
  $EXTRACT_REPORT_DIR/constraint.all_violators.rpt \
  {report_constraint -all_violators}

run_report constraint_max_transition \
  $EXTRACT_REPORT_DIR/constraint.max_transition.rpt \
  {report_constraint -all_violators -max_transition}

run_report constraint_max_capacitance \
  $EXTRACT_REPORT_DIR/constraint.max_capacitance.rpt \
  {report_constraint -all_violators -max_capacitance}

run_report constraint_hold \
  $EXTRACT_REPORT_DIR/constraint.hold.rpt \
  {report_constraint -all_violators -min_delay}

run_report utilization \
  $EXTRACT_REPORT_DIR/utilization.rpt \
  {report_utilization}

run_report design_physical \
  $EXTRACT_REPORT_DIR/design_physical.rpt \
  {report_design -physical}

run_report check_legality \
  $EXTRACT_REPORT_DIR/check_legality.rpt \
  {check_legality}

run_report pg_connectivity \
  $EXTRACT_REPORT_DIR/pg_connectivity.rpt \
  "check_pg_connectivity -nets \[get_nets {VDD VSS}\] -write_connectivity_file $EXTRACT_REPORT_DIR/pg_connectivity_detail.rpt"

if {[catch {
  check_pg_drc \
    -nets [get_nets {VDD VSS}] \
    -no_gui \
    -output $EXTRACT_REPORT_DIR/pg_drc.rpt
} err]} {
  set fh [open $EXTRACT_REPORT_DIR/pg_drc.rpt w]
  puts $fh "ERROR: $err"
  close $fh
  puts $status_fh "pg_drc\tFAIL\t$EXTRACT_REPORT_DIR/pg_drc.rpt\t$err"
} else {
  puts $status_fh "pg_drc\tPASS\t$EXTRACT_REPORT_DIR/pg_drc.rpt\t"
}

run_optional_report report_analysis_coverage \
  $EXTRACT_REPORT_DIR/analysis_coverage.rpt \
  {report_analysis_coverage}

close $status_fh

puts "EXTRACT DONE"
exit
