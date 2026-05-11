################################################################################
# Read-only scanner for PG ladder candidate X locations.
#
# Counts non-PG routing shapes/vias around each floating rail at candidate X
# locations before running destructive create_pg_vias probes.
################################################################################

source 4_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set PG_LADDER_SCAN_INPUT_BLOCK route_seq_size_swap_dff2_oa1_move_u77942_xp152_pintrack
if {[info exists ::env(PG_LADDER_SCAN_INPUT_BLOCK)] && $::env(PG_LADDER_SCAN_INPUT_BLOCK) ne ""} {
  set PG_LADDER_SCAN_INPUT_BLOCK $::env(PG_LADDER_SCAN_INPUT_BLOCK)
}

set PG_LADDER_SCAN_REPORT_DIR $PROJECT_ROOT/4_Backend_ICC2/4_Report/03_powerplan_pg_ladder_scan
if {[info exists ::env(PG_LADDER_SCAN_REPORT_DIR)] && $::env(PG_LADDER_SCAN_REPORT_DIR) ne ""} {
  set PG_LADDER_SCAN_REPORT_DIR $::env(PG_LADDER_SCAN_REPORT_DIR)
}

set PG_LADDER_SCAN_XS {10.0 20.0 70.0 90.0 110.0 130.0 150.0 170.0 190.0 210.0 230.0 250.0 270.0 290.0}
if {[info exists ::env(PG_LADDER_SCAN_XS)] && $::env(PG_LADDER_SCAN_XS) ne ""} {
  set PG_LADDER_SCAN_XS $::env(PG_LADDER_SCAN_XS)
}

set PG_LADDER_SCAN_HALF_BOX 0.25
if {[info exists ::env(PG_LADDER_SCAN_HALF_BOX)] && $::env(PG_LADDER_SCAN_HALF_BOX) ne ""} {
  set PG_LADDER_SCAN_HALF_BOX $::env(PG_LADDER_SCAN_HALF_BOX)
}

set PG_LADDER_SCAN_LAYERS {M2 M3 M4 M5 M6 M7}
if {[info exists ::env(PG_LADDER_SCAN_LAYERS)] && $::env(PG_LADDER_SCAN_LAYERS) ne ""} {
  set PG_LADDER_SCAN_LAYERS $::env(PG_LADDER_SCAN_LAYERS)
}

set PG_LADDER_SCAN_SHAPES {
  PATH_11_483 PATH_11_507 PATH_11_531 PATH_11_555 PATH_11_579 PATH_11_603 PATH_11_627
}
if {[info exists ::env(PG_LADDER_SCAN_SHAPES)] && $::env(PG_LADDER_SCAN_SHAPES) ne ""} {
  set PG_LADDER_SCAN_SHAPES $::env(PG_LADDER_SCAN_SHAPES)
}

file mkdir $PG_LADDER_SCAN_REPORT_DIR

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

proc bbox_center_y {bbox} {
  set ll [lindex $bbox 0]
  set ur [lindex $bbox 1]
  return [expr {([lindex $ll 1] + [lindex $ur 1]) / 2.0}]
}

proc point_bbox {x y half_box} {
  return [list [list [expr {$x - $half_box}] [expr {$y - $half_box}]] [list [expr {$x + $half_box}] [expr {$y + $half_box}]]]
}

proc is_pg_net {net_name} {
  return [expr {$net_name eq "VDD" || $net_name eq "VSS"}]
}

proc bump_count {array_name key} {
  upvar $array_name counts
  if {![info exists counts($key)]} {
    set counts($key) 0
  }
  incr counts($key)
}

proc counts_string {array_name layers} {
  upvar $array_name counts
  set items {}
  foreach layer $layers {
    if {[info exists counts($layer)]} {
      lappend items "$layer=$counts($layer)"
    } else {
      lappend items "$layer=0"
    }
  }
  return [join $items ","]
}

if {![file exists $ICC2_LIB_DIR]} {
  puts "ERROR: Missing ICC2 library: $ICC2_LIB_DIR"
  exit 1
}

puts "PG_LADDER_SCAN lib=$ICC2_LIB_DIR"
puts "PG_LADDER_SCAN input_block=$PG_LADDER_SCAN_INPUT_BLOCK"
puts "PG_LADDER_SCAN report_dir=$PG_LADDER_SCAN_REPORT_DIR"
puts "PG_LADDER_SCAN xs=$PG_LADDER_SCAN_XS half_box=$PG_LADDER_SCAN_HALF_BOX"

open_lib $ICC2_LIB_DIR
open_block $PG_LADDER_SCAN_INPUT_BLOCK
set_voltage $DEFAULT_VOLTAGE

set detail_fh [open $PG_LADDER_SCAN_REPORT_DIR/candidate_details.tsv w]
set summary_fh [open $PG_LADDER_SCAN_REPORT_DIR/candidate_summary.tsv w]
puts $detail_fh "x\tshape\tnet\ty\tbbox\tobject_class\tobject_type\tobject_name\tobject_layer\tobject_net\tobject_bbox"
puts $summary_fh "x\tshapes_checked\tpg_shape_count\tpg_shape_layers\tpg_via_count\tpg_via_defs\tsignal_shape_count\tsignal_shape_layers\tsignal_via_count\tsignal_via_defs\tstatus"

foreach x $PG_LADDER_SCAN_XS {
  array unset pg_shape_counts
  array unset pg_via_counts
  array unset shape_counts
  array unset via_counts
  set pg_shape_count 0
  set pg_via_count 0
  set signal_shape_count 0
  set signal_via_count 0
  set shapes_checked 0

  foreach shape_name $PG_LADDER_SCAN_SHAPES {
    set rail [get_shapes -quiet $shape_name]
    if {[sizeof_collection $rail] == 0} {
      puts $detail_fh "$x\t$shape_name\tNA\tNA\tNA\tmissing\tmissing\tNA\tNA\tNA\tNA"
      continue
    }

    incr shapes_checked
    set net_name [names_or_na [attr_or_na $rail net]]
    set rail_bbox [attr_or_na $rail bbox]
    set y [bbox_center_y $rail_bbox]
    set scan_bbox [point_bbox $x $y $PG_LADDER_SCAN_HALF_BOX]

    foreach_in_collection shape [get_shapes -quiet -intersect $scan_bbox] {
      set object_net [names_or_na [attr_or_na $shape net]]
      set object_layer [attr_or_na $shape layer_name]
      if {[lsearch -exact $PG_LADDER_SCAN_LAYERS $object_layer] < 0} {
        continue
      }
      if {[is_pg_net $object_net]} {
        incr pg_shape_count
        bump_count pg_shape_counts $object_layer
        puts $detail_fh "$x\t$shape_name\t$net_name\t$y\t$scan_bbox\tpg\tshape\t[names_or_na $shape]\t$object_layer\t$object_net\t[attr_or_na $shape bbox]"
      } else {
        incr signal_shape_count
        bump_count shape_counts $object_layer
        puts $detail_fh "$x\t$shape_name\t$net_name\t$y\t$scan_bbox\tsignal\tshape\t[names_or_na $shape]\t$object_layer\t$object_net\t[attr_or_na $shape bbox]"
      }
    }

    foreach_in_collection via [get_vias -quiet -intersect $scan_bbox] {
      set object_net [names_or_na [attr_or_na $via net]]
      set via_def [attr_or_na $via via_def_name]
      if {[is_pg_net $object_net]} {
        incr pg_via_count
        bump_count pg_via_counts $via_def
        puts $detail_fh "$x\t$shape_name\t$net_name\t$y\t$scan_bbox\tpg\tvia\t[names_or_na $via]\t$via_def\t$object_net\t[attr_or_na $via bbox]"
      } else {
        incr signal_via_count
        bump_count via_counts $via_def
        puts $detail_fh "$x\t$shape_name\t$net_name\t$y\t$scan_bbox\tsignal\tvia\t[names_or_na $via]\t$via_def\t$object_net\t[attr_or_na $via bbox]"
      }
    }
  }

  set status candidate
  if {$signal_shape_count == 0 && $signal_via_count == 0} {
    set status no_non_pg_objects
  }

  puts $summary_fh "$x\t$shapes_checked\t$pg_shape_count\t[counts_string pg_shape_counts $PG_LADDER_SCAN_LAYERS]\t$pg_via_count\t[array get pg_via_counts]\t$signal_shape_count\t[counts_string shape_counts $PG_LADDER_SCAN_LAYERS]\t$signal_via_count\t[array get via_counts]\t$status"
}

close $detail_fh
close $summary_fh

puts "PG_LADDER_SCAN DONE"
exit
