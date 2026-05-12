################################################################################
# Insert standard-cell fillers into a copied post-route block, then stream GDS.
#
# Learning handoff step: this adds stdcell filler cells only. It does not perform
# metal fill or declare signoff/tapeout readiness.
################################################################################

source 4_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set FILL_INPUT_BLOCK route_a20_eopen4
if {[info exists ::env(FILL_INPUT_BLOCK)] && $::env(FILL_INPUT_BLOCK) ne ""} {
  set FILL_INPUT_BLOCK $::env(FILL_INPUT_BLOCK)
}

set FILL_OUTPUT_BLOCK route_a20_eopen4_fill2
if {[info exists ::env(FILL_OUTPUT_BLOCK)] && $::env(FILL_OUTPUT_BLOCK) ne ""} {
  set FILL_OUTPUT_BLOCK $::env(FILL_OUTPUT_BLOCK)
}

set FILL_REPORT_DIR $PROJECT_ROOT/4_Backend_ICC2/4_Report/08_fill_gds
if {[info exists ::env(FILL_REPORT_DIR)] && $::env(FILL_REPORT_DIR) ne ""} {
  set FILL_REPORT_DIR $::env(FILL_REPORT_DIR)
}

set GDS_OUTPUT_DIR $PROJECT_ROOT/4_Backend_ICC2/2_Output/08_fill_gds
if {[info exists ::env(GDS_OUTPUT_DIR)] && $::env(GDS_OUTPUT_DIR) ne ""} {
  set GDS_OUTPUT_DIR $::env(GDS_OUTPUT_DIR)
}

set GDS_LAYER_MAP $SAED32_ROOT/tech/milkyway/saed32nm_1p9m_gdsout_mw.map
if {[info exists ::env(GDS_LAYER_MAP)] && $::env(GDS_LAYER_MAP) ne ""} {
  set GDS_LAYER_MAP $::env(GDS_LAYER_MAP)
}

set GDS_MERGE_FILE $SAED32_ROOT/lib/stdcell_rvt/gds/saed32nm_rvt_oa.gds
if {[info exists ::env(GDS_MERGE_FILE)] && $::env(GDS_MERGE_FILE) ne ""} {
  set GDS_MERGE_FILE $::env(GDS_MERGE_FILE)
}

set FILLER_LIB_CELL_PATTERNS {
  */SHFILL128_RVT
  */SHFILL64_RVT
  */SHFILL3_RVT
  */SHFILL2_RVT
  */SHFILL1_RVT
}
if {[info exists ::env(FILLER_LIB_CELL_PATTERNS)] && $::env(FILLER_LIB_CELL_PATTERNS) ne ""} {
  set FILLER_LIB_CELL_PATTERNS $::env(FILLER_LIB_CELL_PATTERNS)
}

file mkdir $FILL_REPORT_DIR
file mkdir $GDS_OUTPUT_DIR

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

set GDS_OUTPUT_FILE $GDS_OUTPUT_DIR/nn_top.${FILL_OUTPUT_BLOCK}.learning.gds
set CELL_SOURCE_REPORT $FILL_REPORT_DIR/gds_cell_source.rpt
set VERBOSE_CELL_SOURCE_REPORT $FILL_REPORT_DIR/gds_cell_source.verbose.rpt
set MANIFEST_FILE $FILL_REPORT_DIR/fill_gds_manifest.txt

puts "FILL_GDS lib=$ICC2_LIB_DIR"
puts "FILL_GDS input_block=$FILL_INPUT_BLOCK"
puts "FILL_GDS output_block=$FILL_OUTPUT_BLOCK"
puts "FILL_GDS output_gds=$GDS_OUTPUT_FILE"
puts "FILL_GDS filler_patterns=$FILLER_LIB_CELL_PATTERNS"

open_lib $ICC2_LIB_DIR

set copy_status [catch {
  copy_block -from_block $FILL_INPUT_BLOCK -to_block $FILL_OUTPUT_BLOCK
} copy_msg]
puts "FILL_GDS copy_block_status=$copy_status message=$copy_msg"
if {$copy_status != 0} {
  error "copy_block failed. Use a new FILL_OUTPUT_BLOCK if the output block already exists: $copy_msg"
}

open_block -edit $FILL_OUTPUT_BLOCK
current_block $FILL_OUTPUT_BLOCK

set_voltage $DEFAULT_VOLTAGE

connect_pg_net -net VDD [get_pins -hierarchical -quiet */VDD]
connect_pg_net -net VSS [get_pins -hierarchical -quiet */VSS]

set filler_lib_cells [get_lib_cells -quiet $FILLER_LIB_CELL_PATTERNS]
set filler_lib_cell_count [sizeof_collection $filler_lib_cells]
puts "FILL_GDS filler_lib_cell_count=$filler_lib_cell_count"
if {$filler_lib_cell_count == 0} {
  error "No filler lib cells found from patterns: $FILLER_LIB_CELL_PATTERNS"
}

set lib_fh [open $FILL_REPORT_DIR/filler_lib_cells.rpt w]
puts $lib_fh "filler_lib_cell"
foreach_in_collection filler_lib_cell $filler_lib_cells {
  puts $lib_fh [get_object_name $filler_lib_cell]
}
close $lib_fh

set filler_cells_before [get_cells -hierarchical -quiet -filter "ref_name =~ *FILL*"]
set filler_count_before [sizeof_collection $filler_cells_before]
puts "FILL_GDS filler_count_before=$filler_count_before"

create_stdcell_fillers \
  -lib_cells $filler_lib_cells \
  -prefix FILLER

connect_pg_net -net VDD [get_pins -hierarchical -quiet */VDD]
connect_pg_net -net VSS [get_pins -hierarchical -quiet */VSS]

set filler_cells_after [get_cells -hierarchical -quiet -filter "ref_name =~ *FILL*"]
set filler_count_after [sizeof_collection $filler_cells_after]
puts "FILL_GDS filler_count_after=$filler_count_after"

set filler_fh [open $FILL_REPORT_DIR/filler_cells.rpt w]
puts $filler_fh "filler_cell\tref_name"
foreach_in_collection filler_cell $filler_cells_after {
  set cell_name [get_object_name $filler_cell]
  set ref_name [get_attribute $filler_cell ref_name]
  puts $filler_fh "$cell_name\t$ref_name"
}
close $filler_fh
redirect -file $FILL_REPORT_DIR/utilization.rpt {
  report_utilization
}
redirect -file $FILL_REPORT_DIR/design_physical.rpt {
  report_design -physical
}
redirect -file $FILL_REPORT_DIR/qor.rpt {
  report_qor
}
redirect -file $FILL_REPORT_DIR/check_legality.rpt {
  check_legality
}
redirect -file $FILL_REPORT_DIR/check_routes.rpt {
  check_routes
}
redirect -file $FILL_REPORT_DIR/pg_connectivity.rpt {
  check_pg_connectivity \
    -nets [get_nets {VDD VSS}] \
    -write_connectivity_file $FILL_REPORT_DIR/pg_connectivity_detail.rpt
}
check_pg_drc \
  -nets [get_nets {VDD VSS}] \
  -no_gui \
  -output $FILL_REPORT_DIR/pg_drc.rpt

save_block
save_lib

write_gds \
  -design $FILL_OUTPUT_BLOCK \
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
puts $fh "stage: ICC2 stdcell filler insertion plus learning GDS stream-out"
puts $fh "top: $TOP_NAME"
puts $fh "input_block: $ICC2_LIB_DIR:$FILL_INPUT_BLOCK.design"
puts $fh "output_block: $ICC2_LIB_DIR:$FILL_OUTPUT_BLOCK.design"
puts $fh "filler_lib_cell_patterns: $FILLER_LIB_CELL_PATTERNS"
puts $fh "filler_lib_cell_count: $filler_lib_cell_count"
puts $fh "filler_count_before: $filler_count_before"
puts $fh "filler_count_after: $filler_count_after"
puts $fh "output_gds: $GDS_OUTPUT_FILE"
puts $fh "output_gds_size_bytes: $gds_size"
puts $fh "layer_map: $GDS_LAYER_MAP"
puts $fh "layer_map_format: icc_default"
puts $fh "hierarchy: design_lib"
puts $fh "merge_file: $GDS_MERGE_FILE"
puts $fh "report_cell_source: $CELL_SOURCE_REPORT"
puts $fh "verbose_report_cell_source: $VERBOSE_CELL_SOURCE_REPORT"
puts $fh "utilization_report: $FILL_REPORT_DIR/utilization.rpt"
puts $fh "check_legality_report: $FILL_REPORT_DIR/check_legality.rpt"
puts $fh "check_routes_report: $FILL_REPORT_DIR/check_routes.rpt"
puts $fh "pg_connectivity_report: $FILL_REPORT_DIR/pg_connectivity.rpt"
puts $fh "pg_drc_report: $FILL_REPORT_DIR/pg_drc.rpt"
puts $fh "note: Learning artifact only. Stdcell filler inserted; metal fill/LVS/signoff DRC are not complete."
close $fh

puts "FILL_GDS output_size_bytes=$gds_size"
puts "FILL_GDS DONE"
exit
