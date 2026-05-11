################################################################################
# Targeted PG ladder repair for floating M1 rails overlapping M7 straps.
#
# Creates one M1-to-M7 via ladder per named floating rail at a fixed X location
# away from the existing M2 strap via stacks.
################################################################################

source 4_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set PG_LADDER_INPUT_BLOCK route
if {[info exists ::env(PG_LADDER_INPUT_BLOCK)] && $::env(PG_LADDER_INPUT_BLOCK) ne ""} {
  set PG_LADDER_INPUT_BLOCK $::env(PG_LADDER_INPUT_BLOCK)
}

set PG_LADDER_OUTPUT_BLOCK route_pg_ladder_repair1
if {[info exists ::env(PG_LADDER_OUTPUT_BLOCK)] && $::env(PG_LADDER_OUTPUT_BLOCK) ne ""} {
  set PG_LADDER_OUTPUT_BLOCK $::env(PG_LADDER_OUTPUT_BLOCK)
}

set PG_LADDER_REPORT_DIR $PROJECT_ROOT/4_Backend_ICC2/4_Report/03_powerplan_pg_ladder_repair
if {[info exists ::env(PG_LADDER_REPORT_DIR)] && $::env(PG_LADDER_REPORT_DIR) ne ""} {
  set PG_LADDER_REPORT_DIR $::env(PG_LADDER_REPORT_DIR)
}

set PG_LADDER_SAVE 0
if {[info exists ::env(PG_LADDER_SAVE)] && $::env(PG_LADDER_SAVE) ne ""} {
  set PG_LADDER_SAVE $::env(PG_LADDER_SAVE)
}

set PG_LADDER_X 50.0
if {[info exists ::env(PG_LADDER_X)] && $::env(PG_LADDER_X) ne ""} {
  set PG_LADDER_X $::env(PG_LADDER_X)
}

set PG_LADDER_HALF_BOX 0.25
if {[info exists ::env(PG_LADDER_HALF_BOX)] && $::env(PG_LADDER_HALF_BOX) ne ""} {
  set PG_LADDER_HALF_BOX $::env(PG_LADDER_HALF_BOX)
}

set PG_LADDER_VDD_X ""
if {[info exists ::env(PG_LADDER_VDD_X)] && $::env(PG_LADDER_VDD_X) ne ""} {
  set PG_LADDER_VDD_X $::env(PG_LADDER_VDD_X)
}

set PG_LADDER_VSS_X ""
if {[info exists ::env(PG_LADDER_VSS_X)] && $::env(PG_LADDER_VSS_X) ne ""} {
  set PG_LADDER_VSS_X $::env(PG_LADDER_VSS_X)
}

set PG_LADDER_VDD_HALF_BOX ""
if {[info exists ::env(PG_LADDER_VDD_HALF_BOX)] && $::env(PG_LADDER_VDD_HALF_BOX) ne ""} {
  set PG_LADDER_VDD_HALF_BOX $::env(PG_LADDER_VDD_HALF_BOX)
}

set PG_LADDER_VSS_HALF_BOX ""
if {[info exists ::env(PG_LADDER_VSS_HALF_BOX)] && $::env(PG_LADDER_VSS_HALF_BOX) ne ""} {
  set PG_LADDER_VSS_HALF_BOX $::env(PG_LADDER_VSS_HALF_BOX)
}

set PG_LADDER_SHAPE_OVERRIDES ""
if {[info exists ::env(PG_LADDER_SHAPE_OVERRIDES)] && $::env(PG_LADDER_SHAPE_OVERRIDES) ne ""} {
  set PG_LADDER_SHAPE_OVERRIDES $::env(PG_LADDER_SHAPE_OVERRIDES)
}

set PG_LADDER_TAG pg_m1_m7_ladder_repair
if {[info exists ::env(PG_LADDER_TAG)] && $::env(PG_LADDER_TAG) ne ""} {
  set PG_LADDER_TAG $::env(PG_LADDER_TAG)
}

set PG_LADDER_DRC_MODE ""
if {[info exists ::env(PG_LADDER_DRC_MODE)] && $::env(PG_LADDER_DRC_MODE) ne ""} {
  set PG_LADDER_DRC_MODE $::env(PG_LADDER_DRC_MODE)
}

set PG_LADDER_SHAPES {
  PATH_11_184 PATH_11_208 PATH_11_232 PATH_11_256 PATH_11_280 PATH_11_304 PATH_11_328
  PATH_11_483 PATH_11_507 PATH_11_531 PATH_11_555 PATH_11_579 PATH_11_603 PATH_11_627
}
if {[info exists ::env(PG_LADDER_SHAPES)] && $::env(PG_LADDER_SHAPES) ne ""} {
  set PG_LADDER_SHAPES $::env(PG_LADDER_SHAPES)
}

file mkdir $PG_LADDER_REPORT_DIR

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

proc ladder_location_for_shape {shape_name net_name default_x default_half vdd_x vss_x vdd_half vss_half shape_overrides} {
  set use_x $default_x
  set use_half $default_half

  if {$net_name eq "VDD"} {
    if {$vdd_x ne ""} {
      set use_x $vdd_x
    }
    if {$vdd_half ne ""} {
      set use_half $vdd_half
    }
  } elseif {$net_name eq "VSS"} {
    if {$vss_x ne ""} {
      set use_x $vss_x
    }
    if {$vss_half ne ""} {
      set use_half $vss_half
    }
  }

  foreach raw_entry [split $shape_overrides ";"] {
    set entry [string trim $raw_entry]
    if {$entry eq ""} {
      continue
    }
    set parts [split $entry "="]
    if {[llength $parts] != 2} {
      continue
    }
    set override_shape [string trim [lindex $parts 0]]
    if {$override_shape ne $shape_name} {
      continue
    }
    set values [split [string trim [lindex $parts 1]] ","]
    if {[llength $values] >= 1 && [string trim [lindex $values 0]] ne ""} {
      set use_x [string trim [lindex $values 0]]
    }
    if {[llength $values] >= 2 && [string trim [lindex $values 1]] ne ""} {
      set use_half [string trim [lindex $values 1]]
    }
  }

  return [list $use_x $use_half]
}

proc collection_names {objects} {
  set names {}
  foreach_in_collection object $objects {
    lappend names [get_object_name $object]
  }
  return [join $names ","]
}

proc bbox_center {bbox} {
  if {[llength $bbox] != 2} {
    return ""
  }
  set ll [lindex $bbox 0]
  set ur [lindex $bbox 1]
  if {[llength $ll] != 2 || [llength $ur] != 2} {
    return ""
  }
  set cx [expr {([lindex $ll 0] + [lindex $ur 0]) / 2.0}]
  set cy [expr {([lindex $ll 1] + [lindex $ur 1]) / 2.0}]
  return [format "%.4f,%.4f" $cx $cy]
}

if {![file exists $ICC2_LIB_DIR]} {
  puts "ERROR: Missing ICC2 library: $ICC2_LIB_DIR"
  exit 1
}

puts "PG_LADDER lib=$ICC2_LIB_DIR"
puts "PG_LADDER input_block=$PG_LADDER_INPUT_BLOCK"
puts "PG_LADDER output_block=$PG_LADDER_OUTPUT_BLOCK"
puts "PG_LADDER report_dir=$PG_LADDER_REPORT_DIR"
puts "PG_LADDER save=$PG_LADDER_SAVE"
puts "PG_LADDER x=$PG_LADDER_X half_box=$PG_LADDER_HALF_BOX drc_mode=$PG_LADDER_DRC_MODE"
puts "PG_LADDER vdd_x=$PG_LADDER_VDD_X vss_x=$PG_LADDER_VSS_X vdd_half=$PG_LADDER_VDD_HALF_BOX vss_half=$PG_LADDER_VSS_HALF_BOX"
puts "PG_LADDER shape_overrides=$PG_LADDER_SHAPE_OVERRIDES"

open_lib $ICC2_LIB_DIR
open_block $PG_LADDER_INPUT_BLOCK
set_voltage $DEFAULT_VOLTAGE

set_ignored_layers \
  -min_routing_layer M1 \
  -max_routing_layer M8

connect_pg_net -net VDD [get_pins -hierarchical -quiet */VDD]
connect_pg_net -net VSS [get_pins -hierarchical -quiet */VSS]

redirect -file $PG_LADDER_REPORT_DIR/pg_connectivity.before.rpt {
  check_pg_connectivity \
    -nets [get_nets {VDD VSS}] \
    -write_connectivity_file $PG_LADDER_REPORT_DIR/pg_connectivity_detail.before.rpt
}

set summary_fh [open $PG_LADDER_REPORT_DIR/repair_ladders.tsv w]
puts $summary_fh "shape\tnet\tshape_bbox\tladder_x\thalf_box\tladder_bbox\tstatus"

foreach shape_name $PG_LADDER_SHAPES {
  set shape [get_shapes -quiet $shape_name]
  if {[sizeof_collection $shape] == 0} {
    puts $summary_fh "$shape_name\tNA\tNA\tNA\tmissing"
    continue
  }

  set net_name [names_or_na [attr_or_na $shape net]]
  set shape_bbox [attr_or_na $shape bbox]
  set y [bbox_center_y $shape_bbox]
  lassign [ladder_location_for_shape \
    $shape_name \
    $net_name \
    $PG_LADDER_X \
    $PG_LADDER_HALF_BOX \
    $PG_LADDER_VDD_X \
    $PG_LADDER_VSS_X \
    $PG_LADDER_VDD_HALF_BOX \
    $PG_LADDER_VSS_HALF_BOX \
    $PG_LADDER_SHAPE_OVERRIDES] ladder_x ladder_half_box
  set ladder_bbox [point_bbox $ladder_x $y $ladder_half_box]
  puts $summary_fh "$shape_name\t$net_name\t$shape_bbox\t$ladder_x\t$ladder_half_box\t$ladder_bbox\tattempt"

  set ladder_cmd [list create_pg_vias \
    -nets [list $net_name] \
    -within_bbox $ladder_bbox \
    -from_layers M1 \
    -to_layers M7 \
    -via_masters default \
    -allow_parallel_objects \
    -tag $PG_LADDER_TAG \
    -show_phantom]

  if {$PG_LADDER_DRC_MODE ne ""} {
    lappend ladder_cmd -drc $PG_LADDER_DRC_MODE
  }

  eval $ladder_cmd
}

close $summary_fh

set repaired_vias [get_vias -quiet -filter "tag==$PG_LADDER_TAG"]
set via_fh [open $PG_LADDER_REPORT_DIR/created_vias.tsv w]
puts $via_fh "via\tnet\tbbox\tvia_def\ttag"
foreach_in_collection via $repaired_vias {
  puts $via_fh "[names_or_na $via]\t[names_or_na [attr_or_na $via net]]\t[attr_or_na $via bbox]\t[attr_or_na $via via_def_name]\t[attr_or_na $via tag]"
}
close $via_fh

redirect -file $PG_LADDER_REPORT_DIR/check_routes.after.rpt {
  check_routes
}

set drc_data [get_drc_error_data -all -quiet zroute.err]
if {[sizeof_collection $drc_data] == 0} {
  set note_fh [open $PG_LADDER_REPORT_DIR/drc.note w]
  puts $note_fh "No zroute.err DRC error data was created by check_routes."
  close $note_fh
} else {
  open_drc_error_data $drc_data
  set drc_data [get_drc_error_data zroute.err]

  redirect -file $PG_LADDER_REPORT_DIR/drc.error_type.rpt {
    report_drc_error -error_data $drc_data -report_type error_type -nosplit
  }

  redirect -file $PG_LADDER_REPORT_DIR/drc.error_layer.rpt {
    report_drc_error -error_data $drc_data -report_type error_layer -nosplit
  }

  redirect -file $PG_LADDER_REPORT_DIR/drc.matrix.rpt {
    report_drc_error -error_data $drc_data -report_type matrix -nosplit
  }

  redirect -file $PG_LADDER_REPORT_DIR/drc.detailed.rpt {
    report_drc_error -error_data $drc_data -report_type detailed -nosplit
  }

  set drc_fh [open $PG_LADDER_REPORT_DIR/drc.errors.tsv w]
  puts $drc_fh "id\ttype_name\terror_class\tlayers\tbbox\tcenter\tobjects\tbrief_info\tverbose_info\tstatus"
  foreach_in_collection err [get_drc_errors -error_data $drc_data *] {
    set id [get_object_name $err]
    set type_name [attr_or_na $err type_name]
    set error_class [attr_or_na $err error_class]
    set layers ""
    if {![catch {set layer_objects [get_attribute $err layers]}]} {
      set layers [collection_names $layer_objects]
    }
    set bbox [attr_or_na $err bbox]
    set center [bbox_center $bbox]
    set objects ""
    if {![catch {set error_objects [get_attribute $err objects]}]} {
      set objects [collection_names $error_objects]
    }
    set brief_info [attr_or_na $err brief_info]
    set verbose_info [attr_or_na $err verbose_info]
    set status [attr_or_na $err status]
    puts $drc_fh "$id\t$type_name\t$error_class\t$layers\t$bbox\t$center\t$objects\t$brief_info\t$verbose_info\t$status"
  }
  close $drc_fh
}

redirect -file $PG_LADDER_REPORT_DIR/pg_connectivity.after.rpt {
  check_pg_connectivity \
    -nets [get_nets {VDD VSS}] \
    -write_connectivity_file $PG_LADDER_REPORT_DIR/pg_connectivity_detail.after.rpt
}

check_pg_drc \
  -nets [get_nets {VDD VSS}] \
  -no_gui \
  -output $PG_LADDER_REPORT_DIR/pg_drc.after.rpt

check_legality > $PG_LADDER_REPORT_DIR/check_legality.after.rpt
report_qor > $PG_LADDER_REPORT_DIR/qor.after.rpt

if {$PG_LADDER_SAVE} {
  save_block -as $PG_LADDER_OUTPUT_BLOCK
  save_lib
}

puts "PG_LADDER DONE"
exit
