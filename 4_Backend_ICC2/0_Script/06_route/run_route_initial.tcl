################################################################################
# ICC2 first signal route for the MNIST NPU RVT-only baseline.
################################################################################

source 4_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

if {![file exists $ICC2_LIB_DIR]} {
  puts "ERROR: Missing ICC2 library: $ICC2_LIB_DIR"
  exit 1
}

open_lib $ICC2_LIB_DIR
open_block -edit cts

set_voltage $DEFAULT_VOLTAGE

# The clock tree was routed during CTS.  This first route step routes signal
# nets and records feasibility evidence; it is not signoff closure.
set_ignored_layers \
  -min_routing_layer M1 \
  -max_routing_layer M8

catch {report_ignored_layers > $ROUTE_REPORT_DIR/ignored_layers.rpt}

check_routability > $ROUTE_REPORT_DIR/check_routability.rpt

route_auto

# Save the routed database before long post-route checks.  This preserves the
# route_auto result even when a report/check step is interrupted.
save_block -as route_auto
save_lib

connect_pg_net -net VDD [get_pins -hierarchical -quiet */VDD]
connect_pg_net -net VSS [get_pins -hierarchical -quiet */VSS]

check_routes > $ROUTE_REPORT_DIR/check_routes.rpt
catch {check_routes -antenna true > $ROUTE_REPORT_DIR/antenna.rpt}

report_qor > $ROUTE_REPORT_DIR/qor.rpt
report_timing -delay_type max -max_paths 20 > $ROUTE_REPORT_DIR/timing.max.rpt
report_timing -delay_type min -max_paths 20 > $ROUTE_REPORT_DIR/timing.min.rpt
report_utilization > $ROUTE_REPORT_DIR/utilization.rpt
report_design -physical > $ROUTE_REPORT_DIR/design_physical.rpt
check_legality > $ROUTE_REPORT_DIR/check_legality.rpt

check_pg_connectivity \
  -nets [get_nets {VDD VSS}] \
  -write_connectivity_file $ROUTE_REPORT_DIR/pg_connectivity_detail.rpt \
  > $ROUTE_REPORT_DIR/pg_connectivity.rpt

check_pg_drc \
  -nets [get_nets {VDD VSS}] \
  -no_gui \
  -output $ROUTE_REPORT_DIR/pg_drc.rpt

save_block -as route
save_lib

exit
