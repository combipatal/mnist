################################################################################
# Build the MNIST SAED32 RVT NDM trial with libdir/LEF/modify and a VIA1
# pitch/no-track technology interpretation.
#
# Purpose:
#   Keep the TT RVT timing DB unchanged while testing the backend physical
#   abstract policy that closed the same lower-metal DRC class in Ibex.
################################################################################

set PROJECT_ROOT /DATA/home/edu135/MNIST
cd $PROJECT_ROOT

set SAED32_ROOT /DATA/home/edu135/lib/SAED32_EDK
set LIBDIR_ROOT /DATA/home/edu135/lib/libdir

set TECH_FILE $PROJECT_ROOT/4_Backend_ICC2/2_Output/00_setup/tech/saed32nm_1p9m_mw.via1_pitch_no_track.tf
set RVT_TT_DB $SAED32_ROOT/lib/stdcell_rvt/db_nldm/saed32rvt_tt1p05v25c.db
set RVT_LEF $LIBDIR_ROOT/LEF/modify/saed32nm_rvt_1p9m.lef

set NDM_DIR $PROJECT_ROOT/4_Backend_ICC2/2_Output/00_setup/ndm_libdir_via1_no_track

if {[info exists ::env(MNIST_NDM_TECH_FILE)]} {
  set TECH_FILE $::env(MNIST_NDM_TECH_FILE)
}
if {[info exists ::env(MNIST_NDM_DIR)]} {
  set NDM_DIR $::env(MNIST_NDM_DIR)
}

file mkdir $NDM_DIR

create_workspace -technology $TECH_FILE -flow normal saed32rvt_tt_libdir_via1_no_track
read_db $RVT_TT_DB
read_lef $RVT_LEF
check_workspace
commit_workspace -output $NDM_DIR/saed32rvt_tt.ndm -force

exit
