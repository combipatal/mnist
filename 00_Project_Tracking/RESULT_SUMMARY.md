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
| CTS | PENDING | TBD |
| Route | PENDING | TBD |

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
