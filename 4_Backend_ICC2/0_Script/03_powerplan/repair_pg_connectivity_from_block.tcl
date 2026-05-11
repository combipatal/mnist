################################################################################
# Debug PG connectivity repair from an existing ICC2 block.
#
# Opens an already routed/debugged block, reapplies the stored PG strategies, and
# writes route/PG reports. The input block is not saved; results are saved only
# to PG_REPAIR_OUTPUT_BLOCK when PG_REPAIR_SAVE is non-zero.
################################################################################

source 4_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set PG_REPAIR_INPUT_BLOCK route
if {[info exists ::env(PG_REPAIR_INPUT_BLOCK)] && $::env(PG_REPAIR_INPUT_BLOCK) ne ""} {
  set PG_REPAIR_INPUT_BLOCK $::env(PG_REPAIR_INPUT_BLOCK)
}

set PG_REPAIR_OUTPUT_BLOCK route_pg_repair1
if {[info exists ::env(PG_REPAIR_OUTPUT_BLOCK)] && $::env(PG_REPAIR_OUTPUT_BLOCK) ne ""} {
  set PG_REPAIR_OUTPUT_BLOCK $::env(PG_REPAIR_OUTPUT_BLOCK)
}

set PG_REPAIR_REPORT_DIR $PROJECT_ROOT/4_Backend_ICC2/4_Report/03_powerplan_pg_repair
if {[info exists ::env(PG_REPAIR_REPORT_DIR)] && $::env(PG_REPAIR_REPORT_DIR) ne ""} {
  set PG_REPAIR_REPORT_DIR $::env(PG_REPAIR_REPORT_DIR)
}

set PG_REPAIR_SAVE 0
if {[info exists ::env(PG_REPAIR_SAVE)] && $::env(PG_REPAIR_SAVE) ne ""} {
  set PG_REPAIR_SAVE $::env(PG_REPAIR_SAVE)
}

file mkdir $PG_REPAIR_REPORT_DIR

if {![file exists $ICC2_LIB_DIR]} {
  puts "ERROR: Missing ICC2 library: $ICC2_LIB_DIR"
  exit 1
}

puts "PG_REPAIR lib=$ICC2_LIB_DIR"
puts "PG_REPAIR input_block=$PG_REPAIR_INPUT_BLOCK"
puts "PG_REPAIR output_block=$PG_REPAIR_OUTPUT_BLOCK"
puts "PG_REPAIR report_dir=$PG_REPAIR_REPORT_DIR"
puts "PG_REPAIR save=$PG_REPAIR_SAVE"

open_lib $ICC2_LIB_DIR
open_block $PG_REPAIR_INPUT_BLOCK
set_voltage $DEFAULT_VOLTAGE

set_ignored_layers \
  -min_routing_layer M1 \
  -max_routing_layer M8

connect_pg_net -net VDD [get_pins -hierarchical -quiet */VDD]
connect_pg_net -net VSS [get_pins -hierarchical -quiet */VSS]

redirect -file $PG_REPAIR_REPORT_DIR/pg_connectivity.before.rpt {
  check_pg_connectivity \
    -nets [get_nets {VDD VSS}] \
    -write_connectivity_file $PG_REPAIR_REPORT_DIR/pg_connectivity_detail.before.rpt
}

redirect -file $PG_REPAIR_REPORT_DIR/pg_patterns.before.rpt {
  report_pg_patterns
}

redirect -file $PG_REPAIR_REPORT_DIR/pg_strategies.before.rpt {
  report_pg_strategies
}

catch {remove_pg_strategy_via_rules pg_repair_via_all}
set_pg_strategy_via_rule pg_repair_via_all \
  -via_rule {{intersection: all}{via_master: default}} \
  -tag pg_repair_via

# Reuse the existing baseline PG strategies. This intentionally does not remove
# current PG shapes, so the experiment is limited to reconnect/update behavior.
compile_pg \
  -strategies {stdcell_rail_strategy core_ring_strategy core_mesh_strategy} \
  -via_rule pg_repair_via_all

redirect -file $PG_REPAIR_REPORT_DIR/check_routes.after.rpt {
  check_routes
}

redirect -file $PG_REPAIR_REPORT_DIR/pg_connectivity.after.rpt {
  check_pg_connectivity \
    -nets [get_nets {VDD VSS}] \
    -write_connectivity_file $PG_REPAIR_REPORT_DIR/pg_connectivity_detail.after.rpt
}

check_pg_drc \
  -nets [get_nets {VDD VSS}] \
  -no_gui \
  -output $PG_REPAIR_REPORT_DIR/pg_drc.after.rpt

report_qor > $PG_REPAIR_REPORT_DIR/qor.after.rpt
report_utilization > $PG_REPAIR_REPORT_DIR/utilization.after.rpt

if {$PG_REPAIR_SAVE} {
  save_block -as $PG_REPAIR_OUTPUT_BLOCK
  save_lib
}

puts "PG_REPAIR DONE"
exit
