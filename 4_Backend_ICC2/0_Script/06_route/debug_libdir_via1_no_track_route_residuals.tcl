################################################################################
# Residual route DRC and PG debug extraction for the libdir VIA1 no-track trial.
################################################################################

source 4_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set DEBUG_REPORT_DIR $PROJECT_ROOT/4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_route/06_route_debug
if {[info exists ::env(ROUTE_DEBUG_REPORT_DIR)]} {
  set DEBUG_REPORT_DIR $::env(ROUTE_DEBUG_REPORT_DIR)
}
set DEBUG_INPUT_BLOCK route
if {[info exists ::env(ROUTE_DEBUG_INPUT_BLOCK)]} {
  set DEBUG_INPUT_BLOCK $::env(ROUTE_DEBUG_INPUT_BLOCK)
}
file mkdir $DEBUG_REPORT_DIR

if {![file exists $ICC2_LIB_DIR]} {
  puts "ERROR: Missing ICC2 library: $ICC2_LIB_DIR"
  exit 1
}

proc collection_names {objects} {
  set names {}
  foreach_in_collection object $objects {
    lappend names [get_object_name $object]
  }
  return [join $names ","]
}

proc safe_attribute {object attr} {
  set value ""
  catch {set value [get_attribute $object $attr]}
  return $value
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

open_lib $ICC2_LIB_DIR
open_block $DEBUG_INPUT_BLOCK

set_voltage $DEFAULT_VOLTAGE

set_ignored_layers \
  -min_routing_layer M1 \
  -max_routing_layer M8

set all_out [open $DEBUG_REPORT_DIR/drc.errors.tsv w]
set offgrid_out [open $DEBUG_REPORT_DIR/drc.offgrid.tsv w]
set header "id\ttype_name\terror_class\tlayers\tbbox\tcenter\tobjects\tshape\tbrief_info\tverbose_info\tstatus"
puts $all_out $header
puts $offgrid_out $header

check_routes > $DEBUG_REPORT_DIR/check_routes.recheck.rpt

set drc_data [get_drc_error_data -all -quiet zroute.err]
if {[sizeof_collection $drc_data] == 0} {
  set note_fh [open $DEBUG_REPORT_DIR/drc.note w]
  puts $note_fh "No zroute.err DRC error data was created by check_routes; this is expected when the block is route-DRC clean."
  close $note_fh
} else {
  open_drc_error_data $drc_data
  set drc_data [get_drc_error_data zroute.err]

  redirect -file $DEBUG_REPORT_DIR/drc.error_type.rpt {
    report_drc_error -error_data $drc_data -report_type error_type -nosplit
  }

  redirect -file $DEBUG_REPORT_DIR/drc.error_layer.rpt {
    report_drc_error -error_data $drc_data -report_type error_layer -nosplit
  }

  redirect -file $DEBUG_REPORT_DIR/drc.matrix.rpt {
    report_drc_error -error_data $drc_data -report_type matrix -nosplit
  }

  redirect -file $DEBUG_REPORT_DIR/drc.detailed.rpt {
    report_drc_error -error_data $drc_data -report_type detailed -nosplit
  }

  foreach_in_collection err [get_drc_errors -error_data $drc_data *] {
    set id [get_object_name $err]
    set type_name [safe_attribute $err type_name]
    set error_class [safe_attribute $err error_class]

    set layers ""
    if {![catch {set layer_objects [get_attribute $err layers]}]} {
      set layers [collection_names $layer_objects]
    }

    set bbox [safe_attribute $err bbox]
    set center [bbox_center $bbox]

    set objects ""
    if {![catch {set error_objects [get_attribute $err objects]}]} {
      set objects [collection_names $error_objects]
    }

    set shape [safe_attribute $err shape]
    set brief_info [safe_attribute $err brief_info]
    set verbose_info [safe_attribute $err verbose_info]
    set status [safe_attribute $err status]

    set line "$id\t$type_name\t$error_class\t$layers\t$bbox\t$center\t$objects\t$shape\t$brief_info\t$verbose_info\t$status"
    puts $all_out $line
    if {$type_name eq "Off-grid"} {
      puts $offgrid_out $line
    }
  }
}

close $all_out
close $offgrid_out

check_pg_connectivity \
  -nets [get_nets {VDD VSS}] \
  -write_connectivity_file $DEBUG_REPORT_DIR/pg_connectivity_detail.rpt \
  > $DEBUG_REPORT_DIR/pg_connectivity.rpt

check_pg_drc \
  -nets [get_nets {VDD VSS}] \
  -no_gui \
  -output $DEBUG_REPORT_DIR/pg_drc.rpt

exit
