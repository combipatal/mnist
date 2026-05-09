################################################################################
# MNIST NPU DC Graphical topographical synthesis baseline.
#
# Baseline:
#   top     : nn_top
#   library : SAED32 RVT TT 1.05V 25C
#   clock   : 10 ns
#   physical: SAED32 1P9M Milkyway + TLU+
################################################################################

set PROJECT_ROOT /DATA/home/edu135/MNIST
set TOP_DESIGN   nn_top

cd $PROJECT_ROOT

set RTL_FILELIST 1_Input/filelists/rtl.f
set SDC_FILE     1_Input/constraints/mnist_npu_10ns.sdc

set RUN_TAG topo_10ns
set WORK_DIR 2_Synthesis/work_${RUN_TAG}
set MW_DESIGN_LIB 2_Synthesis/mw_lib/${TOP_DESIGN}_${RUN_TAG}_mw
set OUT_DIR 2_Synthesis/2_Output/${RUN_TAG}
set SVF_DIR 2_Synthesis/2_Output/svf
set RPT_DIR 2_Synthesis/4_Report/${RUN_TAG}

file delete -force $WORK_DIR
file delete -force $MW_DESIGN_LIB
file mkdir $WORK_DIR
file mkdir $OUT_DIR
file mkdir $SVF_DIR
file mkdir 2_Synthesis/3_Log
file mkdir $RPT_DIR
file mkdir 2_Synthesis/mw_lib

define_design_lib WORK -path $WORK_DIR

source 1_Input/tech/saed32_rvt_topo_setup.tcl

if {![shell_is_in_topographical_mode]} {
  puts "ERROR: This script must be run with dc_shell -topographical_mode."
  exit 1
}

set_app_var verilogout_no_tri true

create_mw_lib \
  -technology $SAED32_TECH_FILE \
  -mw_reference_library [list $SAED32_MW_RVT] \
  -hier_separator {/} \
  -bus_naming_style {%d} \
  -open $MW_DESIGN_LIB

set_tlu_plus_files \
  -max_tluplus $SAED32_TLUPLUS_MAX \
  -min_tluplus $SAED32_TLUPLUS_MIN \
  -tech2itf_map $SAED32_TLUPLUS_MAP

check_tlu_plus_files > ${RPT_DIR}/tlu_plus.check.rpt
check_library > ${RPT_DIR}/library.check.rpt

set RTL_FILES {}
set fp [open $RTL_FILELIST r]
while {[gets $fp line] >= 0} {
  set line [string trim $line]
  if {$line eq ""} {
    continue
  }
  if {[string match "#*" $line]} {
    continue
  }
  lappend RTL_FILES $line
}
close $fp

puts "INFO: Analyzing RTL files:"
foreach rtl_file $RTL_FILES {
  puts "INFO:   $rtl_file"
}

analyze -format sverilog $RTL_FILES
elaborate $TOP_DESIGN
current_design $TOP_DESIGN
link

check_design > ${RPT_DIR}/pre_compile.check_design.rpt
read_sdc $SDC_FILE
check_timing > ${RPT_DIR}/pre_compile.check_timing.rpt

set_svf ${SVF_DIR}/${TOP_DESIGN}.${RUN_TAG}.mapped.svf

compile_ultra -spg

set_svf -off

check_design > ${RPT_DIR}/post_compile.check_design.rpt
report_qor > ${RPT_DIR}/post_compile.qor.rpt
report_timing -delay_type max -max_paths 20 > ${RPT_DIR}/post_compile.timing.max.rpt
report_timing -delay_type min -max_paths 20 > ${RPT_DIR}/post_compile.timing.min.rpt
report_area -hierarchy > ${RPT_DIR}/post_compile.area.rpt
report_power -hierarchy > ${RPT_DIR}/post_compile.power.rpt
report_constraint -all_violators > ${RPT_DIR}/post_compile.constraints.rpt
report_reference -hierarchy > ${RPT_DIR}/post_compile.reference.rpt

write -format ddc -hierarchy -output ${OUT_DIR}/${TOP_DESIGN}.${RUN_TAG}.mapped.ddc
write -format verilog -hierarchy -output ${OUT_DIR}/${TOP_DESIGN}.${RUN_TAG}.mapped.vg
write_sdc ${OUT_DIR}/${TOP_DESIGN}.${RUN_TAG}.mapped.sdc
write_sdf ${OUT_DIR}/${TOP_DESIGN}.${RUN_TAG}.mapped.sdf

close_mw_lib
puts "INFO: DC topographical compile completed for $TOP_DESIGN"
exit

