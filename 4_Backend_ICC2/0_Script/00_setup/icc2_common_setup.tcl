################################################################################
# MNIST NPU ICC2 common setup for the first RVT-only backend baseline.
################################################################################

set PROJECT_ROOT /DATA/home/edu135/MNIST
cd $PROJECT_ROOT

set TOP_NAME nn_top

set SAED32_ROOT /DATA/home/edu135/lib/SAED32_EDK

set RVT_TT_DB $SAED32_ROOT/lib/stdcell_rvt/db_nldm/saed32rvt_tt1p05v25c.db

set TECH_FILE $SAED32_ROOT/tech/milkyway/saed32nm_1p9m_mw.tf
set TLUPLUS_MAX $SAED32_ROOT/tech/star_rcxt/saed32nm_1p9m_Cmax.tluplus
set TLUPLUS_MIN $SAED32_ROOT/tech/star_rcxt/saed32nm_1p9m_Cmin.tluplus
set TLUPLUS_MAP $SAED32_ROOT/tech/star_rcxt/saed32nm_tf_itf_tluplus.map

set NDM_RVT $PROJECT_ROOT/4_Backend_ICC2/2_Output/00_setup/ndm/saed32rvt_tt.ndm

set DC_TOPO_NETLIST $PROJECT_ROOT/2_Synthesis/2_Output/topo_10ns/nn_top.topo_10ns.mapped.vg
set DC_TOPO_SDC     $PROJECT_ROOT/2_Synthesis/2_Output/topo_10ns/nn_top.topo_10ns.mapped.sdc
set ICC2_SDC        $PROJECT_ROOT/1_Input/constraints/mnist_npu_10ns.sdc

if {[info exists ::env(DC_TOPO_NETLIST)]} {
  set DC_TOPO_NETLIST $::env(DC_TOPO_NETLIST)
}
if {[info exists ::env(DC_TOPO_SDC)]} {
  set DC_TOPO_SDC $::env(DC_TOPO_SDC)
}
if {[info exists ::env(ICC2_SDC)]} {
  set ICC2_SDC $::env(ICC2_SDC)
}

set ICC2_LIB_DIR $PROJECT_ROOT/4_Backend_ICC2/2_Output/01_init_design/mnist_npu_icc2_lib
set SETUP_LOG_DIR $PROJECT_ROOT/4_Backend_ICC2/3_Log/00_setup
set INIT_LOG_DIR $PROJECT_ROOT/4_Backend_ICC2/3_Log/01_init_design
set FLOORPLAN_LOG_DIR $PROJECT_ROOT/4_Backend_ICC2/3_Log/02_floorplan
set POWER_LOG_DIR $PROJECT_ROOT/4_Backend_ICC2/3_Log/03_powerplan
set SETUP_REPORT_DIR $PROJECT_ROOT/4_Backend_ICC2/4_Report/00_setup
set INIT_REPORT_DIR $PROJECT_ROOT/4_Backend_ICC2/4_Report/01_init_design
set FLOORPLAN_REPORT_DIR $PROJECT_ROOT/4_Backend_ICC2/4_Report/02_floorplan
set POWER_REPORT_DIR $PROJECT_ROOT/4_Backend_ICC2/4_Report/03_powerplan
set PLACE_REPORT_DIR $PROJECT_ROOT/4_Backend_ICC2/4_Report/04_place
set CTS_REPORT_DIR $PROJECT_ROOT/4_Backend_ICC2/4_Report/05_cts
set ROUTE_REPORT_DIR $PROJECT_ROOT/4_Backend_ICC2/4_Report/06_route

file mkdir $PROJECT_ROOT/4_Backend_ICC2/2_Output/00_setup
file mkdir $PROJECT_ROOT/4_Backend_ICC2/2_Output/01_init_design
file mkdir $PROJECT_ROOT/4_Backend_ICC2/2_Output/02_floorplan
file mkdir $PROJECT_ROOT/4_Backend_ICC2/2_Output/03_powerplan
file mkdir $PROJECT_ROOT/4_Backend_ICC2/2_Output/04_place
file mkdir $PROJECT_ROOT/4_Backend_ICC2/2_Output/05_cts
file mkdir $PROJECT_ROOT/4_Backend_ICC2/2_Output/06_route
file mkdir $SETUP_LOG_DIR
file mkdir $INIT_LOG_DIR
file mkdir $FLOORPLAN_LOG_DIR
file mkdir $POWER_LOG_DIR
file mkdir $SETUP_REPORT_DIR
file mkdir $INIT_REPORT_DIR
file mkdir $FLOORPLAN_REPORT_DIR
file mkdir $POWER_REPORT_DIR
file mkdir $PLACE_REPORT_DIR
file mkdir $CTS_REPORT_DIR
file mkdir $ROUTE_REPORT_DIR

set target_library [list $RVT_TT_DB]
set link_library [list * $RVT_TT_DB]
