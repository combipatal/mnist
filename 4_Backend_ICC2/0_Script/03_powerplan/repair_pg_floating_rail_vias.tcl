################################################################################
# Targeted PG via repair for floating M1 std-cell rails.
#
# Creates M1-M2 PG vias only on named floating rail shapes, then checks route DRC
# and PG connectivity. The input block is preserved unless PG_VIA_REPAIR_SAVE=1.
################################################################################

source 4_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set PG_VIA_REPAIR_INPUT_BLOCK route
if {[info exists ::env(PG_VIA_REPAIR_INPUT_BLOCK)] && $::env(PG_VIA_REPAIR_INPUT_BLOCK) ne ""} {
  set PG_VIA_REPAIR_INPUT_BLOCK $::env(PG_VIA_REPAIR_INPUT_BLOCK)
}

set PG_VIA_REPAIR_OUTPUT_BLOCK route_pg_via12_repair1
if {[info exists ::env(PG_VIA_REPAIR_OUTPUT_BLOCK)] && $::env(PG_VIA_REPAIR_OUTPUT_BLOCK) ne ""} {
  set PG_VIA_REPAIR_OUTPUT_BLOCK $::env(PG_VIA_REPAIR_OUTPUT_BLOCK)
}

set PG_VIA_REPAIR_REPORT_DIR $PROJECT_ROOT/4_Backend_ICC2/4_Report/03_powerplan_pg_via_repair
if {[info exists ::env(PG_VIA_REPAIR_REPORT_DIR)] && $::env(PG_VIA_REPAIR_REPORT_DIR) ne ""} {
  set PG_VIA_REPAIR_REPORT_DIR $::env(PG_VIA_REPAIR_REPORT_DIR)
}

set PG_VIA_REPAIR_SAVE 0
if {[info exists ::env(PG_VIA_REPAIR_SAVE)] && $::env(PG_VIA_REPAIR_SAVE) ne ""} {
  set PG_VIA_REPAIR_SAVE $::env(PG_VIA_REPAIR_SAVE)
}

set PG_VIA_REPAIR_MARGIN 0.04
if {[info exists ::env(PG_VIA_REPAIR_MARGIN)] && $::env(PG_VIA_REPAIR_MARGIN) ne ""} {
  set PG_VIA_REPAIR_MARGIN $::env(PG_VIA_REPAIR_MARGIN)
}

set PG_VIA_REPAIR_TAG pg_via12_rail_repair
if {[info exists ::env(PG_VIA_REPAIR_TAG)] && $::env(PG_VIA_REPAIR_TAG) ne ""} {
  set PG_VIA_REPAIR_TAG $::env(PG_VIA_REPAIR_TAG)
}

set PG_VIA_REPAIR_DRC_MODE ""
if {[info exists ::env(PG_VIA_REPAIR_DRC_MODE)] && $::env(PG_VIA_REPAIR_DRC_MODE) ne ""} {
  set PG_VIA_REPAIR_DRC_MODE $::env(PG_VIA_REPAIR_DRC_MODE)
}

set PG_VIA_REPAIR_SHAPES {
  PATH_11_184 PATH_11_208 PATH_11_232 PATH_11_256 PATH_11_280 PATH_11_304 PATH_11_328
  PATH_11_483 PATH_11_507 PATH_11_531 PATH_11_555 PATH_11_579 PATH_11_603 PATH_11_627
}
if {[info exists ::env(PG_VIA_REPAIR_SHAPES)] && $::env(PG_VIA_REPAIR_SHAPES) ne ""} {
  set PG_VIA_REPAIR_SHAPES $::env(PG_VIA_REPAIR_SHAPES)
}

file mkdir $PG_VIA_REPAIR_REPORT_DIR

proc attr_or_na {object attr_name} {
  if {[catch {set value [get_attribute $object $attr_name]}]} {
    return "NA"
  }
  return $value
}

proc names_or_na {objects} {
  if {[catch {set value [get_object_name $objects]}]} {
    return "NA"
  }
  return $value
}

proc bbox_values {bbox} {
  set ll [lindex $bbox 0]
  set ur [lindex $bbox 1]
  return [list [lindex $ll 0] [lindex $ll 1] [lindex $ur 0] [lindex $ur 1]]
}

proc expand_bbox {bbox margin} {
  lassign [bbox_values $bbox] x1 y1 x2 y2
  return [list [list [expr {$x1 - $margin}] [expr {$y1 - $margin}]] [list [expr {$x2 + $margin}] [expr {$y2 + $margin}]]]
}

if {![file exists $ICC2_LIB_DIR]} {
  puts "ERROR: Missing ICC2 library: $ICC2_LIB_DIR"
  exit 1
}

puts "PG_VIA_REPAIR lib=$ICC2_LIB_DIR"
puts "PG_VIA_REPAIR input_block=$PG_VIA_REPAIR_INPUT_BLOCK"
puts "PG_VIA_REPAIR output_block=$PG_VIA_REPAIR_OUTPUT_BLOCK"
puts "PG_VIA_REPAIR report_dir=$PG_VIA_REPAIR_REPORT_DIR"
puts "PG_VIA_REPAIR save=$PG_VIA_REPAIR_SAVE"
puts "PG_VIA_REPAIR drc_mode=$PG_VIA_REPAIR_DRC_MODE"
puts "PG_VIA_REPAIR shapes=$PG_VIA_REPAIR_SHAPES"

open_lib $ICC2_LIB_DIR
open_block $PG_VIA_REPAIR_INPUT_BLOCK
set_voltage $DEFAULT_VOLTAGE

set_ignored_layers \
  -min_routing_layer M1 \
  -max_routing_layer M8

connect_pg_net -net VDD [get_pins -hierarchical -quiet */VDD]
connect_pg_net -net VSS [get_pins -hierarchical -quiet */VSS]

redirect -file $PG_VIA_REPAIR_REPORT_DIR/pg_connectivity.before.rpt {
  check_pg_connectivity \
    -nets [get_nets {VDD VSS}] \
    -write_connectivity_file $PG_VIA_REPAIR_REPORT_DIR/pg_connectivity_detail.before.rpt
}

set summary_fh [open $PG_VIA_REPAIR_REPORT_DIR/repair_shapes.tsv w]
puts $summary_fh "shape\tnet\tbbox\trepair_bbox\tstatus"

foreach shape_name $PG_VIA_REPAIR_SHAPES {
  set shape [get_shapes -quiet $shape_name]
  if {[sizeof_collection $shape] == 0} {
    puts $summary_fh "$shape_name\tNA\tNA\tNA\tmissing"
    continue
  }

  set net_name [names_or_na [attr_or_na $shape net]]
  set bbox [attr_or_na $shape bbox]
  set repair_bbox [expand_bbox $bbox $PG_VIA_REPAIR_MARGIN]
  puts $summary_fh "$shape_name\t$net_name\t$bbox\t$repair_bbox\tattempt"

  set repair_cmd [list create_pg_vias \
    -nets [list $net_name] \
    -within_bbox $repair_bbox \
    -from_layers M1 \
    -to_layers M2 \
    -via_masters default \
    -tag $PG_VIA_REPAIR_TAG \
    -show_phantom]

  if {$PG_VIA_REPAIR_DRC_MODE ne ""} {
    lappend repair_cmd -drc $PG_VIA_REPAIR_DRC_MODE
  }

  eval $repair_cmd
}

close $summary_fh

set repaired_vias [get_vias -quiet -filter "tag==$PG_VIA_REPAIR_TAG"]
set via_fh [open $PG_VIA_REPAIR_REPORT_DIR/created_vias.tsv w]
puts $via_fh "via\tnet\tbbox\tvia_def\ttag"
foreach_in_collection via $repaired_vias {
  puts $via_fh "[names_or_na $via]\t[names_or_na [attr_or_na $via net]]\t[attr_or_na $via bbox]\t[attr_or_na $via via_def_name]\t[attr_or_na $via tag]"
}
close $via_fh

redirect -file $PG_VIA_REPAIR_REPORT_DIR/check_routes.after.rpt {
  check_routes
}

redirect -file $PG_VIA_REPAIR_REPORT_DIR/pg_connectivity.after.rpt {
  check_pg_connectivity \
    -nets [get_nets {VDD VSS}] \
    -write_connectivity_file $PG_VIA_REPAIR_REPORT_DIR/pg_connectivity_detail.after.rpt
}

check_pg_drc \
  -nets [get_nets {VDD VSS}] \
  -no_gui \
  -output $PG_VIA_REPAIR_REPORT_DIR/pg_drc.after.rpt

check_legality > $PG_VIA_REPAIR_REPORT_DIR/check_legality.after.rpt
report_qor > $PG_VIA_REPAIR_REPORT_DIR/qor.after.rpt

if {$PG_VIA_REPAIR_SAVE} {
  save_block -as $PG_VIA_REPAIR_OUTPUT_BLOCK
  save_lib
}

puts "PG_VIA_REPAIR DONE"
exit
