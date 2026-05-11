################################################################################
# Read-only PG rail island inspector.
#
# Lists M1 PG rail shapes and flags rails with no same-net vias touching them.
################################################################################

source 4_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set PG_ISLAND_INPUT_BLOCK route
if {[info exists ::env(PG_ISLAND_INPUT_BLOCK)] && $::env(PG_ISLAND_INPUT_BLOCK) ne ""} {
  set PG_ISLAND_INPUT_BLOCK $::env(PG_ISLAND_INPUT_BLOCK)
}

set PG_ISLAND_REPORT_DIR $PROJECT_ROOT/4_Backend_ICC2/4_Report/03_powerplan_pg_islands
if {[info exists ::env(PG_ISLAND_REPORT_DIR)] && $::env(PG_ISLAND_REPORT_DIR) ne ""} {
  set PG_ISLAND_REPORT_DIR $::env(PG_ISLAND_REPORT_DIR)
}

set PG_ISLAND_VIA_MARGIN 0.02
if {[info exists ::env(PG_ISLAND_VIA_MARGIN)] && $::env(PG_ISLAND_VIA_MARGIN) ne ""} {
  set PG_ISLAND_VIA_MARGIN $::env(PG_ISLAND_VIA_MARGIN)
}

set PG_ISLAND_CONTEXT_MARGIN 0.20
if {[info exists ::env(PG_ISLAND_CONTEXT_MARGIN)] && $::env(PG_ISLAND_CONTEXT_MARGIN) ne ""} {
  set PG_ISLAND_CONTEXT_MARGIN $::env(PG_ISLAND_CONTEXT_MARGIN)
}

file mkdir $PG_ISLAND_REPORT_DIR

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

proc count_same_net_vias {net_name bbox margin} {
  set count 0
  set area [expand_bbox $bbox $margin]
  foreach_in_collection via [get_vias -quiet -intersect $area] {
    set via_net [names_or_na [attr_or_na $via net]]
    if {$via_net eq $net_name} {
      incr count
    }
  }
  return $count
}

proc count_intersecting_cells {bbox margin} {
  set area [expand_bbox $bbox $margin]
  return [sizeof_collection [get_cells -quiet -intersect $area]]
}

proc write_shape_context {fh rail_idx net_name rail_bbox margin} {
  set area [expand_bbox $rail_bbox $margin]
  set idx 0
  foreach_in_collection shape [get_shapes -quiet -intersect $area] {
    incr idx
    set shape_net [names_or_na [attr_or_na $shape net]]
    set layer [attr_or_na $shape layer_name]
    set bbox [attr_or_na $shape bbox]
    set shape_use [attr_or_na $shape shape_use]
    puts $fh "shape\t$rail_idx\t$idx\t[names_or_na $shape]\t$layer\t$shape_net\t$bbox\t$shape_use\tNA"
  }
  set idx 0
  foreach_in_collection via [get_vias -quiet -intersect $area] {
    incr idx
    set via_net [names_or_na [attr_or_na $via net]]
    set bbox [attr_or_na $via bbox]
    set via_def [attr_or_na $via via_def_name]
    puts $fh "via\t$rail_idx\t$idx\t[names_or_na $via]\tNA\t$via_net\t$bbox\tNA\t$via_def"
  }
}

if {![file exists $ICC2_LIB_DIR]} {
  puts "ERROR: Missing ICC2 library: $ICC2_LIB_DIR"
  exit 1
}

puts "PG_ISLAND lib=$ICC2_LIB_DIR"
puts "PG_ISLAND input_block=$PG_ISLAND_INPUT_BLOCK"
puts "PG_ISLAND report_dir=$PG_ISLAND_REPORT_DIR"

open_lib $ICC2_LIB_DIR
open_block $PG_ISLAND_INPUT_BLOCK
set_voltage $DEFAULT_VOLTAGE

set rail_fh [open $PG_ISLAND_REPORT_DIR/m1_pg_rails.tsv w]
set island_fh [open $PG_ISLAND_REPORT_DIR/m1_pg_rails_no_same_net_vias.tsv w]
set context_fh [open $PG_ISLAND_REPORT_DIR/m1_pg_rail_island_context.tsv w]
puts $rail_fh "net\tshape\tbbox\tx1\ty1\tx2\ty2\twidth\theight\tdirection\tsame_net_vias\tcells"
puts $island_fh "idx\tnet\tshape\tbbox\tx1\ty1\tx2\ty2\twidth\theight\tdirection\tsame_net_vias\tcells"
puts $context_fh "type\trail_idx\tidx\tname\tlayer\tnet\tbbox\tshape_use\tvia_def"

set island_idx 0
foreach net_name {VDD VSS} {
  set net_obj [get_nets -quiet $net_name]
  foreach_in_collection shape [get_shapes -quiet -of_objects $net_obj] {
    set layer [attr_or_na $shape layer_name]
    if {$layer ne "M1"} {
      continue
    }

    set bbox [attr_or_na $shape bbox]
    lassign [bbox_values $bbox] x1 y1 x2 y2
    set width [expr {$x2 - $x1}]
    set height [expr {$y2 - $y1}]
    set direction vertical
    if {$width >= $height} {
      set direction horizontal
    }

    set via_count [count_same_net_vias $net_name $bbox $PG_ISLAND_VIA_MARGIN]
    set cell_count [count_intersecting_cells $bbox $PG_ISLAND_CONTEXT_MARGIN]
    set row "$net_name\t[names_or_na $shape]\t$bbox\t$x1\t$y1\t$x2\t$y2\t$width\t$height\t$direction\t$via_count\t$cell_count"
    puts $rail_fh $row

    if {$via_count == 0} {
      incr island_idx
      puts $island_fh "$island_idx\t$row"
      write_shape_context $context_fh $island_idx $net_name $bbox $PG_ISLAND_CONTEXT_MARGIN
    }
  }
}

close $rail_fh
close $island_fh
close $context_fh

redirect -file $PG_ISLAND_REPORT_DIR/pg_connectivity.rpt {
  check_pg_connectivity \
    -nets [get_nets {VDD VSS}] \
    -write_connectivity_file $PG_ISLAND_REPORT_DIR/pg_connectivity_detail.rpt
}

puts "PG_ISLAND DONE"
exit
