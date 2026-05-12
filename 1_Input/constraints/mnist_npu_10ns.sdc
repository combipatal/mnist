################################################################################
# First-pass MNIST NPU functional constraints.
#
# Purpose:
#   Baseline DC synthesis and ICC2 implementation flow bring-up.
################################################################################

create_clock -name clk -period 10.000 [get_ports clk]

# First-baseline propagated-clock policy:
# keep setup margin at 100 ps, use a smaller hold margin after CTS/route.
set_clock_uncertainty -setup 0.100 [get_clocks clk]
set_clock_uncertainty -hold  0.040 [get_clocks clk]
set_input_transition 0.100 [get_ports {reset wr_en din*}]

set_input_delay  1.000 -clock clk [get_ports {wr_en din*}]
set_output_delay 1.000 -clock clk [all_outputs]

# Active-high async reset is not timed as functional data.
set_false_path -from [get_ports reset]
