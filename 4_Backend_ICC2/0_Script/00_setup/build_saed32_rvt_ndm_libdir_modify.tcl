################################################################################
# Build the MNIST SAED32 RVT NDM trial with libdir/LEF/modify physical abstract.
#
# Purpose:
#   Keep the timing DB and technology stack identical to the baseline, but swap
#   the RVT LEF source to /DATA/home/edu135/lib/libdir/LEF/modify.
################################################################################

set PROJECT_ROOT /DATA/home/edu135/MNIST
cd $PROJECT_ROOT

set SAED32_ROOT /DATA/home/edu135/lib/SAED32_EDK
set LIBDIR_ROOT /DATA/home/edu135/lib/libdir

set TECH_FILE $SAED32_ROOT/tech/milkyway/saed32nm_1p9m_mw.tf
set RVT_TT_DB $SAED32_ROOT/lib/stdcell_rvt/db_nldm/saed32rvt_tt1p05v25c.db
set RVT_LEF $LIBDIR_ROOT/LEF/modify/saed32nm_rvt_1p9m.lef

set NDM_DIR $PROJECT_ROOT/4_Backend_ICC2/2_Output/00_setup/ndm_libdir_modify
file mkdir $NDM_DIR

create_workspace -technology $TECH_FILE -flow normal saed32rvt_tt_libdir_modify
read_db $RVT_TT_DB
read_lef $RVT_LEF
check_workspace
commit_workspace -output $NDM_DIR/saed32rvt_tt.ndm -force

exit
