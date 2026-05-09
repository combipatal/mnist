################################################################################
# SAED32 RVT topographical setup for the first MNIST NPU baseline.
################################################################################

set SAED32_ROOT /DATA/home/edu135/lib/SAED32_EDK

set SAED32_RVT_TT_DB $SAED32_ROOT/lib/stdcell_rvt/db_nldm/saed32rvt_tt1p05v25c.db

set SAED32_TECH_FILE   $SAED32_ROOT/tech/milkyway/saed32nm_1p9m_mw.tf
set SAED32_TLUPLUS_MAX $SAED32_ROOT/tech/star_rcxt/saed32nm_1p9m_Cmax.tluplus
set SAED32_TLUPLUS_MIN $SAED32_ROOT/tech/star_rcxt/saed32nm_1p9m_Cmin.tluplus
set SAED32_TLUPLUS_MAP $SAED32_ROOT/tech/star_rcxt/saed32nm_tf_itf_tluplus.map

set SAED32_MW_RVT $SAED32_ROOT/lib/stdcell_rvt/milkyway/saed32nm_rvt_1p9m

set_app_var target_library [list $SAED32_RVT_TT_DB]
set_app_var link_library   [concat [list "*"] $target_library]

set_app_var search_path [concat $search_path [list \
  $SAED32_ROOT/lib/stdcell_rvt/db_nldm \
]]

