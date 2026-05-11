################################################################################
# ICC2 CTS diagnostic: disable CCD/power-oriented clock_opt cleanup.
#
# The trim_all_pin trial repeatedly stops after clock tree compilation during
# clock_opt Phase 6.  This variant keeps the same placement and clock routing
# intent, but disables CCD and low-power cleanup to isolate that failure mode.
################################################################################

source 4_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

if {![file exists $ICC2_LIB_DIR]} {
  puts "ERROR: Missing ICC2 library: $ICC2_LIB_DIR"
  exit 1
}

open_lib $ICC2_LIB_DIR
open_block -edit placement

set_voltage $DEFAULT_VOLTAGE

set_app_options -name clock_opt.flow.enable_ccd -value false
set_app_options -name clock_opt.flow.enable_power -value false
set_app_options -name cts.common.enable_low_power -value false
set_app_options -name cts.compile.enable_local_skew -value false
set_app_options -name cts.optimize.enable_local_skew -value false
set_app_options -name cts.optimize.enable_cto_power_optimization -value false

report_app_options *clock_opt* > $CTS_REPORT_DIR/app_options.clock_opt.rpt
report_app_options *cts* > $CTS_REPORT_DIR/app_options.cts.rpt

set CTS_CLOCK clk
set CTS_TARGET_SKEW 0.20

set_clock_tree_options \
  -clocks [get_clocks $CTS_CLOCK] \
  -target_skew $CTS_TARGET_SKEW

set_clock_routing_rules \
  -clocks [get_clocks $CTS_CLOCK] \
  -min_routing_layer M4 \
  -max_routing_layer M6 \
  -default_rule

check_clock_trees \
  -clocks [get_clocks $CTS_CLOCK] \
  > $CTS_REPORT_DIR/check_clock_trees.pre.rpt

report_clock_tree_options > $CTS_REPORT_DIR/clock_tree_options.rpt
report_clock_routing_rules > $CTS_REPORT_DIR/clock_routing_rules.rpt

clock_opt \
  -from build_clock \
  -to route_clock

check_clock_trees \
  -clocks [get_clocks $CTS_CLOCK] \
  > $CTS_REPORT_DIR/check_clock_trees.post.rpt

report_clock_qor -type summary > $CTS_REPORT_DIR/clock_qor.summary.rpt
report_clock_qor -type latency > $CTS_REPORT_DIR/clock_qor.latency.rpt
report_clock_qor -type drc_violators > $CTS_REPORT_DIR/clock_qor.drc_violators.rpt
report_clock_qor -type area > $CTS_REPORT_DIR/clock_qor.area.rpt

report_clock_timing -type summary > $CTS_REPORT_DIR/clock_timing.summary.rpt
report_clock_timing -type skew -setup -nworst 20 > $CTS_REPORT_DIR/clock_timing.skew_setup.rpt
report_clock_timing -type skew -hold -nworst 20 > $CTS_REPORT_DIR/clock_timing.skew_hold.rpt
report_clock_timing -type latency -setup -nworst 20 > $CTS_REPORT_DIR/clock_timing.latency_setup.rpt
report_clock_timing -type latency -hold -nworst 20 > $CTS_REPORT_DIR/clock_timing.latency_hold.rpt

report_timing -delay_type max -max_paths 20 > $CTS_REPORT_DIR/timing.max.rpt
report_timing -delay_type min -max_paths 20 > $CTS_REPORT_DIR/timing.min.rpt
report_qor > $CTS_REPORT_DIR/qor.rpt
report_utilization > $CTS_REPORT_DIR/utilization.rpt
report_design -physical > $CTS_REPORT_DIR/design_physical.rpt
check_legality > $CTS_REPORT_DIR/check_legality.rpt

check_pg_connectivity \
  -nets [get_nets {VDD VSS}] \
  -write_connectivity_file $CTS_REPORT_DIR/pg_connectivity_detail.rpt \
  > $CTS_REPORT_DIR/pg_connectivity.rpt

check_pg_drc \
  -nets [get_nets {VDD VSS}] \
  -no_gui \
  -output $CTS_REPORT_DIR/pg_drc.rpt

save_block -as cts
save_lib

exit
