################################################################################
# MNIST NPU Design Compiler first-pass script.
#
# First checkpoint:
#   analyze -> elaborate -> link -> check_design
#
# Full compile is intentionally disabled until front-end intake is clean.
################################################################################

set PROJECT_ROOT /DATA/home/edu135/MNIST
set TOP_DESIGN   nn_top

cd $PROJECT_ROOT

set RTL_FILELIST 1_Input/filelists/rtl.f
set SDC_FILE     1_Input/constraints/mnist_npu_10ns.sdc

file delete -force 2_Synthesis/work
file mkdir 2_Synthesis/work
file mkdir 2_Synthesis/2_Output
file mkdir 2_Synthesis/2_Output/unmapped
file mkdir 2_Synthesis/2_Output/mapped
file mkdir 2_Synthesis/2_Output/svf
file mkdir 2_Synthesis/3_Log
file mkdir 2_Synthesis/4_Report

define_design_lib WORK -path 2_Synthesis/work

source 1_Input/tech/saed32_rvt_tt_setup.tcl

set_app_var hdlin_enable_presto true
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
report_reference -hierarchy > 2_Synthesis/4_Report/pre_compile.reference.rpt

read_sdc $SDC_FILE
check_timing > 2_Synthesis/4_Report/pre_compile.check_timing.rpt
report_constraint -all_violators > 2_Synthesis/4_Report/pre_compile.constraints.rpt

write -format ddc -hierarchy -output 2_Synthesis/2_Output/unmapped/${TOP_DESIGN}.unmapped.ddc

puts "INFO: DC front-end checkpoint completed for $TOP_DESIGN"
exit
