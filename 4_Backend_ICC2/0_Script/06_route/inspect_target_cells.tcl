################################################################################
# Debug-only target cell/net inspector.
#
# Opens a block and reports selected cell, pin, net, route shape, and via
# attributes. This script does not modify or save the design.
################################################################################

source 4_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set TARGET_INPUT_BLOCK route_eco_offgrid1
if {[info exists ::env(TARGET_INPUT_BLOCK)] && $::env(TARGET_INPUT_BLOCK) ne ""} {
  set TARGET_INPUT_BLOCK $::env(TARGET_INPUT_BLOCK)
}

set TARGET_CELLS {U77942}
if {[info exists ::env(TARGET_CELLS)] && $::env(TARGET_CELLS) ne ""} {
  set TARGET_CELLS $::env(TARGET_CELLS)
}

set TARGET_NETS {n143522}
if {[info exists ::env(TARGET_NETS)] && $::env(TARGET_NETS) ne ""} {
  set TARGET_NETS $::env(TARGET_NETS)
}

set TARGET_MARGIN 0.60
if {[info exists ::env(TARGET_MARGIN)] && $::env(TARGET_MARGIN) ne ""} {
  set TARGET_MARGIN $::env(TARGET_MARGIN)
}

set DEBUG_REPORT_DIR $PROJECT_ROOT/4_Backend_ICC2/4_Report/06_route_target_cells
if {[info exists ::env(TARGET_REPORT_DIR)] && $::env(TARGET_REPORT_DIR) ne ""} {
  set DEBUG_REPORT_DIR $::env(TARGET_REPORT_DIR)
}
file mkdir $DEBUG_REPORT_DIR

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

proc dump_object_row {fh label obj extra} {
  set name [names_or_na $obj]
  set class [attr_or_na $obj object_class]
  set bbox [attr_or_na $obj bbox]
  set ref_name [attr_or_na $obj ref_name]
  set lib_cell [attr_or_na $obj lib_cell]
  set origin [attr_or_na $obj origin]
  set orientation [attr_or_na $obj orientation]
  set physical_status [attr_or_na $obj physical_status]
  set layer [attr_or_na $obj layer_name]
  set net [attr_or_na $obj net]
  set net_name [names_or_na $net]
  set shape_use [attr_or_na $obj shape_use]
  set via_def [attr_or_na $obj via_def_name]
  puts $fh "$label\t$name\t$class\t$bbox\t$ref_name\t$lib_cell\t$origin\t$orientation\t$physical_status\t$layer\t$net_name\t$shape_use\t$via_def\t$extra"
}

puts "TARGET_CONTEXT lib=$ICC2_LIB_DIR"
puts "TARGET_CONTEXT block=$TARGET_INPUT_BLOCK"
puts "TARGET_CONTEXT cells=$TARGET_CELLS"
puts "TARGET_CONTEXT nets=$TARGET_NETS"
puts "TARGET_CONTEXT report_dir=$DEBUG_REPORT_DIR"

open_lib $ICC2_LIB_DIR
open_block $TARGET_INPUT_BLOCK
set_voltage $DEFAULT_VOLTAGE

set fh [open $DEBUG_REPORT_DIR/target_context.tsv w]
puts $fh "label\tname\tclass\tbbox\tref_name\tlib_cell\torigin\torientation\tphysical_status\tlayer\tnet\tshape_use\tvia_def\textra"

foreach_in_collection cell [get_cells -quiet $TARGET_CELLS] {
  dump_object_row $fh cell $cell ""

  foreach_in_collection pin [get_pins -quiet -of_objects $cell] {
    dump_object_row $fh cell_pin $pin "cell=[names_or_na $cell]"
  }

  set cell_bbox [attr_or_na $cell bbox]
  if {$cell_bbox ne "NA"} {
    set near_area [expand_bbox $cell_bbox $TARGET_MARGIN]

    foreach_in_collection near_cell [get_cells -quiet -intersect $near_area] {
      dump_object_row $fh near_cell $near_cell "target_cell=[names_or_na $cell]"
    }
    foreach_in_collection near_pin [get_pins -quiet -intersect $near_area] {
      dump_object_row $fh near_pin $near_pin "target_cell=[names_or_na $cell]"
    }
    foreach_in_collection near_shape [get_shapes -quiet -intersect $near_area] {
      dump_object_row $fh near_shape $near_shape "target_cell=[names_or_na $cell]"
    }
    foreach_in_collection near_via [get_vias -quiet -intersect $near_area] {
      dump_object_row $fh near_via $near_via "target_cell=[names_or_na $cell]"
    }
  }
}

foreach_in_collection net [get_nets -quiet $TARGET_NETS] {
  dump_object_row $fh net $net ""
  foreach_in_collection pin [get_pins -quiet -of_objects $net] {
    dump_object_row $fh net_pin $pin "net=[names_or_na $net]"
  }
}

close $fh

puts "TARGET_CONTEXT DONE"
puts "TARGET_CONTEXT NOTE=no save_block/save_lib executed"

exit
