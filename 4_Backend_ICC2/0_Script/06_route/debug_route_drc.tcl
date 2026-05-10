################################################################################
# Route DRC debug report extraction for the MNIST NPU RVT-only baseline.
################################################################################

source 4_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set DEBUG_REPORT_DIR 4_Backend_ICC2/4_Report/06_route/drc_debug
file mkdir $DEBUG_REPORT_DIR

if {![file exists $ICC2_LIB_DIR]} {
  puts "ERROR: Missing ICC2 library: $ICC2_LIB_DIR"
  exit 1
}

open_lib $ICC2_LIB_DIR
open_block route

set_voltage $DEFAULT_VOLTAGE

set_ignored_layers \
  -min_routing_layer M1 \
  -max_routing_layer M8

# Re-run the same route check to refresh the ICC2 DRC error browser data.
check_routes > $DEBUG_REPORT_DIR/check_routes.recheck.rpt

set drc_data [get_drc_error_data -all zroute.err]
if {[sizeof_collection $drc_data] == 0} {
  puts "ERROR: No zroute.err DRC error data was created by check_routes."
  exit 1
}

open_drc_error_data $drc_data
set drc_data [get_drc_error_data zroute.err]

redirect -file $DEBUG_REPORT_DIR/drc_error_data.rpt {
  puts "DRC error data objects:"
  query_objects $drc_data
}

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

redirect -file $DEBUG_REPORT_DIR/drc_error_attributes.rpt {
  list_attributes -application -class drc_error
}

set out [open $DEBUG_REPORT_DIR/drc.errors.tsv w]
puts $out "id\ttype_name\tlayers\tbbox\tobjects\tactual_spacing\trequired_spacing\trequired_width\tbrief_info\tverbose_info\tstatus"
foreach_in_collection err [get_drc_errors -error_data $drc_data *] {
  set id [get_object_name $err]

  set type_name ""
  catch {set type_name [get_attribute $err type_name]}

  set layers ""
  if {![catch {set layer_objects [get_attribute $err layers]}]} {
    set layer_names {}
    foreach_in_collection layer $layer_objects {
      lappend layer_names [get_object_name $layer]
    }
    set layers [join $layer_names ","]
  }

  set bbox ""
  catch {set bbox [get_attribute $err bbox]}

  set objects ""
  if {![catch {set error_objects [get_attribute $err objects]}]} {
    set object_names {}
    foreach_in_collection object $error_objects {
      lappend object_names [get_object_name $object]
    }
    set objects [join $object_names ","]
  }

  set actual_spacing ""
  catch {set actual_spacing [get_attribute $err actual_spacing]}

  set required_spacing ""
  catch {set required_spacing [get_attribute $err required_spacing]}

  set required_width ""
  catch {set required_width [get_attribute $err required_width]}

  set brief_info ""
  catch {set brief_info [get_attribute $err brief_info]}

  set verbose_info ""
  catch {set verbose_info [get_attribute $err verbose_info]}

  set status ""
  catch {set status [get_attribute $err status]}

  puts $out "$id\t$type_name\t$layers\t$bbox\t$objects\t$actual_spacing\t$required_spacing\t$required_width\t$brief_info\t$verbose_info\t$status"
}
close $out

exit
