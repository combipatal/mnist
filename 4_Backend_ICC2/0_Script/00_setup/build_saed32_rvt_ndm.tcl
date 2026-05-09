################################################################################
# Build the SAED32 RVT NDM reference library for ICC2.
################################################################################

set PROJECT_ROOT /DATA/home/edu135/MNIST
cd $PROJECT_ROOT

set SAED32_ROOT /DATA/home/edu135/lib/SAED32_EDK

set TECH_FILE $SAED32_ROOT/tech/milkyway/saed32nm_1p9m_mw.tf
set RVT_TT_DB $SAED32_ROOT/lib/stdcell_rvt/db_nldm/saed32rvt_tt1p05v25c.db

# The nested RVT LEF contains the complete macro definitions used by ICC2.
set RVT_LEF $SAED32_ROOT/lib/stdcell_rvt/SAED32_EDK/lib/stdcell_rvt/lef/saed32nm_rvt_1p9m.lef

set NDM_DIR $PROJECT_ROOT/4_Backend_ICC2/2_Output/00_setup/ndm
file mkdir $NDM_DIR

create_workspace -technology $TECH_FILE -flow normal saed32rvt_tt
read_db $RVT_TT_DB
read_lef $RVT_LEF
check_workspace
commit_workspace -output $NDM_DIR/saed32rvt_tt.ndm -force

exit

