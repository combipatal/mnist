################################################################################
# Post-route route_opt trial from the saved route-plus-PG clean candidate.
#
# The source block is copied first. The input block remains available for
# comparison; all optimization happens on ROUTE_OPT_OUTPUT_BLOCK.
################################################################################

source 4_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set ROUTE_OPT_INPUT_BLOCK route_pg_ladder_vdd50_vss20_path507x55_h015
if {[info exists ::env(ROUTE_OPT_INPUT_BLOCK)] && $::env(ROUTE_OPT_INPUT_BLOCK) ne ""} {
  set ROUTE_OPT_INPUT_BLOCK $::env(ROUTE_OPT_INPUT_BLOCK)
}

set ROUTE_OPT_OUTPUT_BLOCK route_pg_ladder_route_opt1
if {[info exists ::env(ROUTE_OPT_OUTPUT_BLOCK)] && $::env(ROUTE_OPT_OUTPUT_BLOCK) ne ""} {
  set ROUTE_OPT_OUTPUT_BLOCK $::env(ROUTE_OPT_OUTPUT_BLOCK)
}

set ROUTE_OPT_REPORT_DIR $PROJECT_ROOT/4_Backend_ICC2/4_Report/07_extract_sta_route_opt1
if {[info exists ::env(ROUTE_OPT_REPORT_DIR)] && $::env(ROUTE_OPT_REPORT_DIR) ne ""} {
  set ROUTE_OPT_REPORT_DIR $::env(ROUTE_OPT_REPORT_DIR)
}

file mkdir $ROUTE_OPT_REPORT_DIR

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

puts "ROUTE_OPT lib=$ICC2_LIB_DIR"
puts "ROUTE_OPT input_block=$ROUTE_OPT_INPUT_BLOCK"
puts "ROUTE_OPT output_block=$ROUTE_OPT_OUTPUT_BLOCK"
puts "ROUTE_OPT report_dir=$ROUTE_OPT_REPORT_DIR"

set status_fh [open $ROUTE_OPT_REPORT_DIR/report_status.tsv w]
puts $status_fh "step\tstatus\tpath\tmessage"

open_lib $ICC2_LIB_DIR

set copy_status [catch {
  copy_block -from_block $ROUTE_OPT_INPUT_BLOCK -to_block $ROUTE_OPT_OUTPUT_BLOCK
} copy_msg]
puts $status_fh "copy_block\t[expr {$copy_status == 0 ? "PASS" : "FAIL"}]\t$ROUTE_OPT_OUTPUT_BLOCK\t$copy_msg"
if {$copy_status != 0} {
  close $status_fh
  error "copy_block failed: $copy_msg"
}

current_block $ROUTE_OPT_OUTPUT_BLOCK
set_voltage $DEFAULT_VOLTAGE

set_ignored_layers \
  -min_routing_layer M1 \
  -max_routing_layer M8

connect_pg_net -net VDD [get_pins -hierarchical -quiet */VDD]
connect_pg_net -net VSS [get_pins -hierarchical -quiet */VSS]

run_report check_routes_before \
  $ROUTE_OPT_REPORT_DIR/check_routes.before_route_opt.rpt \
  {check_routes}

run_report check_legality_before \
  $ROUTE_OPT_REPORT_DIR/check_legality.before_route_opt.rpt \
  {check_legality}

run_report qor_before \
  $ROUTE_OPT_REPORT_DIR/qor.before_route_opt.rpt \
  {report_qor}

run_report constraints_before \
  $ROUTE_OPT_REPORT_DIR/constraints.before_route_opt.rpt \
  {report_constraint -all_violators}

set route_opt_status [catch {route_opt} route_opt_msg]
puts $status_fh "route_opt\t[expr {$route_opt_status == 0 ? "PASS" : "FAIL"}]\t\t$route_opt_msg"

connect_pg_net -net VDD [get_pins -hierarchical -quiet */VDD]
connect_pg_net -net VSS [get_pins -hierarchical -quiet */VSS]

run_report check_routes_after \
  $ROUTE_OPT_REPORT_DIR/check_routes.after_route_opt.rpt \
  {check_routes}

run_report check_legality_after \
  $ROUTE_OPT_REPORT_DIR/check_legality.after_route_opt.rpt \
  {check_legality}

run_report pg_connectivity_after \
  $ROUTE_OPT_REPORT_DIR/pg_connectivity.after_route_opt.rpt \
  "check_pg_connectivity -nets \[get_nets {VDD VSS}\] -write_connectivity_file $ROUTE_OPT_REPORT_DIR/pg_connectivity_detail.after_route_opt.rpt"

if {[catch {
  check_pg_drc \
    -nets [get_nets {VDD VSS}] \
    -no_gui \
    -output $ROUTE_OPT_REPORT_DIR/pg_drc.after_route_opt.rpt
} pg_drc_msg]} {
  set fh [open $ROUTE_OPT_REPORT_DIR/pg_drc.after_route_opt.rpt w]
  puts $fh "ERROR: $pg_drc_msg"
  close $fh
  puts $status_fh "pg_drc_after\tFAIL\t$ROUTE_OPT_REPORT_DIR/pg_drc.after_route_opt.rpt\t$pg_drc_msg"
} else {
  puts $status_fh "pg_drc_after\tPASS\t$ROUTE_OPT_REPORT_DIR/pg_drc.after_route_opt.rpt\t"
}

run_report qor_after \
  $ROUTE_OPT_REPORT_DIR/qor.after_route_opt.rpt \
  {report_qor}

run_report global_timing_after \
  $ROUTE_OPT_REPORT_DIR/global_timing.after_route_opt.rpt \
  {report_global_timing}

run_report constraints_after \
  $ROUTE_OPT_REPORT_DIR/constraints.after_route_opt.rpt \
  {report_constraint -all_violators}

run_report constraint_hold_after \
  $ROUTE_OPT_REPORT_DIR/constraint.hold.after_route_opt.rpt \
  {report_constraint -all_violators -min_delay}

run_report constraint_max_transition_after \
  $ROUTE_OPT_REPORT_DIR/constraint.max_transition.after_route_opt.rpt \
  {report_constraint -all_violators -max_transition}

run_report constraint_max_capacitance_after \
  $ROUTE_OPT_REPORT_DIR/constraint.max_capacitance.after_route_opt.rpt \
  {report_constraint -all_violators -max_capacitance}

run_report timing_max_after \
  $ROUTE_OPT_REPORT_DIR/timing.max.after_route_opt.rpt \
  {report_timing -delay_type max -max_paths 50}

run_report timing_min_after \
  $ROUTE_OPT_REPORT_DIR/timing.min.after_route_opt.rpt \
  {report_timing -delay_type min -max_paths 50}

run_report design_physical_after \
  $ROUTE_OPT_REPORT_DIR/design_physical.after_route_opt.rpt \
  {report_design -physical}

run_report utilization_after \
  $ROUTE_OPT_REPORT_DIR/utilization.after_route_opt.rpt \
  {report_utilization}

set manifest_fh [open $ROUTE_OPT_REPORT_DIR/route_opt_manifest.txt w]
puts $manifest_fh "source_block=$ROUTE_OPT_INPUT_BLOCK"
puts $manifest_fh "output_block=$ROUTE_OPT_OUTPUT_BLOCK"
puts $manifest_fh "icc2_lib=$ICC2_LIB_DIR"
puts $manifest_fh "report_dir=$ROUTE_OPT_REPORT_DIR"
puts $manifest_fh "command=route_opt"
puts $manifest_fh "route_opt_status=$route_opt_status"
puts $manifest_fh "route_opt_message=$route_opt_msg"
close $manifest_fh

save_block
save_lib

close $status_fh

if {$route_opt_status != 0} {
  error "route_opt failed: $route_opt_msg"
}

puts "ROUTE_OPT DONE"
exit
