################################################################################
# SAED32 RVT TT library setup for the first MNIST NPU baseline.
################################################################################

set SAED32_ROOT /DATA/home/edu135/lib/SAED32_EDK

set SAED32_RVT_TT_DB $SAED32_ROOT/lib/stdcell_rvt/db_nldm/saed32rvt_tt1p05v25c.db

set_app_var target_library [list $SAED32_RVT_TT_DB]
set_app_var link_library   [concat [list "*"] $target_library]

set_app_var search_path [concat $search_path [list \
  $SAED32_ROOT/lib/stdcell_rvt/db_nldm \
]]

