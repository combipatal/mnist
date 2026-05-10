################################################################################
# ICC2 route DRC repair trial 1 for the MNIST NPU RVT-only baseline.
################################################################################

source 4_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set ROUTE_ECO_REPORT_DIR 4_Backend_ICC2/4_Report/06_route_eco_drc1
set ROUTE_ECO_INPUT_BLOCK route
set ROUTE_ECO_OUTPUT_BLOCK route_eco_drc1

if {[info exists ::env(ROUTE_ECO_REPORT_DIR)]} {
  set ROUTE_ECO_REPORT_DIR $::env(ROUTE_ECO_REPORT_DIR)
}
if {[info exists ::env(ROUTE_ECO_INPUT_BLOCK)]} {
  set ROUTE_ECO_INPUT_BLOCK $::env(ROUTE_ECO_INPUT_BLOCK)
}
if {[info exists ::env(ROUTE_ECO_OUTPUT_BLOCK)]} {
  set ROUTE_ECO_OUTPUT_BLOCK $::env(ROUTE_ECO_OUTPUT_BLOCK)
}

file mkdir $ROUTE_ECO_REPORT_DIR

if {![file exists $ICC2_LIB_DIR]} {
  puts "ERROR: Missing ICC2 library: $ICC2_LIB_DIR"
  exit 1
}

open_lib $ICC2_LIB_DIR
open_block -edit $ROUTE_ECO_INPUT_BLOCK

set_voltage $DEFAULT_VOLTAGE

set_ignored_layers \
  -min_routing_layer M1 \
  -max_routing_layer M8

# Refresh DRC data, then let ECO routing reroute any nets needed to fix route DRC.
check_routes > $ROUTE_ECO_REPORT_DIR/check_routes.pre.rpt

route_eco \
  -max_detail_route_iterations 200 \
  -reroute any_nets \
  -reuse_existing_global_route true

save_block -as $ROUTE_ECO_OUTPUT_BLOCK
save_lib

check_routes > $ROUTE_ECO_REPORT_DIR/check_routes.post.rpt
report_qor > $ROUTE_ECO_REPORT_DIR/qor.rpt
report_timing -delay_type max -max_paths 20 > $ROUTE_ECO_REPORT_DIR/timing.max.rpt
report_timing -delay_type min -max_paths 20 > $ROUTE_ECO_REPORT_DIR/timing.min.rpt
check_legality > $ROUTE_ECO_REPORT_DIR/check_legality.rpt

check_pg_connectivity \
  -nets [get_nets {VDD VSS}] \
  -write_connectivity_file $ROUTE_ECO_REPORT_DIR/pg_connectivity_detail.rpt \
  > $ROUTE_ECO_REPORT_DIR/pg_connectivity.rpt

check_pg_drc \
  -nets [get_nets {VDD VSS}] \
  -no_gui \
  -output $ROUTE_ECO_REPORT_DIR/pg_drc.rpt

save_lib

exit
