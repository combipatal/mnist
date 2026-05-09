################################################################################
# MNIST NPU Design Compiler synthesis baseline.
#
# Baseline:
#   top     : nn_top
#   library : SAED32 RVT TT 1.05V 25C
#   clock   : 10 ns
################################################################################

set PROJECT_ROOT /DATA/home/edu135/MNIST
set TOP_DESIGN   nn_top

cd $PROJECT_ROOT

set RTL_FILELIST 1_Input/filelists/rtl.f
set SDC_FILE     1_Input/constraints/mnist_npu_10ns.sdc

file delete -force 2_Synthesis/work_compile
file mkdir 2_Synthesis/work_compile
file mkdir 2_Synthesis/2_Output/mapped
file mkdir 2_Synthesis/2_Output/svf
file mkdir 2_Synthesis/3_Log
file mkdir 2_Synthesis/4_Report

define_design_lib WORK -path 2_Synthesis/work_compile

source 1_Input/tech/saed32_rvt_tt_setup.tcl

set_app_var verilogout_no_tri true

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

check_design > 2_Synthesis/4_Report/pre_compile.check_design.rpt
read_sdc $SDC_FILE
check_timing > 2_Synthesis/4_Report/pre_compile.check_timing.rpt

set_svf 2_Synthesis/2_Output/svf/${TOP_DESIGN}.mapped.svf

compile_ultra

set_svf -off

check_design > 2_Synthesis/4_Report/post_compile.check_design.rpt
report_qor > 2_Synthesis/4_Report/post_compile.qor.rpt
report_timing -delay_type max -max_paths 20 > 2_Synthesis/4_Report/post_compile.timing.max.rpt
report_timing -delay_type min -max_paths 20 > 2_Synthesis/4_Report/post_compile.timing.min.rpt
report_area -hierarchy > 2_Synthesis/4_Report/post_compile.area.rpt
report_power -hierarchy > 2_Synthesis/4_Report/post_compile.power.rpt
report_constraint -all_violators > 2_Synthesis/4_Report/post_compile.constraints.rpt
report_reference -hierarchy > 2_Synthesis/4_Report/post_compile.reference.rpt

write -format ddc -hierarchy -output 2_Synthesis/2_Output/mapped/${TOP_DESIGN}.mapped.ddc
write -format verilog -hierarchy -output 2_Synthesis/2_Output/mapped/${TOP_DESIGN}.mapped.vg
write_sdc 2_Synthesis/2_Output/mapped/${TOP_DESIGN}.mapped.sdc
write_sdf 2_Synthesis/2_Output/mapped/${TOP_DESIGN}.mapped.sdf

puts "INFO: DC compile completed for $TOP_DESIGN"
exit

