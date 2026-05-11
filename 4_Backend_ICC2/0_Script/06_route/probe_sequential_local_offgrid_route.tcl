################################################################################
# Sequential targeted local-route probe for residual M1 Off-grid DRC.
#
# Opens a routed block, enables extra off-grid pin tracks, then reroutes one
# small target-net set at a time. This keeps the successful single-net behavior
# visible instead of removing all residual nets at once.
################################################################################

source 4_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl

set DEBUG_REPORT_DIR $PROJECT_ROOT/4_Backend_ICC2/4_Report/06_route_seq_pintrack
if {[info exists ::env(SEQ_ROUTE_REPORT_DIR)] && $::env(SEQ_ROUTE_REPORT_DIR) ne ""} {
  set DEBUG_REPORT_DIR $::env(SEQ_ROUTE_REPORT_DIR)
}
file mkdir $DEBUG_REPORT_DIR

set SEQ_ROUTE_INPUT_BLOCK route_eco_offgrid1
if {[info exists ::env(SEQ_ROUTE_INPUT_BLOCK)] && $::env(SEQ_ROUTE_INPUT_BLOCK) ne ""} {
  set SEQ_ROUTE_INPUT_BLOCK $::env(SEQ_ROUTE_INPUT_BLOCK)
}

set SEQ_ROUTE_OUTPUT_BLOCK route_seq_pintrack1
if {[info exists ::env(SEQ_ROUTE_OUTPUT_BLOCK)] && $::env(SEQ_ROUTE_OUTPUT_BLOCK) ne ""} {
  set SEQ_ROUTE_OUTPUT_BLOCK $::env(SEQ_ROUTE_OUTPUT_BLOCK)
}

set SEQ_ROUTE_STEPS {ZBUF_714_1050;ZBUF_851_152;ZBUF_832_2538;n143522}
if {[info exists ::env(SEQ_ROUTE_STEPS)] && $::env(SEQ_ROUTE_STEPS) ne ""} {
  set SEQ_ROUTE_STEPS $::env(SEQ_ROUTE_STEPS)
}

set SEQ_ROUTE_ITERATIONS 120
if {[info exists ::env(SEQ_ROUTE_ITERATIONS)] && $::env(SEQ_ROUTE_ITERATIONS) ne ""} {
  set SEQ_ROUTE_ITERATIONS $::env(SEQ_ROUTE_ITERATIONS)
}

set SEQ_ROUTE_SAVE 0
if {[info exists ::env(SEQ_ROUTE_SAVE)] && $::env(SEQ_ROUTE_SAVE) ne ""} {
  set SEQ_ROUTE_SAVE $::env(SEQ_ROUTE_SAVE)
}

set SEQ_ROUTE_SAVE_ON_CLEAN_ONLY 1
if {[info exists ::env(SEQ_ROUTE_SAVE_ON_CLEAN_ONLY)] && $::env(SEQ_ROUTE_SAVE_ON_CLEAN_ONLY) ne ""} {
  set SEQ_ROUTE_SAVE_ON_CLEAN_ONLY $::env(SEQ_ROUTE_SAVE_ON_CLEAN_ONLY)
}

set SEQ_SIZE_SWAPS ""
if {[info exists ::env(SEQ_SIZE_SWAPS)] && $::env(SEQ_SIZE_SWAPS) ne ""} {
  set SEQ_SIZE_SWAPS $::env(SEQ_SIZE_SWAPS)
}

set SEQ_CELL_MOVES ""
if {[info exists ::env(SEQ_CELL_MOVES)] && $::env(SEQ_CELL_MOVES) ne ""} {
  set SEQ_CELL_MOVES $::env(SEQ_CELL_MOVES)
}

set SEQ_SWAP_NET_EXCLUDE_REGEX {^(VDD|VSS)$}
if {[info exists ::env(SEQ_SWAP_NET_EXCLUDE_REGEX)] && $::env(SEQ_SWAP_NET_EXCLUDE_REGEX) ne ""} {
  set SEQ_SWAP_NET_EXCLUDE_REGEX $::env(SEQ_SWAP_NET_EXCLUDE_REGEX)
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

proc write_summary_row {fh step target result save_status} {
  puts $fh "$step\t$target\t$save_status\t[dict get $result total]\t[dict get $result open_nets]\t[dict get $result diff_net_spacing]\t[dict get $result less_than_min_area]\t[dict get $result needs_fat_contact]\t[dict get $result off_grid]\t[dict get $result same_net_spacing]\t[dict get $result short]\t[dict get $result connection_not_within_pin]"
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

proc run_check_routes {report_dir tag} {
  redirect -file $report_dir/check_routes.$tag.rpt {
    check_routes
  }
  return [parse_check_routes $report_dir/check_routes.$tag.rpt]
}

puts "SEQ_PINTRACK lib=$ICC2_LIB_DIR"
puts "SEQ_PINTRACK input_block=$SEQ_ROUTE_INPUT_BLOCK"
puts "SEQ_PINTRACK output_block=$SEQ_ROUTE_OUTPUT_BLOCK"
puts "SEQ_PINTRACK steps=$SEQ_ROUTE_STEPS"
puts "SEQ_PINTRACK size_swaps=$SEQ_SIZE_SWAPS"
puts "SEQ_PINTRACK cell_moves=$SEQ_CELL_MOVES"
puts "SEQ_PINTRACK report_dir=$DEBUG_REPORT_DIR"

open_lib $ICC2_LIB_DIR
open_block -edit $SEQ_ROUTE_INPUT_BLOCK

set_voltage $DEFAULT_VOLTAGE

set_ignored_layers \
  -min_routing_layer M1 \
  -max_routing_layer M8

set option_status ok
if {[catch {
  set_app_options -name route.detail.generate_extra_off_grid_pin_tracks -value true
} opt_msg]} {
  set option_status "extra_pin_tracks_error:$opt_msg"
}

redirect -file $DEBUG_REPORT_DIR/app_options.rpt {
  report_app_options route.detail.generate_extra_off_grid_pin_tracks
}

set swap_pin_net_names {}
set move_pin_net_names {}
if {$SEQ_SIZE_SWAPS ne ""} {
  set swap_fh [open $DEBUG_REPORT_DIR/size_swap.rpt w]
  puts $swap_fh "cell\told_ref\tnew_ref\tstatus\tmessage"
  set excluded_swap_pin_net_names {}

  foreach raw_swap [split $SEQ_SIZE_SWAPS ";"] {
    set swap_text [string trim $raw_swap]
    if {$swap_text eq ""} {
      continue
    }

    if {![regexp {^([^=]+)=(.+)$} $swap_text -> cell_name new_ref]} {
      puts $swap_fh "$swap_text\tNA\tNA\tFAIL\tExpected cell=lib_cell"
      continue
    }

    set cell_name [string trim $cell_name]
    set new_ref [string trim $new_ref]
    set cell_obj [get_cells -quiet $cell_name]
    set lib_cell_obj [get_lib_cells -quiet $new_ref]

    if {[sizeof_collection $cell_obj] == 0} {
      puts $swap_fh "$cell_name\tNA\t$new_ref\tFAIL\tcell_not_found"
      continue
    }
    if {[sizeof_collection $lib_cell_obj] == 0} {
      puts $swap_fh "$cell_name\tNA\t$new_ref\tFAIL\tlib_cell_not_found"
      continue
    }

    set old_ref [get_attribute $cell_obj ref_name]
    set swap_status [catch {size_cell $cell_obj $lib_cell_obj} swap_msg]
    if {$swap_status == 0} {
      puts $swap_fh "$cell_name\t$old_ref\t$new_ref\tPASS\t$swap_msg"
      foreach_in_collection net_obj [get_nets -quiet -of_objects [get_pins -quiet -of_objects $cell_obj]] {
        set net_name [get_object_name $net_obj]
        if {$SEQ_SWAP_NET_EXCLUDE_REGEX ne "" && [regexp $SEQ_SWAP_NET_EXCLUDE_REGEX $net_name]} {
          lappend excluded_swap_pin_net_names $net_name
        } else {
          lappend swap_pin_net_names $net_name
        }
      }
    } else {
      puts $swap_fh "$cell_name\t$old_ref\t$new_ref\tFAIL\t$swap_msg"
    }
  }

  set swap_pin_net_names [lsort -unique $swap_pin_net_names]
  set excluded_swap_pin_net_names [lsort -unique $excluded_swap_pin_net_names]
  puts $swap_fh ""
  puts $swap_fh "swap_net_exclude_regex\t$SEQ_SWAP_NET_EXCLUDE_REGEX"
  puts $swap_fh "excluded_swap_pin_nets\t[join $excluded_swap_pin_net_names { }]"
  puts $swap_fh "swap_pin_nets\t[join $swap_pin_net_names { }]"

  set legalize_status [catch {legalize_placement} legalize_msg]
  if {$legalize_status == 0} {
    puts $swap_fh "legalize_placement\tNA\tNA\tPASS\t$legalize_msg"
  } else {
    puts $swap_fh "legalize_placement\tNA\tNA\tFAIL\t$legalize_msg"
  }
  close $swap_fh
}

if {$SEQ_CELL_MOVES ne ""} {
  set move_fh [open $DEBUG_REPORT_DIR/cell_move.rpt w]
  puts $move_fh "cell\tdx\tdy\told_origin\tnew_origin_pre_legalize\tnew_origin_post_legalize\tstatus\tmessage"
  set excluded_move_pin_net_names {}

  foreach raw_move [split $SEQ_CELL_MOVES ";"] {
    set move_text [string trim $raw_move]
    if {$move_text eq ""} {
      continue
    }

    if {![regexp {^([^=]+)=([^,]+),(.+)$} $move_text -> cell_name dx dy]} {
      puts $move_fh "$move_text\tNA\tNA\tNA\tNA\tNA\tFAIL\tExpected cell=dx,dy"
      continue
    }

    set cell_name [string trim $cell_name]
    set dx [string trim $dx]
    set dy [string trim $dy]
    set cell_obj [get_cells -quiet $cell_name]

    if {[sizeof_collection $cell_obj] == 0} {
      puts $move_fh "$cell_name\t$dx\t$dy\tNA\tNA\tNA\tFAIL\tcell_not_found"
      continue
    }

    set old_origin [safe_attribute $cell_obj origin]
    set move_status [catch {move_objects -delta [list $dx $dy] $cell_obj} move_msg]
    set new_origin_pre [safe_attribute $cell_obj origin]

    if {$move_status == 0} {
      foreach_in_collection net_obj [get_nets -quiet -of_objects [get_pins -quiet -of_objects $cell_obj]] {
        set net_name [get_object_name $net_obj]
        if {$SEQ_SWAP_NET_EXCLUDE_REGEX ne "" && [regexp $SEQ_SWAP_NET_EXCLUDE_REGEX $net_name]} {
          lappend excluded_move_pin_net_names $net_name
        } else {
          lappend move_pin_net_names $net_name
        }
      }
    }

    puts $move_fh "$cell_name\t$dx\t$dy\t$old_origin\t$new_origin_pre\tPENDING\t[expr {$move_status == 0 ? "PASS" : "FAIL"}]\t$move_msg"
  }

  set legalize_status [catch {legalize_placement} legalize_msg]
  set move_pin_net_names [lsort -unique $move_pin_net_names]
  set excluded_move_pin_net_names [lsort -unique $excluded_move_pin_net_names]
  puts $move_fh ""
  puts $move_fh "move_net_exclude_regex\t$SEQ_SWAP_NET_EXCLUDE_REGEX"
  puts $move_fh "excluded_move_pin_nets\t[join $excluded_move_pin_net_names { }]"
  puts $move_fh "move_pin_nets\t[join $move_pin_net_names { }]"
  puts $move_fh "legalize_placement\tNA\tNA\tNA\tNA\tNA\t[expr {$legalize_status == 0 ? "PASS" : "FAIL"}]\t$legalize_msg"
  puts $move_fh ""
  puts $move_fh "post_legalize_cell\torigin\tbbox\tphysical_status"
  foreach raw_move [split $SEQ_CELL_MOVES ";"] {
    set move_text [string trim $raw_move]
    if {$move_text eq "" || ![regexp {^([^=]+)=} $move_text -> cell_name]} {
      continue
    }
    set cell_name [string trim $cell_name]
    set cell_obj [get_cells -quiet $cell_name]
    if {[sizeof_collection $cell_obj] == 0} {
      continue
    }
    puts $move_fh "$cell_name\t[safe_attribute $cell_obj origin]\t[safe_attribute $cell_obj bbox]\t[safe_attribute $cell_obj physical_status]"
  }
  close $move_fh
}

set summary_fh [open $DEBUG_REPORT_DIR/summary.tsv w]
puts $summary_fh "step\ttarget_nets\tsave_status\ttotal\topen_nets\tdiff_net_spacing\tless_than_min_area\tneeds_fat_contact\toff_grid\tsame_net_spacing\tshort\tconnection_not_within_pin"

set save_status no_save
set initial [run_check_routes $DEBUG_REPORT_DIR initial]
write_summary_row $summary_fh initial none $initial $save_status

set step_idx 0
set final_result $initial
foreach raw_step [split $SEQ_ROUTE_STEPS ";"] {
  set target_names [string trim $raw_step]
  if {$target_names eq ""} {
    continue
  }
  if {$target_names eq "@swap_pin_nets"} {
    set target_names [join $swap_pin_net_names { }]
    if {$target_names eq ""} {
      puts "SEQ_PINTRACK step=$step_idx token=@swap_pin_nets skipped_empty"
      continue
    }
  } elseif {$target_names eq "@move_pin_nets"} {
    set target_names [join $move_pin_net_names { }]
    if {$target_names eq ""} {
      puts "SEQ_PINTRACK step=$step_idx token=@move_pin_nets skipped_empty"
      continue
    }
  }
  incr step_idx
  puts "SEQ_PINTRACK step=$step_idx target_nets=$target_names"

  set target_nets [get_nets -quiet $target_names]
  remove_routes -nets $target_nets -detail_route

  route_eco \
    -nets $target_nets \
    -max_detail_route_iterations $SEQ_ROUTE_ITERATIONS \
    -reroute modified_nets_first_then_others \
    -reuse_existing_global_route false \
    -utilize_dangling_wires true

  set final_result [run_check_routes $DEBUG_REPORT_DIR after_step${step_idx}]
  write_summary_row $summary_fh after_step${step_idx} $target_names $final_result $save_status

  puts "SEQ_PINTRACK RESULT step=$step_idx total=[dict get $final_result total] open=[dict get $final_result open_nets] off_grid=[dict get $final_result off_grid] short=[dict get $final_result short] conn_not_within_pin=[dict get $final_result connection_not_within_pin]"
}

write_drc_reports $DEBUG_REPORT_DIR final

set is_clean [expr {[dict get $final_result total] == 0 && [dict get $final_result open_nets] == 0}]
if {$SEQ_ROUTE_SAVE && (!$SEQ_ROUTE_SAVE_ON_CLEAN_ONLY || $is_clean)} {
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
  save_block -as $SEQ_ROUTE_OUTPUT_BLOCK
  save_lib
  set save_status saved
} elseif {$SEQ_ROUTE_SAVE && $SEQ_ROUTE_SAVE_ON_CLEAN_ONLY && !$is_clean} {
  set save_status no_save_not_clean
}

puts $summary_fh "final\tall\t$save_status\t[dict get $final_result total]\t[dict get $final_result open_nets]\t[dict get $final_result diff_net_spacing]\t[dict get $final_result less_than_min_area]\t[dict get $final_result needs_fat_contact]\t[dict get $final_result off_grid]\t[dict get $final_result same_net_spacing]\t[dict get $final_result short]\t[dict get $final_result connection_not_within_pin]"
close $summary_fh

puts "SEQ_PINTRACK FINAL total=[dict get $final_result total] open=[dict get $final_result open_nets] off_grid=[dict get $final_result off_grid] save=$save_status"
exit
