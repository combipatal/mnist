# Result Summary

## Baseline

```text
name: mnist_npu_rvt_tt_10ns_route
top: nn_top
library: SAED32 RVT TT 1.05V 25C
clock: 10 ns
backend utilization target: 55%
```

## Stage Status

| Stage | Status | Evidence |
| --- | --- | --- |
| RTL intake | RECORDED | `00_Project_Tracking/SOURCE_REVISION.md`, `docs/rtl_intake.md` |
| DC analyze/elaborate/link | PASS | `2_Synthesis/3_Log/run_dc.log`, `2_Synthesis/4_Report/pre_compile.check_design.rpt` |
| DC synthesis | PASS_WITH_ACCEPTED_RISKS | `2_Synthesis/3_Log/run_dc_compile_topo.log`, `2_Synthesis/4_Report/topo_10ns/post_compile.qor.rpt`, `2_Synthesis/2_Output/topo_10ns/nn_top.topo_10ns.mapped.ddc` |
| Formality R2N | PASS | `3_Formality/3_Log/run_fm_r2n_topo.log`, `3_Formality/4_Report/r2n_topo_10ns/r2n_topo_10ns.failing_points.rpt` |
| ICC2 init_design | PASS_WITH_OPEN_WARNINGS | `4_Backend_ICC2/3_Log/01_init_design/run_init_design_check.log`, `4_Backend_ICC2/4_Report/01_init_design/check_design.rpt`, `4_Backend_ICC2/2_Output/01_init_design/mnist_npu_icc2_lib` |
| Floorplan | PASS_WITH_OPEN_WARNINGS | `4_Backend_ICC2/3_Log/02_floorplan/run_floorplan_initial.log`, `4_Backend_ICC2/4_Report/02_floorplan/utilization.rpt` |
| Powerplan | PASS_WITH_OPEN | `4_Backend_ICC2/3_Log/03_powerplan/run_powerplan_initial.log`, `4_Backend_ICC2/4_Report/03_powerplan/pg_connectivity.rpt`, `4_Backend_ICC2/4_Report/03_powerplan/pg_drc.rpt` |
| Placement | PASS_WITH_OPEN | `4_Backend_ICC2/3_Log/04_place/run_place_initial.log`, `4_Backend_ICC2/4_Report/04_place/check_legality.rpt`, `4_Backend_ICC2/4_Report/04_place/pg_connectivity.rpt` |
| CTS | PASS_WITH_OPEN | `4_Backend_ICC2/3_Log/05_cts/run_cts_initial.log`, `4_Backend_ICC2/4_Report/05_cts/clock_qor.summary.rpt`, `4_Backend_ICC2/4_Report/05_cts/check_legality.rpt`, `4_Backend_ICC2/4_Report/05_cts/pg_connectivity.rpt` |
| Route | PASS_WITH_OPEN | `4_Backend_ICC2/3_Log/06_route/run_route_initial.log`, `4_Backend_ICC2/4_Report/06_route/check_routes.rpt`, `4_Backend_ICC2/4_Report/06_route/qor.rpt`, `4_Backend_ICC2/4_Report/06_route/pg_connectivity.rpt` |
| Route-plus-PG candidate extraction | PASS_WITH_OPEN | `4_Backend_ICC2/3_Log/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_pg_ladder_vdd50_vss20_path507x55_h015/run.log`, `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_pg_ladder_vdd50_vss20_path507x55_h015/report_status.tsv` |
| Broad post-route route_opt trial | COMPLETED_NOT_ADOPTED | `4_Backend_ICC2/3_Log/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_route_opt1/run.log`, `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_route_opt1/report_status.tsv` |
| Open-site hold ECO trial | COMPLETED_NOT_ADOPTED_NEAR_ROUTE_CLEAN | `4_Backend_ICC2/3_Log/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_hold_eco_open_site_m0/run.log`, `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_hold_eco_open_site_m0/report_status.tsv` |

## DC Topographical Synthesis Summary

| Metric | Value |
| --- | --- |
| Tool mode | `dc_shell -topographical_mode` |
| Compile | `compile_ultra -spg` |
| Setup WNS/TNS | `0.00 / 0.00` |
| Setup violating paths | `0` |
| Hold WNS/TNS | about `-0.01 / -1.06` |
| Hold violating paths | `221` |
| Cell area | `615341.590990` |
| Leaf cells | `175574` |
| Sequential cells | `39659` |
| Macro count | `0` |
| Max transition violations | `2518` |
| Max capacitance violations | `17694` |

## DC Accepted Risks

| Risk | Disposition |
| --- | --- |
| Max cap/max transition violations | Accepted for first baseline; re-check and optimize in ICC2. |
| Small hold violations | Accepted for first baseline; re-check after CTS/route. |
| SAED32 scan FF `check_library` messages | Recorded as DFT/library risk; first baseline has no DFT insertion. |
| FF-array memories | Accepted because SRAM macro replacement is disabled for the first pass. |

## Formality R2N Summary

| Metric | Value |
| --- | --- |
| Reference | RTL filelist `1_Input/filelists/rtl.f` |
| Implementation | `2_Synthesis/2_Output/topo_10ns/nn_top.topo_10ns.mapped.vg` |
| SVF | `2_Synthesis/2_Output/svf/nn_top.topo_10ns.mapped.svf` |
| Result | `Verification SUCCEEDED` |
| Passing compare points | `39681` |
| Failing compare points | `0` |
| Unmatched compare points | `0(0)` |
| Unverified compare points | `0` |

## Formality Accepted Warnings

| Warning | Disposition |
| --- | --- |
| `synopsys_auto_setup` enabled | Accepted; assumptions are recorded in FM log. |
| RTL signedness/array-bound interpretation warnings | Accepted for first baseline because R2N passed; retain as RTL-quality risk. |
| 64 rejected SVF `change_names` guidance commands | Accepted because verification succeeded. |

## ICC2 Init Summary

| Metric | Value |
| --- | --- |
| Netlist | `2_Synthesis/2_Output/topo_10ns/nn_top.topo_10ns.mapped.vg` |
| Reference library | `4_Backend_ICC2/2_Output/00_setup/ndm/saed32rvt_tt.ndm` |
| Link result | `nn_top` successfully linked |
| Saved library/block | `4_Backend_ICC2/2_Output/01_init_design/mnist_npu_icc2_lib` |
| Leaf cells | `175574` |
| Sequential cells | `39659` |
| Hard macros | `0` |
| Floating/no-driver nets | `16` |

## ICC2 Init Open Warnings

| Warning | Disposition |
| --- | --- |
| DC-written SDC emits unsupported net `set_load` warnings in ICC2 | Resolved for ICC2 bring-up by reading clean project SDC `1_Input/constraints/mnist_npu_10ns.sdc`. |
| Async reset endpoints reported unconstrained | Expected from reset false-path handling; keep explicit and review before timing closure. |
| 16 no-driver mapped-netlist nets | Classify as optimization leftovers or fix before claiming clean init. |

## ICC2 Floorplan Summary

| Metric | Value |
| --- | --- |
| Target utilization | `0.55` |
| Reported utilization | `0.5506` |
| Core area | `{20 20} {1077.616 1076.704}` |
| Total cell area | `615341.5854` |
| Top-level pins placed | `41` |
| Setup sample slack | `5.97 ns` |
| Hold sample worst slack | about `-0.01 ns` |

## ICC2 Powerplan Summary

| Metric | Value |
| --- | --- |
| Saved block | `powerplan` |
| PG wires/vias committed | `813 / 24942` |
| Boundary PG pins | `16` |
| PG DRC | `No errors found` |
| VDD connectivity | `7` floating wires, `175574` floating standard cells |
| VSS connectivity | `7` floating wires, `175574` floating standard cells |

## ICC2 Powerplan Open Warnings

| Warning | Disposition |
| --- | --- |
| PG connectivity reports all standard cells floating | Not PG-clean; expected to remain open before placement because cells are unplaced. Re-check after placement. |
| 7 floating wires on VDD and VSS | Carry into placement/debug; do not claim PG clean until fixed or classified. |

## ICC2 Placement Summary

| Metric | Value |
| --- | --- |
| Saved block | `placement` |
| Utilization | `0.5506` |
| Legality | `TOTAL 0 Violations` |
| Setup QoR | `clk` critical path slack `5.26 ns`, setup violating paths `0` |
| Hold QoR | worst `-0.01 ns`, total `-1.02`, violations `180` |
| PG DRC | `No errors found` |
| VDD connectivity | `7` floating wires, `3985` floating standard cells, `8` floating terminals |
| VSS connectivity | `7` floating wires, `3405` floating standard cells |
| Phase1 global-route overflow | `45036`, max `5`, GRCs `36186 (4.20%)` |
| Routing density over target | horizontal `38.28%`, vertical `6.22%` |
| Max transition/cap violations | `3394 / 21531` |

## ICC2 Placement Open Warnings

| Warning | Disposition |
| --- | --- |
| PG connectivity still has floating std cells | Not PG-clean; keep open for powerplan/placement repair or post-CTS recheck. |
| High global-route congestion at 55% utilization | Continue first baseline to CTS/route for evidence, but prepare lower-utilization trial if route fails. |
| Hold remains slightly negative before CTS | Accepted for first baseline; re-check after CTS/route. |
| Max cap/transition violations increased after placement | Carry into CTS/route optimization; do not claim electrical clean. |

## ICC2 CTS Summary

| Metric | Value |
| --- | --- |
| Command | `4_Backend_ICC2/0_Script/05_cts/run_cts_initial.sh` |
| Input block | `mnist_npu_icc2_lib:placement.design` |
| Saved block | `mnist_npu_icc2_lib:cts.design` |
| Clock routing layers | `M4` to `M6` |
| Clock sinks | `39659` |
| Clock tree levels | `11` |
| Clock repeaters | `1066` |
| Clock repeater area | `3800.98` |
| Max latency / global skew | `0.38 ns / 0.21 ns` |
| Clock transition/cap DRC | `0 / 7` |
| Setup QoR | worst setup slack `5.57 ns`, setup violating paths `0` |
| Hold QoR | worst hold `-0.10 ns`, total hold `-237.12`, violations `23288` |
| Utilization after CTS | `0.6925` |
| Legality | `TOTAL 0 Violations` |
| Clock route detail DRC | `TOTAL VIOLATIONS = 0`; `0 open nets` |
| PG DRC | `No errors found` |
| VDD connectivity | `7` floating wires, `4653` floating standard cells, `8` floating terminals |
| VSS connectivity | `7` floating wires, `3963` floating standard cells |
| Design max transition/cap violations | `187 / 1492` |

## ICC2 CTS Open Warnings

| Warning | Disposition |
| --- | --- |
| Hold became significantly worse after CTS | Must be addressed in route/post-route optimization; do not claim hold clean. |
| PG connectivity still has floating std cells | Not PG-clean; keep open for route-stage PG repair/debug. |
| Clock-specific cap DRC count is `7` | Must be rechecked after route optimization. |
| Design max transition/cap remain open | Improved versus placement but still not electrical clean. |
| `POW-080` default voltage warnings | Route and future CTS scripts now set default top-level voltage to `1.05 V`; re-check on next run. |

## ICC2 Route Summary

| Metric | Value |
| --- | --- |
| Command | `4_Backend_ICC2/0_Script/06_route/run_route_initial.sh` |
| Input block | `mnist_npu_icc2_lib:cts.design` |
| Saved block | `mnist_npu_icc2_lib:route.design` |
| Signal routing layers | `M1` to `M8` |
| Open signal nets | `0` |
| Route DRC total | `738` |
| Route DRC classes | `285` diff-net spacing, `4` minimum-area, `183` needs-fat-contact, `240` off-grid, `26` short |
| Antenna | no antenna rules defined; not proven clean |
| Setup QoR | worst setup slack `5.59 ns`, setup violating paths `0` |
| Hold QoR | worst hold `-0.10 ns`, total hold `-288.96`, violations `25344` |
| Utilization after route | `0.6925` |
| Legality | `TOTAL 0 Violations` |
| PG DRC | `No errors found` |
| VDD connectivity | `7` floating wires, `4653` floating standard cells, `8` floating terminals |
| VSS connectivity | `7` floating wires, `3963` floating standard cells |
| Design max transition/cap violations | `287 / 1958` |
| Cell area | `773908.63` |
| Net length | `7026401.73` |

## ICC2 Route Open Warnings

| Warning | Disposition |
| --- | --- |
| Route DRC remains open | Must classify by location/type before claiming route clean; likely congestion or pin-access driven at the 55% first baseline. |
| Antenna report has no rules | Do not claim antenna clean; the SAED32 route setup did not provide antenna rules for this check. |
| Hold remains significantly negative | Needs post-route optimization or timing-closure loop; route baseline is not hold clean. |
| PG connectivity still has floating std cells | PG DRC alone is insufficient; debug rail/pin connectivity before claiming PG clean. |
| Max transition/cap remain open | Electrical cleanup still required after route. |
| Route log beginning was partially overwritten by a duplicate launch | Use completed report files and the intact log tail as route evidence; route script now has a lock guard. |

## ICC2 Route DRC Repair Trial Summary

| Metric | Baseline Route | Route ECO DRC1 | libdir VIA1 no-track route |
| --- | --- | --- | --- |
| Command | `4_Backend_ICC2/0_Script/06_route/run_route_initial.sh` | `4_Backend_ICC2/0_Script/06_route/run_route_eco_drc1.sh` | `4_Backend_ICC2/0_Script/99_util/run_libdir_via1_no_track_backend_flow.sh` |
| Reference physical setup | EDK RVT NDM | EDK RVT NDM | libdir modified LEFs plus VIA1 pitch/no-track techfile |
| Open signal nets | `0` | `0` | `0` |
| Route DRC total | `738` | `709` | `77` |
| Diff-net spacing | `285` | `263` | `3` |
| Minimum-area | `4` | `7` | `1` |
| Needs-fat-contact | `183` | `205` | `0` |
| Off-grid | `240` | `210` | `72` |
| Same-net spacing | `0` | `0` | `1` |
| Short | `26` | `24` | `0` |
| Antenna | no antenna rules defined | no antenna rules defined | no antenna rules defined |
| Setup QoR | worst setup slack `5.59 ns`, setup violating paths `0` | setup still met | worst setup slack `5.60 ns`, setup violating paths `0` |
| Hold QoR | worst `-0.10 ns`, total `-288.96`, violations `25344` | about worst `-0.10 ns`; still open | worst `-0.10 ns`, total `-235.75`, violations `22731` |
| Utilization after route | `0.6925` | `0.6925` | `0.6924` |
| Legality | `TOTAL 0 Violations` | `TOTAL 0 Violations` | `TOTAL 0 Violations` |
| PG DRC | `No errors found` | `No errors found` | `No errors found` in route log |
| VDD connectivity | `7` floating wires, `4653` floating std cells, `8` floating terminals | still open | `7` floating wires, `4697` floating std cells |
| VSS connectivity | `7` floating wires, `3963` floating std cells | still open | `7` floating wires, `4151` floating std cells |
| Max transition/cap violations | `287 / 1958` | still open | `296 / 2011` |
| Disposition | Fixed first route baseline, not clean | Completed but not adopted | Best route-DRC candidate, not clean yet |

## ICC2 libdir VIA1 no-track Residual DRC Summary

| Metric | Value |
| --- | --- |
| Debug command | `4_Backend_ICC2/0_Script/06_route/debug_libdir_via1_no_track_route_residuals.sh` |
| Debug reports | `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_route/06_route_debug/` |
| Rechecked open signal nets | `0` |
| Rechecked DRC total | `77` |
| Off-grid total | `72` |
| Off-grid by layer | `69` M1, `3` M2 |
| Off-grid PG references | `0` VDD/VSS object references |
| Off-grid signal references | `72` signal-only entries |
| Largest repeated off-grid object | `n47593`, `3` entries |
| Largest 100um coordinate bucket | `500,700`, `12` off-grid entries |
| PG connectivity shape | VDD and VSS each have `8` disjoint networks: one main network plus seven one-wire/zero-via subnetworks |
| PG DRC | `No errors found` |

## ICC2 libdir VIA1 no-track Route-only ECO Off-grid Trial

| Metric | Value |
| --- | --- |
| Command | `4_Backend_ICC2/0_Script/06_route/run_libdir_via1_no_track_route_eco_offgrid1.sh` |
| Input block | `mnist_npu_icc2_lib:route.design` in the `libdir_via1_no_track_route` trial library |
| Output block | `mnist_npu_icc2_lib:route_eco_offgrid1.design` |
| Pre-check DRC | `77`: `3` diff-net spacing, `1` min-area, `72` off-grid, `1` same-net spacing |
| ECO changed nets | `364` |
| Best intermediate DRC | `38`, then non-monotonic |
| Final post-check DRC | `55`: `2` diff-net spacing, `53` off-grid |
| Open signal nets | `0` |
| Legality | `TOTAL 0 Violations` |
| Setup QoR | worst setup slack `5.60 ns`, setup violating paths `0` |
| Hold QoR | worst `-0.10 ns`, total `-235.75`, violations `22731` |
| PG connectivity | unchanged: VDD `4697` floating std cells, VSS `4151` floating std cells |
| PG DRC | `No errors found` |
| Disposition | Partial route-only repair; not a clean closure path by itself |

## ICC2 libdir VIA1 no-track 45% Utilization Backend Trial

| Metric | Value |
| --- | --- |
| Command | `4_Backend_ICC2/0_Script/99_util/run_libdir_via1_no_track_util45_backend_flow.sh` |
| Physical setup | libdir modified LEF plus VIA1 pitch/no-track techfile |
| Floorplan utilization target | `0.45` |
| Final utilization after route | `0.5669` |
| Open signal nets | `0` |
| Route DRC total | `59` |
| Route DRC classes | `1` diff-net spacing, `57` off-grid, `1` short |
| Antenna | no antenna rules defined |
| Legality | `TOTAL 0 Violations` |
| Setup QoR | worst setup slack `5.60 ns`, setup violating paths `0` |
| Hold QoR | worst about `-0.10 ns`; still open |
| PG DRC | `No errors found` |
| VDD connectivity | `7` floating wires, `4447` floating std cells |
| VSS connectivity | `7` floating wires, `4002` floating std cells |
| Max transition/cap violations | `307 / 2018` |
| Disposition | Improved versus the 55% VIA1 no-track trial, but not route clean. Lower utilization alone is insufficient. |

## Sibling SAED32 Backend Reference Matrix

| Reference | Relevant Result | MNIST Impact |
| --- | --- | --- |
| ibex RUN_MANIFEST | VIA1 pitch/no-track plus upstream cell-use policy reached `0` open nets and `0` signal DRC | Confirms SAED32 lower-metal physical-library policy can be decisive, but MNIST must validate locally. |
| CV32E40P route root-cause investigation | M9 did not solve lower-metal DRC and worsened one trial | Do not prioritize upper-layer routing as the next MNIST experiment. |
| CV32E40P trim_all_pin NDM | `configure_frame_options -mode keep_obs_and_trim_all_pin` reduced a 67-DRC candidate to 1 DRC | Build the same NDM frame policy for MNIST before broader synthesis reruns. |

## ICC2 libdir VIA1 no-track trim_all_pin 45% Utilization Route Trial

| Metric | Value |
| --- | --- |
| NDM build command | `4_Backend_ICC2/0_Script/00_setup/build_saed32_rvt_ndm_libdir_via1_no_track_trim_all_pin.sh` |
| NDM build result | PASS; workspace check succeeded and RVT NDM was written |
| Backend command | `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 4_Backend_ICC2/0_Script/99_util/run_libdir_via1_no_track_trim_all_pin_util45_backend_flow.sh` |
| Backend status | COMPLETED_ROUTE_NOT_CLEAN |
| Trial reference library | `4_Backend_ICC2/2_Output/00_setup/ndm_libdir_via1_no_track_trim_all_pin/saed32rvt_tt.ndm` |
| Preserved trial design library | `4_Backend_ICC2/2_Output/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/mnist_npu_icc2_lib` |
| Report root | `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3` |
| Saved blocks available | `nn_top`, `floorplan`, `powerplan`, `placement`, `cts`, `route_auto`, `route` |
| Open signal nets | `0` |
| Route DRC total | `6` |
| Route DRC classes | `6` off-grid |
| Antenna | no antenna rules defined; not proven clean |
| Legality | `TOTAL 0 Violations` |
| Setup QoR | worst setup slack `5.61 ns`, setup violating paths `0` |
| Hold QoR | worst `-0.10 ns`, total `-322.94`, violations `26158` |
| Final utilization after route | `0.5669` |
| PG DRC | `No errors found` in route log |
| VDD connectivity | `7` floating wires, `4447` floating std cells |
| VSS connectivity | `7` floating wires, `4002` floating std cells |
| Max transition/cap violations | `317 / 2006` |
| Cell area | `774796.61` |
| Net length | `7028986.22` |
| Disposition | Best preserved full-flow route database, but not clean. Route DRC, PG connectivity, hold, antenna-rule coverage, and electrical closure remain open. |
| Rerun note | `rerun2` reports also showed `6` route DRC, but its saved route DB was later overwritten by a no-CCD diagnostic route. Use `rerun3` for database-based debug. |

## ICC2 trim_all_pin util45 Route ECO Off-grid Trial

| Metric | Value |
| --- | --- |
| Command | `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 ROUTE_ECO_TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3_eco_offgrid1 ROUTE_ECO_OUTPUT_BLOCK=route_eco_offgrid1 4_Backend_ICC2/0_Script/06_route/run_libdir_via1_no_track_route_eco_offgrid1.sh` |
| Input block | `mnist_npu_icc2_lib:route.design` in the rerun3 trial library |
| Output block | `mnist_npu_icc2_lib:route_eco_offgrid1.design` |
| Pre-check DRC | `6` M1 off-grid, `0` open signal nets |
| Final post-check DRC | `5` M1 off-grid, `0` open signal nets |
| ECO changed nets | `81` |
| ECO convergence | best intermediate DRC `4`; stopped as not converging; final official post-check `5` |
| Residual objects after ECO | `ZBUF_832_2538`, `ZBUF_714_1050` twice, `ZBUF_851_152`, `n143522` |
| Cleared original objects | `n130475`, `ZBUF_766_3067` no longer appear in the ECO residual list |
| Legality | `TOTAL 0 Violations` |
| Setup QoR | worst setup slack `5.61 ns`, setup violating paths `0` |
| Hold QoR | worst `-0.10 ns`, total `-322.94`, violations `26158` |
| PG DRC | `No errors found` |
| PG connectivity | unchanged: VDD `4447` floating std cells, VSS `4002` floating std cells |
| Max transition/cap violations | `317 / 2006` |
| Disposition | Partial route-only repair and current lowest DRC count, but not clean and not a full-flow replacement. |

## ICC2 trim_all_pin util45 Targeted Route-DRC Clean Candidate

| Metric | Value |
| --- | --- |
| Command | `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 SEQ_ROUTE_PROBE_NAME=seq_size_swap_dff2_oa1_move_u77942_xp152_pintrack_clean_save1 SEQ_ROUTE_INPUT_BLOCK=route_eco_offgrid1 SEQ_ROUTE_OUTPUT_BLOCK=route_seq_size_swap_dff2_oa1_move_u77942_xp152_pintrack SEQ_SIZE_SWAPS='act_ram_reg[861][0]=DFFARX2_RVT;U77942=OA221X1_RVT' SEQ_CELL_MOVES='U77942=0.152,0' SEQ_ROUTE_STEPS='ZBUF_714_1050;ZBUF_851_152;@swap_pin_nets;ZBUF_832_2538;n143522' SEQ_ROUTE_ITERATIONS=120 SEQ_ROUTE_SAVE=1 SEQ_ROUTE_SAVE_ON_CLEAN_ONLY=1 4_Backend_ICC2/0_Script/06_route/probe_sequential_local_offgrid_route.sh` |
| Input block | `mnist_npu_icc2_lib:route_eco_offgrid1.design` in the rerun3 trial library |
| Saved output block | `mnist_npu_icc2_lib:route_seq_size_swap_dff2_oa1_move_u77942_xp152_pintrack.design` |
| Report root | `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/06_route_seq_size_swap_dff2_oa1_move_u77942_xp152_pintrack_clean_save1` |
| Saved-block recheck root | `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/06_route_seq_size_swap_dff2_oa1_move_u77942_xp152_saved_recheck` |
| Targeted size swaps | `act_ram_reg[861][0]: DFFARX1_RVT -> DFFARX2_RVT`; `U77942: OA221X2_RVT -> OA221X1_RVT` |
| Targeted move | `U77942` moved `+0.152um` in X; origin `249.6720 854.3280 -> 249.8240 854.3280` |
| Final route DRC/open | `0` route DRCs, `0` open signal nets |
| Saved-block recheck | `check_routes.recheck.rpt` confirms `0` route DRCs and `0` open signal nets |
| DRC extraction after recheck | `drc.errors.tsv` and `drc.offgrid.tsv` contain only headers |
| Legality | `TOTAL 0 Violations` |
| Setup QoR | `clk` critical path slack `5.61 ns`, setup violating paths `0` |
| Hold QoR | worst `-0.10 ns`, total `-322.90`, violations `26153` |
| PG DRC | `No errors found` in run log |
| PG connectivity | still open: VDD has `7` floating wires and `4447` floating std cells; VSS has `7` floating wires and `4002` floating std cells |
| Max transition/cap violations | `318 / 2009` |
| Antenna | no antenna rules defined; not proven clean |
| Disposition | Current best saved signal-route candidate. Not a complete backend clean baseline because PG connectivity, hold, antenna-rule coverage, and electrical closure remain open. |

## ICC2 PG Rail Connectivity Repair Probe Summary

| Probe | PG Connectivity | PG DRC | Signal Route DRC/Open | Disposition |
| --- | --- | --- | --- | --- |
| Reapply existing PG strategies from routed block | Worse: `14` floating wires per supply, VDD `4447` floating std cells, VSS `4002` floating std cells | clean | route DRC stayed clean in check | Not adopted; created wires but no missing rail-to-mesh vias |
| Floating rail inspection | Identified 7 isolated M1 rails per supply | not a repair | not a repair | Confirms isolated one-wire/zero-via rail subnetworks are the PG issue |
| Direct M1-M2 VIA12, normal DRC mode | unchanged because candidates were removed | clean | unchanged | Not adopted; tool DRC mode rejected candidates |
| Direct M1-M2 VIA12, `no_check` | clean: zero floating wires/vias/std cells | `580` PG DRC errors | `0` route DRC, `0` open nets | Not adopted; fixes connectivity but violates PG cut spacing |
| M1-M7 ladders at `x=50.0`, all floating rails, `no_check` | clean: zero floating wires/vias/std cells | clean | `24` route DRCs, VSS-side collisions | Not adopted; good PG topology but signal route not clean |
| VSS-only M1-M7 ladders at `x=30.0`, `no_check` | VSS clean for probed rails; VDD intentionally still open | clean | `20` route DRCs | Not adopted; continue VSS X-coordinate search |
| Combined M1-M7 ladders: VDD `x=50.0`, VSS `x=20.0`, `PATH_11_507` override `x=55.0` half-box `0.15` | clean: zero floating wires/vias/std cells/terminals for VDD and VSS | clean | `0` route DRC, `0` open signal nets | Saved as `route_pg_ladder_vdd50_vss20_path507x55_h015`; current best route-plus-PG clean candidate |

## ICC2 Route Plus PG Clean Candidate

| Metric | Value |
| --- | --- |
| Input block | `mnist_npu_icc2_lib:route_seq_size_swap_dff2_oa1_move_u77942_xp152_pintrack.design` |
| Saved output block | `mnist_npu_icc2_lib:route_pg_ladder_vdd50_vss20_path507x55_h015.design` |
| Repair command | `env PG_LADDER_NAME=pg_ladder_vdd50_vss20_path507x55_h015_save1 PG_LADDER_SAVE=1 PG_LADDER_OUTPUT_BLOCK=route_pg_ladder_vdd50_vss20_path507x55_h015 PG_LADDER_DRC_MODE=no_check PG_LADDER_VDD_X=50.0 PG_LADDER_VSS_X=20.0 PG_LADDER_VDD_HALF_BOX=0.25 PG_LADDER_VSS_HALF_BOX=0.25 PG_LADDER_SHAPE_OVERRIDES='PATH_11_507=55.0,0.15' 4_Backend_ICC2/0_Script/03_powerplan/repair_pg_floating_rail_ladders.sh` |
| Repair report root | `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/03_powerplan_pg_ladder_vdd50_vss20_path507x55_h015_save1` |
| Saved-block recheck root | `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/06_route_pg_ladder_vdd50_vss20_path507x55_h015_saved_recheck` |
| Ladder vias created | `84` |
| Route DRC/open after saved-block recheck | `0` route DRCs, `0` open signal nets |
| DRC extraction after recheck | `drc.errors.tsv` and `drc.offgrid.tsv` contain only headers |
| PG connectivity after saved-block recheck | VDD and VSS each report `0` floating wires, `0` floating vias, `0` floating standard cells, and `0` floating terminals |
| PG DRC after saved-block recheck | `pg_drc.rpt` has no error body; run log reports no PG DRC errors |
| Legality after saved-block recheck | `TOTAL 0 Violations` |
| Disposition | Current best saved route-plus-PG clean candidate. Not a complete backend clean baseline because hold, max transition/capacitance, and antenna-rule coverage remain open. |

## ICC2 Post-Route Extraction From Route Plus PG Candidate

| Metric | Value |
| --- | --- |
| Input block | `mnist_npu_icc2_lib:route_pg_ladder_vdd50_vss20_path507x55_h015.design` |
| Command | `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 EXTRACT_NAME=07_extract_sta_pg_ladder_vdd50_vss20_path507x55_h015 EXTRACT_INPUT_BLOCK=route_pg_ladder_vdd50_vss20_path507x55_h015 4_Backend_ICC2/0_Script/07_extract_sta/run_post_route_extract_sta.sh` |
| Log path | `4_Backend_ICC2/3_Log/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_pg_ladder_vdd50_vss20_path507x55_h015/run.log` |
| Report root | `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_pg_ladder_vdd50_vss20_path507x55_h015` |
| Report command status | Required reports pass; optional `report_analysis_coverage` is `OPTIONAL_FAIL` and not used as a checkpoint criterion |
| Route DRC/open | `0` route DRCs, `0` open signal nets |
| PG connectivity | VDD and VSS each report `0` floating wires, `0` floating vias, `0` floating standard cells, and `0` floating terminals |
| PG DRC | `No errors found` in ICC2 run log |
| Legality | `TOTAL 0 Violations` |
| Setup timing | setup slack `5.61 ns`, TNS `0.00`, setup violating paths `0` |
| Hold timing | WNS `-0.10 ns`, TNS `-322.90 ns`, hold violations `26153` |
| Electrical DRC | `318` max transition violations, `2009` max capacitance violations, `2039` nets with violations |
| Antenna | not proven; reports state `no antenna rules defined` |
| Disposition | Post-route extraction checkpoint complete, but backend baseline remains open on hold, electrical, and antenna-rule coverage. |

## ICC2 Broad Post-Route route_opt Trial

| Metric | Value |
| --- | --- |
| Input block | `mnist_npu_icc2_lib:route_pg_ladder_vdd50_vss20_path507x55_h015.design` |
| Saved output block | `mnist_npu_icc2_lib:route_pg_ladder_route_opt1.design` |
| Command | `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 ROUTE_OPT_NAME=07_extract_sta_route_opt1 ROUTE_OPT_INPUT_BLOCK=route_pg_ladder_vdd50_vss20_path507x55_h015 ROUTE_OPT_OUTPUT_BLOCK=route_pg_ladder_route_opt1 4_Backend_ICC2/0_Script/07_extract_sta/run_post_route_route_opt_trial.sh` |
| Log path | `4_Backend_ICC2/3_Log/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_route_opt1/run.log` |
| Report root | `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_route_opt1` |
| Report command status | `report_status.tsv` shows required route, legality, PG, timing, electrical, and save steps completed |
| Route DRC/open | `26` route DRCs, `43` open signal nets |
| PG connectivity | VDD and VSS each report `0` floating wires, `0` floating vias, `0` floating standard cells, and `0` floating terminals |
| PG DRC | `No errors found` in ICC2 run log |
| Legality | `TOTAL 0 Violations` |
| Setup timing | setup violating paths `0` |
| Hold timing | WNS `-0.02 ns`, TNS `-0.38 ns`, hold violations `293` |
| Electrical DRC | `673` max transition violations, `2181` max capacitance violations, `2271` nets with violations |
| Antenna | not proven; reports state `no antenna rules defined` |
| Disposition | Completed but not adopted. Hold improved substantially, but route DRC/open and electrical results fail the handoff criteria. Continue from `route_pg_ladder_vdd50_vss20_path507x55_h015`. |

## ICC2 Open-Site Hold ECO Trial

| Metric | Value |
| --- | --- |
| Input block | `mnist_npu_icc2_lib:route_pg_ladder_vdd50_vss20_path507x55_h015.design` |
| Saved output block | `mnist_npu_icc2_lib:route_pg_ladder_hold_eco_open_site_m0.design` |
| Command | `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 HOLD_ECO_NAME=07_extract_sta_hold_eco_open_site_m0 HOLD_ECO_INPUT_BLOCK=route_pg_ladder_vdd50_vss20_path507x55_h015 HOLD_ECO_OUTPUT_BLOCK=route_pg_ladder_hold_eco_open_site_m0 HOLD_MARGIN=0.00 PHYSICAL_MODE=open_site 4_Backend_ICC2/0_Script/07_extract_sta/run_post_route_hold_eco_trial.sh` |
| Log path | `4_Backend_ICC2/3_Log/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_hold_eco_open_site_m0/run.log` |
| Report root | `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_hold_eco_open_site_m0` |
| Output root | `4_Backend_ICC2/2_Output/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_hold_eco_open_site_m0` |
| ECO command | `eco_opt -types hold -hold_margin 0.00 -physical_mode open_site` |
| PrimeTime ECO edits | `23584` hold buffer insertions, `84` size-cell commands |
| Inserted hold buffers | `19793` `NBUFFX2_RVT`, `2841` `DELLN1X2_RVT`, `950` `NBUFFX4_RVT` |
| Route DRC/open before ECO | `0` route DRCs, `0` open signal nets |
| Route DRC/open after ECO | `3` route DRCs, `0` open signal nets |
| Route DRC classes after ECO | `1` off-grid, `2` shorts |
| PG connectivity | VDD and VSS each report `0` floating wires, `0` floating vias, `0` floating standard cells, and `0` floating terminals |
| PG DRC | no PG DRC error body; ICC2 run log reports `No errors found` |
| Legality | `TOTAL 0 Violations` |
| Setup timing | setup slack `5.61 ns`, TNS `0.00`, setup violating paths `0` |
| Hold timing | WNS `-0.05 ns`, TNS `-15.61 ns`, hold violations `4472` |
| Electrical DRC | `328` max transition violations, `2116` max capacitance violations, `2142` nets with violations |
| Antenna | not proven; reports state `no antenna rules defined` |
| Disposition | Completed but not adopted. This is the best hold-improved near-route-clean candidate, but route DRC, hold, electrical, and antenna-rule coverage remain open. |

## ICC2 Open-Site Hold ECO Residual Route Repair

| Metric | Value |
| --- | --- |
| Input block | `mnist_npu_icc2_lib:route_pg_ladder_hold_eco_open_site_m0.design` |
| Saved output block | `mnist_npu_icc2_lib:route_pg_ladder_hold_eco_open_site_m0_route_repair1.design` |
| Residual debug root | `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_hold_eco_open_site_m0_residual_route_debug` |
| Repair command | `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 SEQ_ROUTE_PROBE_NAME=hold_eco_open_site_m0_residual_route_repair1 SEQ_ROUTE_INPUT_BLOCK=route_pg_ladder_hold_eco_open_site_m0 SEQ_ROUTE_OUTPUT_BLOCK=route_pg_ladder_hold_eco_open_site_m0_route_repair1 SEQ_ROUTE_STEPS='u_input_fifo/fifo_buf[1015][7] u_input_fifo/n3339;eco_net_682_u_input_fifo/n2310 eco_net_1102_u_input_fifo/n3334' SEQ_ROUTE_ITERATIONS=160 SEQ_ROUTE_SAVE=1 SEQ_ROUTE_SAVE_ON_CLEAN_ONLY=1 4_Backend_ICC2/0_Script/06_route/probe_sequential_local_offgrid_route.sh` |
| Repair log path | `4_Backend_ICC2/3_Log/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/06_route_hold_eco_open_site_m0_residual_route_repair1/run.log` |
| Repair report root | `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/06_route_hold_eco_open_site_m0_residual_route_repair1` |
| Saved-block recheck command | `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 ROUTE_DEBUG_SUBDIR=07_extract_sta_hold_eco_open_site_m0_route_repair1_saved_recheck ROUTE_DEBUG_INPUT_BLOCK=route_pg_ladder_hold_eco_open_site_m0_route_repair1 4_Backend_ICC2/0_Script/06_route/debug_libdir_via1_no_track_route_residuals.sh` |
| Saved-block recheck root | `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_hold_eco_open_site_m0_route_repair1_saved_recheck` |
| Residual DRC before repair | `3` route DRCs, `0` open signal nets: `1` M1 off-grid and `2` M2 shorts |
| Repair sequence result | `summary.tsv` reports initial `3/0`, after step1 `0/0`, after step2 `0/0`, final save status `saved` |
| Route DRC/open after saved-block recheck | `0` route DRCs, `0` open signal nets |
| DRC extraction after recheck | `drc.errors.tsv` and `drc.offgrid.tsv` contain only headers |
| PG connectivity after recheck | VDD and VSS each report `0` floating wires, `0` floating vias, `0` floating standard cells, and `0` floating terminals |
| PG DRC after recheck | `No errors found` in ICC2 run log |
| Legality after recheck | `TOTAL 0 Violations` |
| Setup timing | setup slack `5.61 ns`, TNS `0.00`, setup violating paths `0` |
| Hold timing | WNS `-0.05 ns`, TNS `-15.61 ns`, hold violations `4472` |
| Electrical DRC | `328` max transition violations, `2116` max capacitance violations, `2142` nets with violations |
| Antenna | not proven; reports state `no antenna rules defined` |
| Disposition | Current best route-plus-PG and hold-improved candidate. Not a complete backend clean baseline because hold, electrical, and antenna-rule coverage remain open. |

## ICC2 PG Connectivity Debug Conclusions

| Observation | Evidence | Current Interpretation |
| --- | --- | --- |
| Floating PG rails are specific M1 standard-cell rails | `03_powerplan_pg_islands1/m1_pg_rails.tsv`, `pg_connectivity_detail` reports | Seven VDD rails and seven VSS rails are isolated one-wire/zero-via subnetworks |
| Cell pins physically overlap the floating rails | `06_route_pg_unconn_cells1` target-cell reports | The issue is not that cells miss the rail geometry; the rails lack connection to the upper PG mesh |
| Missing via count matches powerplan cleanup | Initial `03_powerplan/run.log` removed `406` dangling/floating vias; forced VIA12 repair created `406` vias | Early pre-placement PG cleanup removed vias on rails that later became populated by placed cells |
| Direct rail-to-M2 via repair is not legal | `03_powerplan_pg_via12_nocheck1/pg_drc.after.rpt` reports `580` PG DRC errors | Existing M2-M3 strap via stacks block direct VIA12 insertion at the strap intersections |
| M1-M7 ladders can make PG clean | `03_powerplan_pg_ladder_x50_nocheck2/pg_connectivity.after.rpt` and `pg_drc.after.rpt` | Ladder topology is promising, but X location must avoid signal route collisions before saving |
| Combined PG repair is saved and rechecked | `06_route_pg_ladder_vdd50_vss20_path507x55_h015_saved_recheck` reports route DRC/open `0/0`, PG floating counts `0`, PG DRC clean, and legality `0` | Continue from `route_pg_ladder_vdd50_vss20_path507x55_h015` for timing/electrical/antenna closure |

## ICC2 Route Debug Conclusions

| Observation | Evidence | Current Interpretation |
| --- | --- | --- |
| Baseline DRC is lower-metal/contact dominated | `4_Backend_ICC2/4_Report/06_route/drc_debug/drc.matrix.rpt` | Root cause is likely SAED32 pin access/VIA1/contact legality plus congestion, not a single local route error. |
| Simple route ECO is weak | DRC `738` to `709` in `06_route_eco_drc1/check_routes.post.rpt` | Do not spend more time on generic ECO reroute before changing the physical setup or placement conditions. |
| VIA1 no-track physical setup is effective for contact DRC | Needs-fat-contact `183` to `0`, short `26` to `0` | The sibling-project library-policy fix applies partially to MNIST. |
| Residual trial DRC is mostly off-grid | `72` of `77` final DRCs are off-grid | Next debug should inspect residual off-grid objects/locations before broad reruns. |
| trim_all_pin util45 is the best full-flow route-DRC candidate | rerun3 route reports `0` open signal nets and `6` off-grid DRCs | Continue residual off-grid debug from the preserved rerun3 route DB, but do not claim clean closure. |
| Route-only ECO gives only partial additional repair | ECO reduced official DRC from `6` to `5` and then stopped as not converging | Do not assume generic ECO will close the remaining off-grid DRCs without another targeted change. |
| Targeted pin-access repair closes signal route DRC | saved candidate recheck reports `0` open signal nets and `0` route DRCs | Route DRC/open objective is closed for the saved candidate, but PG/timing/electrical/antenna closure remains separate. |
| PG connectivity is separate from signal DRC | The earlier signal-route clean block still had thousands of floating std cells, while the later PG ladder block fixes PG connectivity without route DRC regression | Use `route_pg_ladder_vdd50_vss20_path507x55_h015` as the current route-plus-PG candidate; do not use the earlier signal-route-only block as PG-clean evidence. |
| Broad post-route `route_opt` over-repairs hold | `07_extract_sta_route_opt1` reduces hold violations from `26153` to `293`, but leaves `43` open signal nets, `26` route DRCs, and worsened electrical counts | Do not adopt broad `route_opt`; next timing cleanup should be narrower hold ECO with route/PG/electrical rechecks after each candidate. |
| Open-site hold ECO is closer to route-clean | `07_extract_sta_hold_eco_open_site_m0` reduces hold TNS from `-322.90 ns` to `-15.61 ns` and leaves only `3` route DRCs with `0` open nets | Keep it as a partial candidate; debug the three residual route DRCs before using it as the next timing/electrical base. |

## ICC2 libdir/LEF/modify NDM Trial Summary

| Metric | Baseline EDK RVT NDM | libdir/LEF/modify RVT NDM |
| --- | --- | --- |
| NDM build | PASS | PASS |
| Init link/check_design errors | `0` | `0` |
| Placement legality | `TOTAL 0 Violations` | `TOTAL 0 Violations` |
| PG DRC | `No errors found` | `No errors found` |
| Setup QoR | `5.26 ns`, setup violating paths `0` | `5.31 ns`, setup violating paths `0` |
| Hold QoR | worst `-0.01 ns`, total `-1.02`, violations `180` | worst `-0.01 ns`, total `-0.93`, violations `184` |
| VDD connectivity | `7` floating wires, `3985` floating std cells, `8` floating terminals | `7` floating wires, `4041` floating std cells, `0` floating terminals |
| VSS connectivity | `7` floating wires, `3405` floating std cells | `7` floating wires, `3533` floating std cells |
| Phase1 global-route overflow | `45036`, max `5`, GRCs `36186 (4.20%)` | `46959`, max `5`, GRCs `38099 (4.42%)` |
| Routing density over target | horizontal `38.28%`, vertical `6.22%` | horizontal `38.48%`, vertical `6.22%` |
| Max transition/cap violations | `3394 / 21531` | `3352 / 21557` |
| Disposition | First baseline | Completed but not adopted |
