################################################################################
# Learning-baseline GDS stream-out from the active post-route ICC2 block.
#
# This script does not edit or save the design. It exports a GDS for learning
# handoff practice and records the inputs used for stream-out.
################################################################################

source 4_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set GDS_INPUT_BLOCK route_a20_eopen4
if {[info exists ::env(GDS_INPUT_BLOCK)] && $::env(GDS_INPUT_BLOCK) ne ""} {
  set GDS_INPUT_BLOCK $::env(GDS_INPUT_BLOCK)
}

set GDS_OUTPUT_DIR $PROJECT_ROOT/4_Backend_ICC2/2_Output/08_gds
if {[info exists ::env(GDS_OUTPUT_DIR)] && $::env(GDS_OUTPUT_DIR) ne ""} {
  set GDS_OUTPUT_DIR $::env(GDS_OUTPUT_DIR)
}

set GDS_REPORT_DIR $PROJECT_ROOT/4_Backend_ICC2/4_Report/08_gds
if {[info exists ::env(GDS_REPORT_DIR)] && $::env(GDS_REPORT_DIR) ne ""} {
  set GDS_REPORT_DIR $::env(GDS_REPORT_DIR)
}

set GDS_LAYER_MAP $SAED32_ROOT/tech/milkyway/saed32nm_1p9m_gdsout_mw.map
if {[info exists ::env(GDS_LAYER_MAP)] && $::env(GDS_LAYER_MAP) ne ""} {
  set GDS_LAYER_MAP $::env(GDS_LAYER_MAP)
}

set GDS_MERGE_FILE $SAED32_ROOT/lib/stdcell_rvt/gds/saed32nm_rvt_oa.gds
if {[info exists ::env(GDS_MERGE_FILE)] && $::env(GDS_MERGE_FILE) ne ""} {
  set GDS_MERGE_FILE $::env(GDS_MERGE_FILE)
}

file mkdir $GDS_OUTPUT_DIR
file mkdir $GDS_REPORT_DIR

if {![file exists $ICC2_LIB_DIR]} {
  puts "ERROR: Missing ICC2 library: $ICC2_LIB_DIR"
  exit 1
}
if {![file exists $GDS_LAYER_MAP]} {
  puts "ERROR: Missing GDS layer map: $GDS_LAYER_MAP"
  exit 1
}
if {![file exists $GDS_MERGE_FILE]} {
  puts "ERROR: Missing standard-cell GDS merge file: $GDS_MERGE_FILE"
  exit 1
}

set GDS_OUTPUT_FILE $GDS_OUTPUT_DIR/nn_top.route_a20_eopen4.learning.gds
set CELL_SOURCE_REPORT $GDS_REPORT_DIR/gds_cell_source.rpt
set VERBOSE_CELL_SOURCE_REPORT $GDS_REPORT_DIR/gds_cell_source.verbose.rpt
set MANIFEST_FILE $GDS_REPORT_DIR/stream_out_manifest.txt

puts "GDS lib=$ICC2_LIB_DIR"
puts "GDS input_block=$GDS_INPUT_BLOCK"
puts "GDS output_file=$GDS_OUTPUT_FILE"
puts "GDS layer_map=$GDS_LAYER_MAP"
puts "GDS merge_file=$GDS_MERGE_FILE"

open_lib $ICC2_LIB_DIR
open_block $GDS_INPUT_BLOCK
current_block $GDS_INPUT_BLOCK

set_voltage $DEFAULT_VOLTAGE

connect_pg_net -net VDD [get_pins -hierarchical -quiet */VDD]
connect_pg_net -net VSS [get_pins -hierarchical -quiet */VSS]

redirect -file $GDS_REPORT_DIR/design_physical.rpt {
  report_design -physical
}

redirect -file $GDS_REPORT_DIR/check_routes.rpt {
  check_routes
}

write_gds \
  -design $GDS_INPUT_BLOCK \
  -hierarchy design_lib \
  -long_names \
  -layer_map $GDS_LAYER_MAP \
  -layer_map_format icc_default \
  -merge_files $GDS_MERGE_FILE \
  -output_pin all \
  -report_cell_source $CELL_SOURCE_REPORT \
  -verbose_report_cell_source $VERBOSE_CELL_SOURCE_REPORT \
  $GDS_OUTPUT_FILE

set gds_size [file size $GDS_OUTPUT_FILE]
set fh [open $MANIFEST_FILE w]
puts $fh "stage: ICC2 learning GDS stream-out"
puts $fh "top: $TOP_NAME"
puts $fh "input_block: $ICC2_LIB_DIR:$GDS_INPUT_BLOCK.design"
puts $fh "output_gds: $GDS_OUTPUT_FILE"
puts $fh "output_gds_size_bytes: $gds_size"
puts $fh "layer_map: $GDS_LAYER_MAP"
puts $fh "layer_map_format: icc_default"
puts $fh "hierarchy: design_lib"
puts $fh "merge_file: $GDS_MERGE_FILE"
puts $fh "report_cell_source: $CELL_SOURCE_REPORT"
puts $fh "verbose_report_cell_source: $VERBOSE_CELL_SOURCE_REPORT"
puts $fh "design_physical_report: $GDS_REPORT_DIR/design_physical.rpt"
puts $fh "check_routes_report: $GDS_REPORT_DIR/check_routes.rpt"
puts $fh "note: Learning artifact only. Not a signoff/tapeout declaration; antenna rules remain unavailable."
close $fh

puts "GDS output_size_bytes=$gds_size"
puts "GDS DONE"
exit
