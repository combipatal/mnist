################################################################################
# Targeted local-route probe for residual M1 Off-grid DRC.
#
# Opens a routed block, enables extra off-grid pin tracks, removes detail route
# only for selected signal nets, reroutes only those nets, and reports DRC.
# By default this is report-only and does not save.
################################################################################

source 4_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set DEBUG_REPORT_DIR $PROJECT_ROOT/4_Backend_ICC2/4_Report/06_route_local_pintrack
if {[info exists ::env(LOCAL_ROUTE_REPORT_DIR)] && $::env(LOCAL_ROUTE_REPORT_DIR) ne ""} {
  set DEBUG_REPORT_DIR $::env(LOCAL_ROUTE_REPORT_DIR)
}
file mkdir $DEBUG_REPORT_DIR

set LOCAL_ROUTE_INPUT_BLOCK route_eco_offgrid1
if {[info exists ::env(LOCAL_ROUTE_INPUT_BLOCK)] && $::env(LOCAL_ROUTE_INPUT_BLOCK) ne ""} {
  set LOCAL_ROUTE_INPUT_BLOCK $::env(LOCAL_ROUTE_INPUT_BLOCK)
}

set LOCAL_ROUTE_OUTPUT_BLOCK route_local_pintrack1
if {[info exists ::env(LOCAL_ROUTE_OUTPUT_BLOCK)] && $::env(LOCAL_ROUTE_OUTPUT_BLOCK) ne ""} {
  set LOCAL_ROUTE_OUTPUT_BLOCK $::env(LOCAL_ROUTE_OUTPUT_BLOCK)
}

set LOCAL_ROUTE_TARGET_NETS {ZBUF_832_2538 ZBUF_714_1050 ZBUF_851_152 n143522}
if {[info exists ::env(LOCAL_ROUTE_TARGET_NETS)] && $::env(LOCAL_ROUTE_TARGET_NETS) ne ""} {
  set LOCAL_ROUTE_TARGET_NETS $::env(LOCAL_ROUTE_TARGET_NETS)
}

set LOCAL_ROUTE_ITERATIONS 120
if {[info exists ::env(LOCAL_ROUTE_ITERATIONS)] && $::env(LOCAL_ROUTE_ITERATIONS) ne ""} {
  set LOCAL_ROUTE_ITERATIONS $::env(LOCAL_ROUTE_ITERATIONS)
}

set LOCAL_ROUTE_EXTRA_OFFGRID_PIN_TRACKS true
if {[info exists ::env(LOCAL_ROUTE_EXTRA_OFFGRID_PIN_TRACKS)] && $::env(LOCAL_ROUTE_EXTRA_OFFGRID_PIN_TRACKS) ne ""} {
  set LOCAL_ROUTE_EXTRA_OFFGRID_PIN_TRACKS $::env(LOCAL_ROUTE_EXTRA_OFFGRID_PIN_TRACKS)
}

set LOCAL_ROUTE_CONNECT_WITHIN_PINS ""
if {[info exists ::env(LOCAL_ROUTE_CONNECT_WITHIN_PINS)] && $::env(LOCAL_ROUTE_CONNECT_WITHIN_PINS) ne ""} {
  set LOCAL_ROUTE_CONNECT_WITHIN_PINS $::env(LOCAL_ROUTE_CONNECT_WITHIN_PINS)
}

set LOCAL_ROUTE_SAVE 0
if {[info exists ::env(LOCAL_ROUTE_SAVE)] && $::env(LOCAL_ROUTE_SAVE) ne ""} {
  set LOCAL_ROUTE_SAVE $::env(LOCAL_ROUTE_SAVE)
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

proc parse_check_routes {file_name} {
  set result [dict create total NA open_nets NA diff_net_spacing 0 less_than_min_area 0 needs_fat_contact 0 off_grid 0 same_net_spacing 0 short 0 connection_not_within_pin 0]
  if {![file exists $file_name]} {
    return $result
  }

  set fh [open $file_name r]
  while {[gets $fh line] >= 0} {
    if {[regexp {Total number of open nets = *([0-9]+)} $line -> count]} {
      dict set result open_nets $count
    } elseif {[regexp {TOTAL VIOLATIONS = *([0-9]+)} $line -> count]} {
      dict set result total $count
    } elseif {[regexp {Diff net spacing : *([0-9]+)} $line -> count]} {
      dict set result diff_net_spacing $count
    } elseif {[regexp {Less than minimum area : *([0-9]+)} $line -> count]} {
      dict set result less_than_min_area $count
    } elseif {[regexp {Needs fat contact : *([0-9]+)} $line -> count]} {
      dict set result needs_fat_contact $count
    } elseif {[regexp {Off-grid : *([0-9]+)} $line -> count]} {
      dict set result off_grid $count
    } elseif {[regexp {Same net spacing : *([0-9]+)} $line -> count]} {
      dict set result same_net_spacing $count
    } elseif {[regexp {Short : *([0-9]+)} $line -> count]} {
      dict set result short $count
    } elseif {[regexp {Connection not within pin : *([0-9]+)} $line -> count]} {
      dict set result connection_not_within_pin $count
    } elseif {[regexp {Total number of DRCs = *([0-9]+)} $line -> count]} {
      dict set result total $count
    }
  }
  close $fh

  return $result
}

proc write_summary {file_name target_nets before after after_remove option_status save_status} {
  set fh [open $file_name w]
  puts $fh "target_nets\toption_status\tsave_status\tstage\ttotal\topen_nets\tdiff_net_spacing\tless_than_min_area\tneeds_fat_contact\toff_grid\tsame_net_spacing\tshort\tconnection_not_within_pin"
  foreach stage {before after_remove after} data [list $before $after_remove $after] {
    puts $fh "$target_nets\t$option_status\t$save_status\t$stage\t[dict get $data total]\t[dict get $data open_nets]\t[dict get $data diff_net_spacing]\t[dict get $data less_than_min_area]\t[dict get $data needs_fat_contact]\t[dict get $data off_grid]\t[dict get $data same_net_spacing]\t[dict get $data short]\t[dict get $data connection_not_within_pin]"
  }
  close $fh
}

proc write_drc_reports {report_dir prefix} {
  set drc_data [get_drc_error_data -all -quiet zroute.err]
  if {[sizeof_collection $drc_data] == 0} {
    set fh [open $report_dir/${prefix}.drc.note w]
    puts $fh "No zroute.err DRC error data was created."
    close $fh
    return
  }

  set opened_data [open_drc_error_data $drc_data]
  if {[sizeof_collection $opened_data] > 0} {
    set drc_data $opened_data
  }

  redirect -file $report_dir/${prefix}.drc.error_type.rpt {
    report_drc_error -error_data $drc_data -report_type error_type -nosplit
  }

  redirect -file $report_dir/${prefix}.drc.error_layer.rpt {
    report_drc_error -error_data $drc_data -report_type error_layer -nosplit
  }

  redirect -file $report_dir/${prefix}.drc.matrix.rpt {
    report_drc_error -error_data $drc_data -report_type matrix -nosplit
  }

  redirect -file $report_dir/${prefix}.drc.detailed.rpt {
    report_drc_error -error_data $drc_data -report_type detailed -nosplit
  }

  set all_out [open $report_dir/${prefix}.drc.errors.tsv w]
  set offgrid_out [open $report_dir/${prefix}.drc.offgrid.tsv w]
  set header "id\ttype_name\terror_class\tlayers\tbbox\tcenter\tobjects\tshape\tbrief_info\tverbose_info\tstatus"
  puts $all_out $header
  puts $offgrid_out $header

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

  close $all_out
  close $offgrid_out
}

puts "LOCAL_PINTRACK lib=$ICC2_LIB_DIR"
puts "LOCAL_PINTRACK input_block=$LOCAL_ROUTE_INPUT_BLOCK"
puts "LOCAL_PINTRACK output_block=$LOCAL_ROUTE_OUTPUT_BLOCK"
puts "LOCAL_PINTRACK target_nets=$LOCAL_ROUTE_TARGET_NETS"
puts "LOCAL_PINTRACK extra_offgrid_pin_tracks=$LOCAL_ROUTE_EXTRA_OFFGRID_PIN_TRACKS"
puts "LOCAL_PINTRACK connect_within_pins=$LOCAL_ROUTE_CONNECT_WITHIN_PINS"
puts "LOCAL_PINTRACK report_dir=$DEBUG_REPORT_DIR"

open_lib $ICC2_LIB_DIR
open_block -edit $LOCAL_ROUTE_INPUT_BLOCK

set_voltage $DEFAULT_VOLTAGE

set_ignored_layers \
  -min_routing_layer M1 \
  -max_routing_layer M8

set option_status {}
if {$LOCAL_ROUTE_EXTRA_OFFGRID_PIN_TRACKS ne ""} {
  if {[catch {
    set_app_options -name route.detail.generate_extra_off_grid_pin_tracks -value $LOCAL_ROUTE_EXTRA_OFFGRID_PIN_TRACKS
  } opt_msg]} {
    lappend option_status "extra_pin_tracks_error:$opt_msg"
  } else {
    lappend option_status "extra_pin_tracks=$LOCAL_ROUTE_EXTRA_OFFGRID_PIN_TRACKS"
  }
}

if {$LOCAL_ROUTE_CONNECT_WITHIN_PINS ne ""} {
  set connect_within_pins_value [list $LOCAL_ROUTE_CONNECT_WITHIN_PINS]
  if {[catch {
    set_app_options -name route.common.connect_within_pins_by_layer_name -value $connect_within_pins_value
  } opt_msg]} {
    lappend option_status "connect_within_pins_error:$opt_msg"
  } else {
    lappend option_status "connect_within_pins=$connect_within_pins_value"
  }
}

if {[llength $option_status] == 0} {
  set option_status no_options_set
} else {
  set option_status [join $option_status ";"]
}

redirect -file $DEBUG_REPORT_DIR/app_options.rpt {
  report_app_options route.detail.generate_extra_off_grid_pin_tracks
  if {$LOCAL_ROUTE_CONNECT_WITHIN_PINS ne ""} {
    report_app_options route.common.connect_within_pins_by_layer_name
  }
}

redirect -file $DEBUG_REPORT_DIR/check_routes.before.rpt {
  check_routes
}
set before [parse_check_routes $DEBUG_REPORT_DIR/check_routes.before.rpt]

set target_nets [get_nets -quiet $LOCAL_ROUTE_TARGET_NETS]
set nf [open $DEBUG_REPORT_DIR/target_nets.rpt w]
foreach net_name $LOCAL_ROUTE_TARGET_NETS {
  puts $nf $net_name
}
close $nf

remove_routes -nets $target_nets -detail_route

redirect -file $DEBUG_REPORT_DIR/check_routes.after_remove.rpt {
  check_routes
}
set after_remove [parse_check_routes $DEBUG_REPORT_DIR/check_routes.after_remove.rpt]

route_eco \
  -nets $target_nets \
  -max_detail_route_iterations $LOCAL_ROUTE_ITERATIONS \
  -reroute modified_nets_first_then_others \
  -reuse_existing_global_route false \
  -utilize_dangling_wires true

redirect -file $DEBUG_REPORT_DIR/check_routes.after.rpt {
  check_routes
}
set after [parse_check_routes $DEBUG_REPORT_DIR/check_routes.after.rpt]
write_drc_reports $DEBUG_REPORT_DIR after

set save_status no_save
if {$LOCAL_ROUTE_SAVE} {
  redirect -file $DEBUG_REPORT_DIR/qor.rpt {
    report_qor
  }
  redirect -file $DEBUG_REPORT_DIR/check_legality.rpt {
    check_legality
  }
  check_pg_connectivity \
    -nets [get_nets {VDD VSS}] \
    -write_connectivity_file $DEBUG_REPORT_DIR/pg_connectivity_detail.rpt \
    > $DEBUG_REPORT_DIR/pg_connectivity.rpt
  check_pg_drc \
    -nets [get_nets {VDD VSS}] \
    -no_gui \
    -output $DEBUG_REPORT_DIR/pg_drc.rpt
  save_block -as $LOCAL_ROUTE_OUTPUT_BLOCK
  save_lib
  set save_status saved
}

write_summary $DEBUG_REPORT_DIR/summary.tsv $LOCAL_ROUTE_TARGET_NETS $before $after $after_remove $option_status $save_status

puts "LOCAL_PINTRACK RESULT before_total=[dict get $before total] before_open=[dict get $before open_nets] after_total=[dict get $after total] after_open=[dict get $after open_nets] after_off_grid=[dict get $after off_grid] after_short=[dict get $after short] after_conn_not_within_pin=[dict get $after connection_not_within_pin]"
puts "LOCAL_PINTRACK NOTE=$save_status"

exit
