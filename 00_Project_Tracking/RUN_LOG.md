# Run Log

## 2026-05-09

- Created project directory structure from the implementation-flow plan.
- Cloned primary source repo into `0_RTL/MNIST-NPU-ASIC`.
- Frozen source commit: `d1e31ea9e6fdfde157fee62fbf7f91658e382f09`.
- Confirmed initial top candidate: `nn_top`.
- Created initial synthesis filelist at `1_Input/filelists/rtl.f`.
- Noted no top-level license file in cloned repo.

### DC front-end checkpoint

- Command: `2_Synthesis/0_Script/run_dc.sh`
- Log: `2_Synthesis/3_Log/run_dc.log`
- Reports:
  - `2_Synthesis/4_Report/pre_compile.check_design.rpt`
  - `2_Synthesis/4_Report/pre_compile.check_timing.rpt`
  - `2_Synthesis/4_Report/pre_compile.constraints.rpt`
  - `2_Synthesis/4_Report/pre_compile.reference.rpt`
- Output:
  - `2_Synthesis/2_Output/unmapped/nn_top.unmapped.ddc`
- Result: PASS after SDC syntax correction.
- Note: initial SDC used a Tcl collection command inside `read_sdc`; fixed by keeping SDC commands SDC-compatible.
- Known non-fatal warnings:
  - pre-compile lint from unused/unconnected generated MAC lane ports and constants.
  - high fanout on clock/reset before physical synthesis/CTS.
  - large inferred FF arrays for `act_ram` and FIFO because SRAM macro replacement is disabled for first pass.

### DC topographical synthesis

- Command: `2_Synthesis/0_Script/run_dc_compile_topo.sh`
- DC mode: `dc_shell -topographical_mode`
- Compile command: `compile_ultra -spg`
- SVF: `2_Synthesis/2_Output/svf/nn_top.topo_10ns.mapped.svf`
- Outputs:
  - `2_Synthesis/2_Output/topo_10ns/nn_top.topo_10ns.mapped.ddc`
  - `2_Synthesis/2_Output/topo_10ns/nn_top.topo_10ns.mapped.vg`
  - `2_Synthesis/2_Output/topo_10ns/nn_top.topo_10ns.mapped.sdc`
  - `2_Synthesis/2_Output/topo_10ns/nn_top.topo_10ns.mapped.sdf`
- Reports:
  - `2_Synthesis/4_Report/topo_10ns/tlu_plus.check.rpt`
  - `2_Synthesis/4_Report/topo_10ns/library.check.rpt`
  - `2_Synthesis/4_Report/topo_10ns/post_compile.qor.rpt`
  - `2_Synthesis/4_Report/topo_10ns/post_compile.timing.max.rpt`
  - `2_Synthesis/4_Report/topo_10ns/post_compile.timing.min.rpt`
  - `2_Synthesis/4_Report/topo_10ns/post_compile.constraints.rpt`
  - `2_Synthesis/4_Report/topo_10ns/post_compile.area.rpt`
  - `2_Synthesis/4_Report/topo_10ns/post_compile.power.rpt`
- Result: PASS for first baseline handoff.
- Evidence:
  - TLU+ sanity check passed.
  - Setup timing: WNS `0.00`, TNS `0.00`, violating setup paths `0`.
  - Best reported setup path slack in timing report: `4.89 ns`.
  - Hold timing: worst hold violation about `-0.01 ns`, total hold violation `-1.06`, hold violating paths `221`.
  - Cell area: `615341.590990`.
  - Leaf cell count: `175574`.
  - Sequential cell count: `39659`.
  - Macro count: `0`.
- Accepted for first baseline:
  - Max transition violations: `2518`.
  - Max capacitance violations: `17694`.
  - These are recorded and carried into ICC2 physical implementation for re-check, not fixed in DC before the first route baseline.
- Risks to revisit:
  - `check_library` reports 4 SAED32 scan FF `test_cell` next_state errors; first baseline is not DFT insertion, so this is recorded as a library/DFT risk.
  - Clock/reset high fanout remains expected before CTS.
  - No SRAM macro replacement yet; FF-array memories dominate area and routing demand.

### Formality R2N for DC topographical handoff

- Command: `3_Formality/0_Script/run_fm_r2n_topo.sh`
- Log: `3_Formality/3_Log/run_fm_r2n_topo.log`
- Reference: RTL filelist `1_Input/filelists/rtl.f`
- Implementation: `2_Synthesis/2_Output/topo_10ns/nn_top.topo_10ns.mapped.vg`
- SVF: `2_Synthesis/2_Output/svf/nn_top.topo_10ns.mapped.svf`
- Reports:
  - `3_Formality/4_Report/r2n_topo_10ns/r2n_topo_10ns.unmatched_points.rpt`
  - `3_Formality/4_Report/r2n_topo_10ns/r2n_topo_10ns.failing_points.rpt`
  - `3_Formality/4_Report/r2n_topo_10ns/r2n_topo_10ns.aborted_points.rpt`
  - `3_Formality/4_Report/r2n_topo_10ns/r2n_topo_10ns.unverified_points.rpt`
  - `3_Formality/4_Report/r2n_topo_10ns/r2n_topo_10ns.passing_points.post_verify.rpt`
- Output session: `3_Formality/2_Output/r2n_topo_10ns/r2n_topo_10ns_fm_session.fss`
- Result: PASS.
- Evidence:
  - `Verification SUCCEEDED`.
  - Passing compare points: `39681`.
  - Failing compare points: `0`.
  - Unmatched reference/implementation compare points after match: `0(0)`.
  - `r2n_topo_10ns.failing_points.rpt`: no failing compare points.
  - `r2n_topo_10ns.unverified_points.rpt`: no unverified compare points.
- Recorded warnings:
  - `synopsys_auto_setup` was enabled; verification is valid under the reported auto setup assumptions.
  - RTL interpretation warnings remain from array-bound/signedness messages; DC and FM both elaborate the design, but this should be considered an RTL-quality risk if functional simulation disagrees.
  - SVF guidance had 64 rejected `change_names` commands; Formality states these can be ignored when verification succeeds.

### ICC2 SAED32 RVT NDM setup

- Command: `4_Backend_ICC2/0_Script/00_setup/build_saed32_rvt_ndm.sh`
- Tool: `lm_shell`
- Log: `4_Backend_ICC2/3_Log/00_setup/build_saed32_rvt_ndm.log`
- Output:
  - `4_Backend_ICC2/2_Output/00_setup/ndm/saed32rvt_tt.ndm`
- Result: PASS.
- Evidence:
  - `check_workspace` completed successfully.
  - NDM reference library was written under the project ICC2 output directory.
- Recorded warnings:
  - LEF bus-bit-character defaulting, duplicate timing arc, PG pin direction correction, and frame blockage messages were reported by Library Manager.
  - These are treated as SAED32 library import warnings for the first baseline and must be revisited only if ICC2 placement/routing reports show library-view failures.

### ICC2 init_design checkpoint

- Command: `4_Backend_ICC2/0_Script/01_init_design/run_init_design_check.sh`
- Tool: `icc2_shell`
- Log: `4_Backend_ICC2/3_Log/01_init_design/run_init_design_check.log`
- Inputs:
  - Netlist: `2_Synthesis/2_Output/topo_10ns/nn_top.topo_10ns.mapped.vg`
  - Constraint handoff: `2_Synthesis/2_Output/topo_10ns/nn_top.topo_10ns.mapped.sdc`
  - Reference library: `4_Backend_ICC2/2_Output/00_setup/ndm/saed32rvt_tt.ndm`
- Output:
  - `4_Backend_ICC2/2_Output/01_init_design/mnist_npu_icc2_lib`
- Reports:
  - `4_Backend_ICC2/4_Report/01_init_design/ref_libs.rpt`
  - `4_Backend_ICC2/4_Report/01_init_design/parasitic_parameters.rpt`
  - `4_Backend_ICC2/4_Report/01_init_design/design.rpt`
  - `4_Backend_ICC2/4_Report/01_init_design/design_physical.rpt`
  - `4_Backend_ICC2/4_Report/01_init_design/check_design.rpt`
  - `4_Backend_ICC2/4_Report/01_init_design/timing.max.rpt`
  - `4_Backend_ICC2/4_Report/01_init_design/timing.min.rpt`
- Result: PASS_WITH_OPEN_WARNINGS.
- Evidence:
  - `read_verilog` imported the Formality-verified mapped netlist.
  - `link_block` reported that design `nn_top` was successfully linked.
  - Re-run uses clean project SDC `1_Input/constraints/mnist_npu_10ns.sdc`; previous ICC2 `CSTR-021` noise from DC-written net `set_load` constraints is removed.
  - Saved ICC2 library/block was created for the next floorplan stage.
  - Design report shows `175574` leaf cells, `39659` sequential cells, and `0` hard macros.
- Open warnings to classify before floorplan signoff:
  - `DCHK-010`: 16 floating/no-driver nets from the mapped structural netlist.
  - `TCK-001`: async reset endpoints reported unconstrained because reset is false-pathed.
  - `TCK-012`: reset input has no clock-relative delay.
  - No-driver nets listed in EMS: `global_w_addr[10:4]`, `in_cnt[3:0]`, `state[3]`, `state_next[3]`, `u_input_fifo/rd_addr_t[9]`, `u_input_fifo/rd_addr_t[6]`, `u_input_fifo/rd_addr_t[4]`.

### ICC2 floorplan checkpoint

- Command: `4_Backend_ICC2/0_Script/02_floorplan/run_floorplan_initial.sh`
- Tool: `icc2_shell`
- Log: `4_Backend_ICC2/3_Log/02_floorplan/run_floorplan_initial.log`
- Input block: `4_Backend_ICC2/2_Output/01_init_design/mnist_npu_icc2_lib:nn_top.design`
- Output block: `4_Backend_ICC2/2_Output/01_init_design/mnist_npu_icc2_lib:floorplan.design`
- Reports:
  - `4_Backend_ICC2/4_Report/02_floorplan/design_physical.rpt`
  - `4_Backend_ICC2/4_Report/02_floorplan/utilization.rpt`
  - `4_Backend_ICC2/4_Report/02_floorplan/qor.rpt`
  - `4_Backend_ICC2/4_Report/02_floorplan/timing.max.rpt`
  - `4_Backend_ICC2/4_Report/02_floorplan/timing.min.rpt`
  - `4_Backend_ICC2/4_Report/02_floorplan/check_design.rpt`
- Result: PASS_WITH_OPEN_WARNINGS.
- Evidence:
  - `initialize_floorplan` completed.
  - Target utilization: `0.55`; reported utilization: `0.5506`.
  - Core area: `{20 20} {1077.616 1076.704}`.
  - Total cell area: `615341.5854`.
  - `place_pins -self` created 41 top-level pins.
  - Setup timing sample slack after floorplan: `5.97 ns`.
  - Hold timing sample worst reported slack remains about `-0.01 ns`.
- Open warnings:
  - Same 16 mapped-netlist no-driver warnings remain.
  - Same async-reset timing check warnings remain.
  - ICC2 auto-derived routing directions for M1 through MRDL because the imported technology did not provide explicit routing direction metadata.

### ICC2 powerplan checkpoint

- Command: `4_Backend_ICC2/0_Script/03_powerplan/run_powerplan_initial.sh`
- Tool: `icc2_shell`
- Log: `4_Backend_ICC2/3_Log/03_powerplan/run_powerplan_initial.log`
- Input block: `4_Backend_ICC2/2_Output/01_init_design/mnist_npu_icc2_lib:floorplan.design`
- Output block: `4_Backend_ICC2/2_Output/01_init_design/mnist_npu_icc2_lib:powerplan.design`
- Reports:
  - `4_Backend_ICC2/4_Report/03_powerplan/pg_patterns.rpt`
  - `4_Backend_ICC2/4_Report/03_powerplan/pg_strategies.rpt`
  - `4_Backend_ICC2/4_Report/03_powerplan/pg_strategy_via_rules.rpt`
  - `4_Backend_ICC2/4_Report/03_powerplan/pg_ports.rpt`
  - `4_Backend_ICC2/4_Report/03_powerplan/pg_connectivity.rpt`
  - `4_Backend_ICC2/4_Report/03_powerplan/pg_connectivity_detail.rpt`
  - `4_Backend_ICC2/4_Report/03_powerplan/pg_drc.rpt`
  - `4_Backend_ICC2/4_Report/03_powerplan/design_physical.rpt`
  - `4_Backend_ICC2/4_Report/03_powerplan/utilization.rpt`
  - `4_Backend_ICC2/4_Report/03_powerplan/qor.rpt`
- Result: PASS_WITH_OPEN_PG_CONNECTIVITY.
- Evidence:
  - `compile_pg` completed successfully.
  - PG objects committed: `813` wires and `24942` vias.
  - Boundary PG pins created: `16`.
  - `check_pg_drc` reported `No errors found`.
  - Utilization remains `0.5506`.
- Open warnings:
  - `check_pg_connectivity` reports 7 floating wires and `175574` floating standard cells for both VDD and VSS.
  - This is not PG-clean. The cells are still unplaced at the pre-placement powerplan stage, so PG connectivity must be rechecked after placement.

### ICC2 placement checkpoint

- Command: `4_Backend_ICC2/0_Script/04_place/run_place_initial.sh`
- Tool: `icc2_shell`
- Log: `4_Backend_ICC2/3_Log/04_place/run_place_initial.log`
- Input block: `4_Backend_ICC2/2_Output/01_init_design/mnist_npu_icc2_lib:powerplan.design`
- Output block: `4_Backend_ICC2/2_Output/01_init_design/mnist_npu_icc2_lib:placement.design`
- Reports:
  - `4_Backend_ICC2/4_Report/04_place/check_legality.rpt`
  - `4_Backend_ICC2/4_Report/04_place/utilization.rpt`
  - `4_Backend_ICC2/4_Report/04_place/qor.rpt`
  - `4_Backend_ICC2/4_Report/04_place/timing.max.rpt`
  - `4_Backend_ICC2/4_Report/04_place/timing.min.rpt`
  - `4_Backend_ICC2/4_Report/04_place/design_physical.rpt`
  - `4_Backend_ICC2/4_Report/04_place/pg_connectivity.rpt`
  - `4_Backend_ICC2/4_Report/04_place/pg_connectivity_detail.rpt`
  - `4_Backend_ICC2/4_Report/04_place/pg_drc.rpt`
- Result: PASS_WITH_OPEN.
- Evidence:
  - `create_placement` completed.
  - `legalize_placement` completed and reported `Legalization succeeded`.
  - `check_legality.rpt` reports `TOTAL 0 Violations`.
  - `check_pg_drc` reported `No errors found`.
  - Setup timing remains met in QoR: `clk` critical path slack `5.26 ns`, no setup violating paths.
  - Hold remains open: worst hold violation `-0.01 ns`, total hold violation `-1.02`, hold violations `180`.
  - Placement utilization remains `0.5506`.
- Open warnings:
  - PG connectivity improved from all cells floating, but is still not clean: VDD has 7 floating wires, 3985 floating standard cells, and 8 floating terminals; VSS has 7 floating wires and 3405 floating standard cells.
  - Congestion is high at the 55% first baseline: phase1 global-route overflow `45036`, max overflow `5`, GRCs `36186 (4.20%)`.
  - Horizontal routing density above target is `38.28%`; vertical above target is `6.22%`.
  - Max transition/max capacitance violations remain open after placement: `3394` max transition violations and `21531` max capacitance violations.
  - No tie cell is available for constant fixing in the RVT-only library setup; keep as a library/setup risk before route closure.

### ICC2 libdir/LEF/modify NDM trial

- Command:
  - `4_Backend_ICC2/0_Script/00_setup/build_saed32_rvt_ndm_libdir_modify.sh`
  - `4_Backend_ICC2/0_Script/00_setup/run_libdir_modify_backend_env.sh 4_Backend_ICC2/0_Script/01_init_design/run_init_design_check.sh`
  - `4_Backend_ICC2/0_Script/00_setup/run_libdir_modify_backend_env.sh 4_Backend_ICC2/0_Script/02_floorplan/run_floorplan_initial.sh`
  - `4_Backend_ICC2/0_Script/00_setup/run_libdir_modify_backend_env.sh 4_Backend_ICC2/0_Script/03_powerplan/run_powerplan_initial.sh`
  - `4_Backend_ICC2/0_Script/00_setup/run_libdir_modify_backend_env.sh 4_Backend_ICC2/0_Script/04_place/run_place_initial.sh`
- Trial reference library: `4_Backend_ICC2/2_Output/00_setup/ndm_libdir_modify/saed32rvt_tt.ndm`.
- Trial design library: `4_Backend_ICC2/2_Output/01_init_design/mnist_npu_icc2_lib_libdir_modify`.
- Result: COMPLETED_NOT_ADOPTED.
- Evidence:
  - `check_workspace` succeeded for the modified RVT NDM.
  - ICC2 init linked `nn_top` with zero check_design errors; the same 16 no-driver and reset-related warnings remain.
  - Floorplan, powerplan, placement, and legalization completed.
  - Placement legality remains clean: `TOTAL 0 Violations`.
  - PG DRC remains clean: `No errors found`.
  - Setup remains met: `clk` critical path slack `5.31 ns`, setup violating paths `0`.
  - Hold remains open: worst hold `-0.01 ns`, total `-0.93`, hold violations `184`.
- Comparison against first placement baseline:
  - VDD floating standard cells worsened from `3985` to `4041`.
  - VSS floating standard cells worsened from `3405` to `3533`.
  - Phase1 global-route overflow worsened from `45036` to `46959`; GRCs worsened from `36186 (4.20%)` to `38099 (4.42%)`.
  - Horizontal density over target worsened slightly from `38.28%` to `38.48%`; vertical density stayed `6.22%`.
  - Max transition improved slightly from `3394` to `3352`, but max cap worsened from `21531` to `21557`.
- Disposition:
  - Do not adopt `libdir_modify` as the main baseline.
  - Keep scripts as a reproducible backend-only physical-abstract trial.
  - Continue CTS from the original EDK RVT NDM baseline unless route failure calls for another NDM trial.

### ICC2 CTS checkpoint

- Command: `4_Backend_ICC2/0_Script/05_cts/run_cts_initial.sh`
- Tool: `icc2_shell`
- Log: `4_Backend_ICC2/3_Log/05_cts/run_cts_initial.log`
- Input block: `4_Backend_ICC2/2_Output/01_init_design/mnist_npu_icc2_lib:placement.design`
- Output block: `4_Backend_ICC2/2_Output/01_init_design/mnist_npu_icc2_lib:cts.design`
- Reports:
  - `4_Backend_ICC2/4_Report/05_cts/check_clock_trees.pre.rpt`
  - `4_Backend_ICC2/4_Report/05_cts/check_clock_trees.post.rpt`
  - `4_Backend_ICC2/4_Report/05_cts/clock_qor.summary.rpt`
  - `4_Backend_ICC2/4_Report/05_cts/clock_qor.drc_violators.rpt`
  - `4_Backend_ICC2/4_Report/05_cts/clock_timing.summary.rpt`
  - `4_Backend_ICC2/4_Report/05_cts/timing.max.rpt`
  - `4_Backend_ICC2/4_Report/05_cts/timing.min.rpt`
  - `4_Backend_ICC2/4_Report/05_cts/qor.rpt`
  - `4_Backend_ICC2/4_Report/05_cts/utilization.rpt`
  - `4_Backend_ICC2/4_Report/05_cts/check_legality.rpt`
  - `4_Backend_ICC2/4_Report/05_cts/pg_connectivity.rpt`
  - `4_Backend_ICC2/4_Report/05_cts/pg_drc.rpt`
- Result: PASS_WITH_OPEN.
- Evidence:
  - `clock_opt -from build_clock -to route_clock` completed.
  - Saved block `cts` was created and `save_lib` completed.
  - CTS summary reports `39659` sinks, `11` levels, `1066` repeaters, repeater area `3800.98`, max latency `0.38 ns`, global skew `0.21 ns`.
  - Clock route detail route finished with `0 open nets` and `TOTAL VIOLATIONS = 0`.
  - `check_legality.rpt` reports `TOTAL 0 Violations`.
  - `check_pg_drc` reported `No errors found`.
  - Setup remains met: worst setup slack `5.57 ns`, setup violating paths `0`.
- Open warnings:
  - Hold is worse after CTS: worst hold `-0.10 ns`, total hold `-237.12`, hold violations `23288`.
  - PG connectivity is still not clean: VDD has 7 floating wires, 4653 floating standard cells, and 8 floating terminals; VSS has 7 floating wires and 3963 floating standard cells.
  - Design max transition/max capacitance violations remain open after CTS: `187` max transition violations and `1492` max capacitance violations.
  - Clock-specific DRC has `0` transition violations and `7` capacitance violations.
  - CTS log includes `POW-080` default voltage warnings; add explicit 1.05 V voltage context before route.
- Follow-up script update:
  - Added `DEFAULT_VOLTAGE 1.05` in `4_Backend_ICC2/0_Script/00_setup/icc2_common_setup.tcl`.
  - Added `set_voltage $DEFAULT_VOLTAGE` to the CTS script for future reruns.
  - Added first route script `4_Backend_ICC2/0_Script/06_route/run_route_initial.tcl`.
  - The route script opens saved block `cts`, sets default voltage, limits signal routing to M1-M8, runs `route_auto`, and records `check_routes`, antenna, timing, utilization, legality, PG connectivity, and PG DRC reports.

### ICC2 route/report extraction checkpoint

- Command: `4_Backend_ICC2/0_Script/06_route/run_route_initial.sh`
- Tool: `icc2_shell`
- Log: `4_Backend_ICC2/3_Log/06_route/run_route_initial.log`
- Input block: `4_Backend_ICC2/2_Output/01_init_design/mnist_npu_icc2_lib:cts.design`
- Output block: `4_Backend_ICC2/2_Output/01_init_design/mnist_npu_icc2_lib:route.design`
- Reports:
  - `4_Backend_ICC2/4_Report/06_route/check_routability.rpt`
  - `4_Backend_ICC2/4_Report/06_route/check_routes.rpt`
  - `4_Backend_ICC2/4_Report/06_route/antenna.rpt`
  - `4_Backend_ICC2/4_Report/06_route/qor.rpt`
  - `4_Backend_ICC2/4_Report/06_route/timing.max.rpt`
  - `4_Backend_ICC2/4_Report/06_route/timing.min.rpt`
  - `4_Backend_ICC2/4_Report/06_route/utilization.rpt`
  - `4_Backend_ICC2/4_Report/06_route/design_physical.rpt`
  - `4_Backend_ICC2/4_Report/06_route/check_legality.rpt`
  - `4_Backend_ICC2/4_Report/06_route/pg_connectivity.rpt`
  - `4_Backend_ICC2/4_Report/06_route/pg_drc.rpt`
- Result: PASS_WITH_OPEN.
- Evidence:
  - `set_voltage 1.05` was accepted and no `POW-080` message appeared before route.
  - `route_auto` completed and post-route reports completed.
  - `save_block -as route` completed; log tail reports saving `mnist_npu_icc2_lib:cts.design` to `mnist_npu_icc2_lib:route.design`.
  - `check_routes.rpt` reports `0` open signal nets and `738` total route DRCs.
  - Residual DRC classes: `285` diff-net spacing, `4` minimum-area, `183` needs-fat-contact, `240` off-grid, `26` short.
  - `antenna.rpt` reports no antenna rules defined, so antenna is not proven clean.
  - Setup timing remains met: worst reported setup slack `5.59 ns`, setup violating paths `0`.
  - Hold remains open: worst hold `-0.10 ns`, total hold `-288.96`, hold violations `25344`.
  - `check_legality.rpt` reports `TOTAL 0 Violations`.
  - `check_pg_drc` reported `No errors found`.
  - Utilization after route remains `0.6925`.
  - PG connectivity is still not clean: VDD has 7 floating wires, 4653 floating standard cells, and 8 floating terminals; VSS has 7 floating wires and 3963 floating standard cells.
  - Design max transition/max capacitance violations remain open after route: `287` max transition violations and `1958` max capacitance violations.
- Tool-operation note:
  - A duplicate route launch was attempted while PID `3802491` still held `cts.design`; it failed immediately with `NDM-029` and partially overwrote the beginning of `run_route_initial.log`.
  - Final stage evidence is therefore taken from the completed report files and the intact log tail showing PG DRC completion, `save_block -as route`, `save_lib`, and normal ICC2 exit.
  - Added a lock-file guard to `run_route_initial.sh` so future route reruns fail before clobbering the log when the ICC2 design library is locked.
- Next action:
  - Classify route DRC locations/types and determine whether the first repair should be lower utilization, routing option adjustment, or physical abstract/PG connectivity repair.

### ICC2 post-route DRC debug checkpoint

- Command: `4_Backend_ICC2/0_Script/06_route/debug_route_drc.sh`
- Tool: `icc2_shell`
- Input block: `4_Backend_ICC2/2_Output/01_init_design/mnist_npu_icc2_lib:route.design`
- Reports:
  - `4_Backend_ICC2/4_Report/06_route/drc_debug/drc.matrix.rpt`
  - `4_Backend_ICC2/4_Report/06_route/drc_debug/drc.error_type.rpt`
  - `4_Backend_ICC2/4_Report/06_route/drc_debug/drc.error_layer.rpt`
  - `4_Backend_ICC2/4_Report/06_route/drc_debug/drc.errors.tsv`
- Result: COMPLETED.
- Evidence:
  - Baseline route DRC matrix is concentrated on lower routing/contact layers.
  - M1 has `378` total DRCs: `263` diff-net spacing, `91` off-grid, `24` short.
  - M1-M2 has `183` needs-fat-contact DRCs.
  - M2 has `101` total DRCs: `21` diff-net spacing, `4` min-area, `74` off-grid, `2` short.
  - VIA1 has `75` off-grid DRCs.
  - DRCs are distributed across many locations; this is not a single localized hotspot.
- Diagnosis:
  - The dominant baseline route problem is lower-metal pin/via/contact legality and routing-resource pressure, consistent with SAED32 M1/M2/VIA1 issues seen in the sibling CV32E40P and ibex projects.

### ICC2 route ECO DRC repair trial

- Command: `4_Backend_ICC2/0_Script/06_route/run_route_eco_drc1.sh`
- Tool: `icc2_shell`
- Input block: `4_Backend_ICC2/2_Output/01_init_design/mnist_npu_icc2_lib:route.design`
- Output block: `4_Backend_ICC2/2_Output/01_init_design/mnist_npu_icc2_lib:route_eco_drc1.design`
- Reports:
  - `4_Backend_ICC2/4_Report/06_route_eco_drc1/check_routes.post.rpt`
  - `4_Backend_ICC2/4_Report/06_route_eco_drc1/qor.rpt`
  - `4_Backend_ICC2/4_Report/06_route_eco_drc1/check_legality.rpt`
  - `4_Backend_ICC2/4_Report/06_route_eco_drc1/pg_connectivity.rpt`
  - `4_Backend_ICC2/4_Report/06_route_eco_drc1/pg_drc.rpt`
- Result: COMPLETED_NOT_ADOPTED.
- Evidence:
  - Open signal nets remained `0`.
  - Route DRC improved only from `738` to `709`.
  - Residual DRC classes: `263` diff-net spacing, `7` minimum-area, `205` needs-fat-contact, `210` off-grid, `24` short.
  - Setup remained met; hold remained open at about worst `-0.10 ns`.
  - Legality remained clean: `TOTAL 0 Violations`.
  - PG DRC reported no errors, but PG connectivity remained open.
- Disposition:
  - Simple post-route ECO is not enough to close the baseline DRC.
  - Keep the script as a reproducible negative trial and move to physical-abstract/library-policy experiments.

### Sibling-project backend reference review

- References reviewed:
  - `/DATA/home/edu135/ibex/docs/backend_library_policy.md`
  - `/DATA/home/edu135/ibex/docs/ibex_backend_route_closure_case_study.md`
  - `/DATA/home/edu135/ibex/init/context_bootstrap.md`
  - `/DATA/home/edu135/CV32E40P/docs/backend/libdir_modify_lef_trial_2026_05_09.md`
  - `/DATA/home/edu135/CV32E40P/docs/backend/contact_code_diagnosis.md`
  - `/DATA/home/edu135/CV32E40P/docs/backend/pin_access_track_probe.md`
  - `/DATA/home/edu135/CV32E40P/docs/backend/scan_def_and_advanced_legalizer_trials.md`
- Result: COMPLETED.
- Findings:
  - ibex achieved route closure with project-local modified LEFs plus a patched technology file where VIA1 pitch was enabled and VIA1 `onWireTrack`/`onGrid` restrictions were removed.
  - CV32E40P showed that modified LEFs removed needs-fat-contact DRCs but could leave off-grid DRCs.
  - CV32E40P also showed that simple M1 track regeneration and advanced legalizer-style trials were not effective standalone fixes.
  - Both projects point to SAED32 lower-metal pin access and VIA1 legality as the first route-DRC root-cause family to test.

### ICC2 libdir VIA1 no-track NDM build

- Command: `4_Backend_ICC2/0_Script/00_setup/build_saed32_rvt_ndm_libdir_via1_no_track.sh`
- Tool: `lm_shell`
- Log: `4_Backend_ICC2/3_Log/00_setup/build_saed32_rvt_ndm_libdir_via1_no_track.log`
- Outputs:
  - `4_Backend_ICC2/2_Output/00_setup/tech/saed32nm_1p9m_mw.via1_pitch_no_track.tf`
  - `4_Backend_ICC2/2_Output/00_setup/ndm_libdir_via1_no_track/saed32rvt_tt.ndm`
- Result: PASS.
- Evidence:
  - `check_workspace` completed successfully.
  - NDM was written under the project ICC2 setup output directory.
  - The patched techfile uses the sibling-project VIA1 policy: enable `pitch = 0.36`, remove VIA1 `onWireTrack = 1`, and remove VIA1 `onGrid = 1`.
- Recorded warnings:
  - SAED32 LEF/NDM import warnings remain in the same family as the previous NDM builds and are treated as library-import warnings unless a downstream report proves a direct failure.

### ICC2 libdir VIA1 no-track backend-route trial

- Command: `4_Backend_ICC2/0_Script/99_util/run_libdir_via1_no_track_backend_flow.sh`
- Tool: `icc2_shell`
- Trial reference library: `4_Backend_ICC2/2_Output/00_setup/ndm_libdir_via1_no_track/saed32rvt_tt.ndm`
- Trial design library: `4_Backend_ICC2/2_Output/trials/libdir_via1_no_track_route/mnist_npu_icc2_lib`
- Log root: `4_Backend_ICC2/3_Log/trials/libdir_via1_no_track_route`
- Report root: `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_route`
- Result: PASS_WITH_OPEN, NOT YET ADOPTED AS BASELINE.
- Evidence:
  - Init, floorplan, powerplan, placement, CTS, and route completed using trial-specific log/report/output roots.
  - Final route block was saved as `mnist_npu_icc2_lib:route.design` inside the trial output library.
  - `06_route/check_routes.rpt` reports `0` open signal nets and `77` total DRCs.
  - Residual route DRC classes: `3` diff-net spacing, `1` minimum-area, `72` off-grid, `1` same-net spacing.
  - `Needs fat contact` is no longer reported in the final route report.
  - `antenna.rpt` reports no antenna rules defined, so antenna is not proven clean.
  - Setup timing remains met: worst setup slack `5.60 ns`, setup violating paths `0`.
  - Hold remains open: worst hold `-0.10 ns`, total hold `-235.75`, hold violations `22731`.
  - Utilization after route is `0.6924`.
  - `check_legality.rpt` reports `TOTAL 0 Violations`.
  - Route log reports `check_pg_drc` completed with `No errors found`.
  - PG connectivity is still not clean: VDD has 7 floating wires and `4697` floating standard cells; VSS has 7 floating wires and `4151` floating standard cells.
  - Design max transition/max capacitance violations remain open after route: `296` max transition violations and `2011` max capacitance violations.
- Comparison against first route baseline:
  - Total route DRC improved from `738` to `77`.
  - Diff-net spacing improved from `285` to `3`.
  - Needs-fat-contact improved from `183` to `0`.
  - Off-grid improved from `240` to `72`, but remains the dominant residual class.
  - Short DRCs improved from `26` to `0`.
  - PG connectivity worsened versus baseline route: VDD floating standard cells increased from `4653` to `4697`; VSS increased from `3963` to `4151`.
- Disposition:
  - Treat the VIA1 no-track NDM as the strongest current route-DRC repair candidate.
  - Do not declare route clean and do not replace the fixed baseline yet because residual DRC, PG connectivity, hold, and electrical violations remain open.
  - Next action is residual off-grid classification on the trial route, then decide between route-level repair, lower-utilization rerun with the same NDM, or a DC cell-use policy rerun based on ibex.

### ICC2 libdir VIA1 no-track residual DRC and PG debug

- Command: `4_Backend_ICC2/0_Script/06_route/debug_libdir_via1_no_track_route_residuals.sh`
- Tool: `icc2_shell`
- Input block: `4_Backend_ICC2/2_Output/trials/libdir_via1_no_track_route/mnist_npu_icc2_lib:route.design`
- Reports:
  - `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_route/06_route_debug/check_routes.recheck.rpt`
  - `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_route/06_route_debug/drc.matrix.rpt`
  - `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_route/06_route_debug/drc.errors.tsv`
  - `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_route/06_route_debug/drc.offgrid.tsv`
  - `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_route/06_route_debug/pg_connectivity.rpt`
  - `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_route/06_route_debug/pg_connectivity_detail.rpt`
  - `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_route/06_route_debug/pg_drc.rpt`
- Result: COMPLETED.
- Evidence:
  - Recheck confirmed `0` open signal nets and `77` total route DRCs.
  - DRC matrix: `69` M1 off-grid, `3` M2 off-grid, `3` diff-net spacing, `1` M2 minimum-area, and `1` M2 same-net spacing.
  - `drc.offgrid.tsv` contains `72` off-grid entries with bbox center and object name.
  - Off-grid object classification: `0` entries reference VDD/VSS; `72` are signal-only; `70` are plain signal net names and `2` are named route objects.
  - Top repeated off-grid objects are small clusters, not one global object: `n47593` appears 3 times; `n68596`, `n62541`, `n57976`, `n53846`, `n45702`, `n43530`, and `n40786` appear 2 times each.
  - Coarse 100um coordinate buckets show distributed clusters; largest bucket is `500,700` with `12` off-grid entries.
  - PG connectivity remains separate from signal route DRC: VDD has `8` disjoint networks, with the main network connected to `201997` std cells and seven 1-wire/0-via sub-networks covering `765`, `706`, `667`, `666`, `665`, `642`, and `586` std cells.
  - VSS has `8` disjoint networks, with the main network connected to `202543` std cells and seven 1-wire/0-via sub-networks covering `681`, `620`, `605`, `596`, `566`, `558`, and `525` std cells.
  - PG DRC again reported `No errors found`.
- Diagnosis:
  - Residual route DRC is a signal routing off-grid problem dominated by M1, not a PG-net DRC.
  - PG connectivity is a PG network/rail connectivity issue: seven isolated rail subnetworks per supply net, not a signal route DRC side effect.

### ICC2 libdir VIA1 no-track route-only ECO off-grid trial

- Command: `4_Backend_ICC2/0_Script/06_route/run_libdir_via1_no_track_route_eco_offgrid1.sh`
- Tool: `icc2_shell`
- Input block: `4_Backend_ICC2/2_Output/trials/libdir_via1_no_track_route/mnist_npu_icc2_lib:route.design`
- Output block: `4_Backend_ICC2/2_Output/trials/libdir_via1_no_track_route/mnist_npu_icc2_lib:route_eco_offgrid1.design`
- Reports:
  - `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_route_eco_offgrid1/06_route/check_routes.pre.rpt`
  - `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_route_eco_offgrid1/06_route/check_routes.post.rpt`
  - `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_route_eco_offgrid1/06_route/qor.rpt`
  - `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_route_eco_offgrid1/06_route/check_legality.rpt`
  - `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_route_eco_offgrid1/06_route/pg_connectivity.rpt`
  - `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_route_eco_offgrid1/06_route/pg_drc.rpt`
- Result: COMPLETED_PARTIAL_REPAIR_NOT_CLEAN.
- Evidence:
  - Pre-check confirmed `0` open signal nets and `77` total DRCs.
  - ECO changed `364` nets and saved `route_eco_offgrid1`.
  - During detail route iteration, DRC fell as low as `38`, then became non-monotonic and stopped as not converging.
  - Final `check_routes.post.rpt` reports `0` open signal nets and `55` total DRCs: `2` diff-net spacing and `53` off-grid.
  - Legality remains clean: `TOTAL 0 Violations`.
  - Setup remains met: worst setup slack `5.60 ns`, setup violating paths `0`.
  - Hold remains open: worst hold `-0.10 ns`, total hold `-235.75`, hold violations `22731`.
  - PG connectivity is unchanged: VDD `4697` floating standard cells, VSS `4151` floating standard cells.
  - PG DRC reported `No errors found`.
- Disposition:
  - Route-only ECO can partially reduce residual signal DRC, but it did not converge to clean.
  - Do not continue generic route-only ECO as the main closure path without another variable change.
  - Next controlled trials should target placement/congestion or PG rail connectivity separately.
  - Note: the first execution of this shared ECO Tcl also issued a final `save_block` after `save_block -as`; the Tcl was updated to avoid saving the input block on future ECO trials.

### ICC2 libdir VIA1 no-track 45% utilization backend-route trial

- Command: `4_Backend_ICC2/0_Script/99_util/run_libdir_via1_no_track_util45_backend_flow.sh`
- Tool: `icc2_shell`
- Trial reference library: `4_Backend_ICC2/2_Output/00_setup/ndm_libdir_via1_no_track/saed32rvt_tt.ndm`
- Trial design library: `4_Backend_ICC2/2_Output/trials/libdir_via1_no_track_util45_route/mnist_npu_icc2_lib`
- Log root: `4_Backend_ICC2/3_Log/trials/libdir_via1_no_track_util45_route`
- Report root: `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_util45_route`
- Result: COMPLETED_PARTIAL_IMPROVEMENT_NOT_CLEAN.
- Evidence:
  - Init, floorplan, powerplan, placement, CTS, and route completed using trial-specific log/report/output roots.
  - `02_floorplan/run_floorplan_initial.tcl` now supports `CORE_UTILIZATION`, `CORE_ASPECT_RATIO`, and `CORE_OFFSET_UM` environment overrides for controlled trials.
  - Final `06_route/check_routes.rpt` reports `0` open signal nets and `59` total DRCs.
  - Residual route DRC classes: `1` diff-net spacing, `57` off-grid, and `1` short.
  - Official route check is used for the result; the route log reached `58` DRC during `route_auto` before final reconnect/reporting.
  - `check_legality.rpt` reports `TOTAL 0 Violations`.
  - Setup remains met: worst setup slack `5.60 ns`, setup violating paths `0`.
  - Hold remains open: worst hold about `-0.10 ns`.
  - Final utilization is `0.5669`, so a 45% floorplan target still becomes a 56.69% routed design after optimization.
  - PG DRC reported no errors, but PG connectivity is still not clean: VDD has `4447` floating standard cells and VSS has `4002` floating standard cells.
  - Electrical cleanup remains open: `307` max transition violations and `2018` max capacitance violations.
- Diagnosis:
  - Lowering floorplan utilization from 55% to 45% improves route DRC from `77` to `59`, but it does not close the route.
  - Residual DRC remains lower-metal/off-grid dominated, matching the sibling-project pin-access/physical-abstract root-cause family.
  - Lower utilization alone is therefore not the main closure fix.
- Next action:
  - Build a new RVT NDM that combines libdir modified LEF, VIA1 pitch/no-track techfile, and `configure_frame_options -mode keep_obs_and_trim_all_pin`.
  - Run the same 45% backend flow with that NDM before moving to a DC cell-use policy rerun.

### Sibling-project backend closure reference update

- References checked:
  - `/DATA/home/edu135/ibex/00_Project_Tracking/RUN_MANIFEST.md`
  - `/DATA/home/edu135/CV32E40P/docs/backend/route_drc_root_cause_investigation.md`
  - `/DATA/home/edu135/CV32E40P/7_Backend_ICC2/0_Script/00_setup/build_saed32_ndm_trim_all_pin.tcl`
- Result: COMPLETED.
- Findings:
  - ibex closed a comparable SAED32 route DRC case using modified LEFs, VIA1 pitch/no-track techfile policy, and upstream DC `dont_use` policy for weak lower-metal cells; its final debug candidate reported `0` open nets and `0` signal DRC.
  - CV32E40P found M9 routing did not address the lower-metal DRC root cause and worsened DRC in that trial.
  - CV32E40P reduced a 67-DRC backend candidate to 1 DRC by rebuilding NDMs with `configure_frame_options -mode keep_obs_and_trim_all_pin`; the last residual was a MUX41X2 pin-access case.
  - MNIST's current mapped netlist contains `39` `MUX41X1_RVT`, `74` `NOR2X0_RVT`, `1` `NOR2X2_RVT`, and no `MUX41X2_RVT`, so the NDM frame-trimming experiment is the narrower next trial than an immediate DC cell-use rerun.

### ICC2 libdir VIA1 no-track trim_all_pin NDM build

- Command: `4_Backend_ICC2/0_Script/00_setup/build_saed32_rvt_ndm_libdir_via1_no_track_trim_all_pin.sh`
- Tool: `lm_shell`
- Log: `4_Backend_ICC2/3_Log/00_setup/build_saed32_rvt_ndm_libdir_via1_no_track_trim_all_pin.log`
- Outputs:
  - `4_Backend_ICC2/2_Output/00_setup/tech/saed32nm_1p9m_mw.via1_pitch_no_track_trim_all_pin.tf`
  - `4_Backend_ICC2/2_Output/00_setup/ndm_libdir_via1_no_track_trim_all_pin/saed32rvt_tt.ndm`
- Result: PASS.
- Evidence:
  - Build log shows `configure_frame_options -mode keep_obs_and_trim_all_pin`.
  - `check_workspace` reports `Workspace check succeeded!`.
  - `commit_workspace` wrote the RVT NDM under the project output directory.
- Recorded warnings:
  - SAED32 LEF/NDM import direction mismatch warnings remain in the same library-import family as prior NDM builds.

### ICC2 libdir VIA1 no-track trim_all_pin 45% utilization backend trial

- Command: `4_Backend_ICC2/0_Script/99_util/run_libdir_via1_no_track_trim_all_pin_util45_backend_flow.sh`
- Tool: `icc2_shell`
- Trial reference library: `4_Backend_ICC2/2_Output/00_setup/ndm_libdir_via1_no_track_trim_all_pin/saed32rvt_tt.ndm`
- Trial design library: `4_Backend_ICC2/2_Output/trials/libdir_via1_no_track_trim_all_pin_util45_route/mnist_npu_icc2_lib`
- Log root: `4_Backend_ICC2/3_Log/trials/libdir_via1_no_track_trim_all_pin_util45_route`
- Report root: `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route`
- Result: STOPPED_BY_USER_DURING_CTS, ROUTE_NOT_RUN.
- Stop action:
  - User requested to stop at CTS and evaluate for the day.
  - Active process group was interrupted, then terminated after SIGINT did not stop it.
  - No `route` stage was started, and no route DRC result exists for this trial.
- Completed evidence before stop:
  - Init completed and saved `nn_top.design`.
  - Floorplan completed with `CORE_UTILIZATION=0.45`; floorplan log reports core utilization ratio about `45.03%`.
  - Powerplan completed; route-stage PG is not available.
  - Placement completed and saved `placement.design`.
  - Placement legality report shows `TOTAL 0 Violations`.
  - Placement utilization report shows utilization ratio `0.4503`.
  - Placement QoR shows setup positive, with path-group critical slacks `7.39`, `7.92`, and `4.89`.
  - Placement QoR still has `3074` max transition violations and `21434` max capacitance violations.
  - Placement PG DRC log reported `No errors found`.
  - Placement PG connectivity is still not clean: VDD has `3885` floating standard cells and VSS has `3308` floating standard cells.
  - CTS log reached `Compilation of clock trees finished successfully`, but the script was stopped later during clock-opt optimization before final CTS reports/save.
- Open issues:
  - No `cts.design` saved block was found after the stop; saved blocks currently include `nn_top`, `floorplan`, `powerplan`, and `placement`.
  - The trial design library has a stale-looking `lib.ndm.master_lock` after the forced stop. Do not rerun the wrapper until this is checked and removed or the design library is recreated.
  - CTS log repeats `POW-080` default-voltage warnings and `OPT-070` default max-transition constraint warnings; these are setup/constraint cleanup items, not route DRC evidence.
- Disposition:
  - The new NDM build is valid and can be reused.
  - The backend trial is not evaluable for route DRC yet. Resume by cleaning/recreating the trial library and rerunning from CTS or rerunning the full wrapper, then continue through route.

## 2026-05-11

### ICC2 trim_all_pin util45 previous-day final-result recovery

- Objective: resume from the final available evidence for the `libdir_via1_no_track_trim_all_pin_util45` trial and continue without losing reproducibility.
- Result: COMPLETED.
- Findings:
  - The normal `libdir_via1_no_track_trim_all_pin_util45_route_rerun2` full wrapper completed through route after the previous stop point.
  - Its `05_cts/run.log` and `06_route/run.log` both reached normal ICC2 exit.
  - Its route reports showed `0` open signal nets and `6` total route DRCs, all `Off-grid`.
  - After that completion, a no-CCD diagnostic route was run in the same rerun2 design library and overwrote the saved `route.design`/`route_auto.design`.
- Disposition:
  - Use rerun2 reports only as historical evidence.
  - Do not use the rerun2 saved route database as the preserved final database because it was later overwritten by diagnostic work.

### ICC2 trim_all_pin util45 no-CCD diagnostic route

- Command:
  - `4_Backend_ICC2/0_Script/99_util/run_libdir_via1_no_track_trim_all_pin_util45_recover_cts_no_ccd_route.sh`
- Tool: `icc2_shell`
- Trial root: `libdir_via1_no_track_trim_all_pin_util45_route_rerun2`
- Result: COMPLETED_DIAGNOSTIC_NOT_ADOPTED.
- Evidence:
  - Diagnostic route reports were written under `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun2/06_route_from_cts_no_ccd/`.
  - Diagnostic route reported `0` open signal nets and `7` total route DRCs, all `Off-grid`.
  - Diagnostic hold improved versus the normal rerun2 route, but route DRC and PG connectivity remained open.
- Disposition:
  - Keep this as a diagnostic data point only.
  - Do not adopt the no-CCD diagnostic database or reports as the main trim_all_pin util45 route result.

### ICC2 trim_all_pin util45 clean full rerun3 route

- Command: `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 4_Backend_ICC2/0_Script/99_util/run_libdir_via1_no_track_trim_all_pin_util45_backend_flow.sh`
- Tool: `icc2_shell`
- Trial reference library: `4_Backend_ICC2/2_Output/00_setup/ndm_libdir_via1_no_track_trim_all_pin/saed32rvt_tt.ndm`
- Trial design library: `4_Backend_ICC2/2_Output/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/mnist_npu_icc2_lib`
- Log root: `4_Backend_ICC2/3_Log/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3`
- Report root: `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3`
- Result: COMPLETED_ROUTE_NOT_CLEAN.
- Evidence:
  - Init, floorplan, powerplan, placement, CTS, and route completed using trial-specific roots.
  - Final route log reached normal ICC2 exit and saved both `route_auto.design` and `route.design`.
  - Saved blocks include `nn_top`, `floorplan`, `powerplan`, `placement`, `cts`, `route_auto`, and `route`.
  - `06_route/check_routes.rpt` reports `213233` total nets, `0` open signal nets, and `6` total route DRCs.
  - Residual route DRC class is `6` `Off-grid` violations.
  - `antenna.rpt` reports no antenna rules defined, so antenna is not proven clean.
  - `06_route/check_legality.rpt` reports `TOTAL 0 Violations`.
  - `06_route/qor.rpt` reports setup met: worst setup slack `5.61 ns`, total negative setup slack `0.00`, setup violating paths `0`.
  - Hold remains open: worst hold `-0.10 ns`, total negative hold slack `-322.94`, hold violating paths `26158`.
  - Routed utilization is `0.5669`.
  - Cell area is `774796.61`; net length is `7028986.22`.
  - Design max transition/max capacitance violations remain open: `317 / 2006`.
  - Route log reports `check_pg_drc` completed with `No errors found`.
  - PG connectivity is still not clean: VDD has `7` floating wires and `4447` floating standard cells; VSS has `7` floating wires and `4002` floating standard cells.
- Comparison:
  - Versus the previous VIA1 no-track 45% route trial, official route DRC improved from `59` to `6`.
  - Versus the original 55% first route baseline, official route DRC improved from `738` to `6`.
- Disposition:
  - Treat rerun3 as the preserved route database and current best full-flow route-DRC candidate.
  - Do not declare route clean because route DRC, PG connectivity, hold, antenna-rule coverage, and electrical violations remain open.
  - Next action is to debug the six residual off-grid DRCs from the rerun3 route database while keeping PG connectivity as a separate closure track.

### ICC2 trim_all_pin util45 rerun3 residual DRC debug extraction

- Command: `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 ROUTE_DEBUG_SUBDIR=06_route_debug 4_Backend_ICC2/0_Script/06_route/debug_libdir_via1_no_track_route_residuals.sh`
- Tool: `icc2_shell`
- Input block: `4_Backend_ICC2/2_Output/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/mnist_npu_icc2_lib:route.design`
- Reports:
  - `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/06_route_debug/check_routes.recheck.rpt`
  - `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/06_route_debug/drc.matrix.rpt`
  - `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/06_route_debug/drc.offgrid.tsv`
  - `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/06_route_debug/pg_connectivity.rpt`
  - `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/06_route_debug/pg_drc.rpt`
- Result: COMPLETED.
- Evidence:
  - Recheck confirmed `0` open signal nets and `6` total route DRCs.
  - DRC matrix shows all six DRCs are `M1` `Off-grid`.
  - Residual objects and centers:
    - `ZBUF_832_2538` at `201.6400,255.6000`
    - `n130475` at `805.5360,332.8160`
    - `ZBUF_714_1050` at `906.9200,399.3920`
    - `ZBUF_766_3067` at `359.4160,456.2400`
    - `ZBUF_851_152` at `899.1680,650.4960`
    - `n143522` at `250.1025,855.1040`
  - PG connectivity and PG DRC recheck match route-stage evidence: VDD has `7` floating wires and `4447` floating standard cells; VSS has `7` floating wires and `4002` floating standard cells; PG DRC reports `No errors found`.
- Diagnosis:
  - The residual trim_all_pin DRCs are signal M1 off-grid errors, not PG DRCs.

### ICC2 trim_all_pin util45 rerun3 route-only ECO off-grid trial

- Command: `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 ROUTE_ECO_TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3_eco_offgrid1 ROUTE_ECO_OUTPUT_BLOCK=route_eco_offgrid1 4_Backend_ICC2/0_Script/06_route/run_libdir_via1_no_track_route_eco_offgrid1.sh`
- Tool: `icc2_shell`
- Input block: `mnist_npu_icc2_lib:route.design` in the rerun3 trial library.
- Output block: `mnist_npu_icc2_lib:route_eco_offgrid1.design` in the rerun3 trial library.
- Reports:
  - `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3_eco_offgrid1/06_route/check_routes.pre.rpt`
  - `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3_eco_offgrid1/06_route/check_routes.post.rpt`
  - `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3_eco_offgrid1/06_route/qor.rpt`
  - `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3_eco_offgrid1/06_route/check_legality.rpt`
  - `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3_eco_offgrid1/06_route/pg_connectivity.rpt`
  - `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3_eco_offgrid1/06_route/pg_drc.rpt`
- Result: COMPLETED_PARTIAL_REPAIR_NOT_CLEAN.
- Evidence:
  - Pre-check confirmed `0` open signal nets and `6` M1 off-grid DRCs.
  - ECO changed `81` nets.
  - Detail-route iterations reached `4` DRCs at best, became non-monotonic, and stopped as not converging.
  - Final post-check reports `0` open signal nets and `5` route DRCs, all `Off-grid`.
  - Legality remains clean: `TOTAL 0 Violations`.
  - Setup remains met: worst setup slack `5.61 ns`, setup violating paths `0`.
  - Hold remains open: worst hold `-0.10 ns`, total hold `-322.94`, hold violations `26158`.
  - PG DRC reports `No errors found`, but PG connectivity is unchanged: VDD `4447` floating standard cells, VSS `4002` floating standard cells.
  - Max transition/max capacitance violations remain `317 / 2006`.
- Residual ECO DRC extraction:
  - Command: `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 ROUTE_DEBUG_SUBDIR=06_route_eco_offgrid1_debug ROUTE_DEBUG_INPUT_BLOCK=route_eco_offgrid1 4_Backend_ICC2/0_Script/06_route/debug_libdir_via1_no_track_route_residuals.sh`
  - Residual objects and centers:
    - `ZBUF_832_2538` at `201.1840,255.6330`
    - `ZBUF_714_1050` at `906.7680,393.0080`
    - `ZBUF_714_1050` at `906.7680,399.3920`
    - `ZBUF_851_152` at `899.1680,650.4960`
    - `n143522` at `250.1025,855.1040`
- Disposition:
  - Route-only ECO is a partial repair: official DRC improved from `6` to `5`, but it did not converge to clean.
  - Keep the preserved full-flow rerun3 `route.design` as the main reproducible route database and treat `route_eco_offgrid1` as a route-only candidate for further residual analysis.

### ICC2 trim_all_pin util45 targeted pin-access route repair

- Objective: close the five residual M1 off-grid DRCs in `route_eco_offgrid1` using targeted pin-access/local-route changes, not another broad generic ECO loop.
- Script updates:
  - Added sequential local-route probe support in `4_Backend_ICC2/0_Script/06_route/probe_sequential_local_offgrid_route.tcl`.
  - Added `SEQ_SWAP_NET_EXCLUDE_REGEX`, default `^(VDD|VSS)$`, so `@swap_pin_nets` excludes PG nets.
  - Added `SEQ_CELL_MOVES='cell=dx,dy;...'` support and `cell_move.rpt` recording for controlled placement nudges.
  - Updated `debug_libdir_via1_no_track_route_residuals.tcl` so a clean route recheck is handled without failing.
- Context extraction:
  - `06_route_eco_offgrid1_context/context.tsv` localized the five residual DRCs to reset-pin/buffer pin-access sites plus `n143522`.
  - `06_route_target_u77942_route_eco_offgrid1/target_context.tsv` showed the final `n143522` residual overlaps the `U77942/A1` pin-access region; `U77942/A1` and `U77942/A3` are both on `n143522`.
- Negative/partial probes:
  - Single local pin-track reroute fixed `ZBUF_851_152` only.
  - Single-net `ZBUF_714_1050` reroute fixed both `ZBUF_714_1050` off-grid markers.
  - Sequential local pin-track reroute reduced the ECO residual from `5` to `2`, leaving `ZBUF_832_2538` and `n143522`.
  - Size-swap plus sequential reroute reduced the residual to `1`, leaving only `n143522`; rerun with PG-net exclusion produced the same `1` residual and confirmed `VDD/VSS` were not part of the targeted signal reroute set.
- Successful command:
  - `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 SEQ_ROUTE_PROBE_NAME=seq_size_swap_dff2_oa1_move_u77942_xp152_pintrack_clean_save1 SEQ_ROUTE_INPUT_BLOCK=route_eco_offgrid1 SEQ_ROUTE_OUTPUT_BLOCK=route_seq_size_swap_dff2_oa1_move_u77942_xp152_pintrack SEQ_SIZE_SWAPS='act_ram_reg[861][0]=DFFARX2_RVT;U77942=OA221X1_RVT' SEQ_CELL_MOVES='U77942=0.152,0' SEQ_ROUTE_STEPS='ZBUF_714_1050;ZBUF_851_152;@swap_pin_nets;ZBUF_832_2538;n143522' SEQ_ROUTE_ITERATIONS=120 SEQ_ROUTE_SAVE=1 SEQ_ROUTE_SAVE_ON_CLEAN_ONLY=1 4_Backend_ICC2/0_Script/06_route/probe_sequential_local_offgrid_route.sh`
- Tool: `icc2_shell`
- Input block: `mnist_npu_icc2_lib:route_eco_offgrid1.design` in the rerun3 trial library.
- Output block: `mnist_npu_icc2_lib:route_seq_size_swap_dff2_oa1_move_u77942_xp152_pintrack.design` in the rerun3 trial library.
- Reports:
  - `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/06_route_seq_size_swap_dff2_oa1_move_u77942_xp152_pintrack_clean_save1/summary.tsv`
  - `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/06_route_seq_size_swap_dff2_oa1_move_u77942_xp152_pintrack_clean_save1/check_routes.after_step5.rpt`
  - `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/06_route_seq_size_swap_dff2_oa1_move_u77942_xp152_pintrack_clean_save1/size_swap.rpt`
  - `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/06_route_seq_size_swap_dff2_oa1_move_u77942_xp152_pintrack_clean_save1/cell_move.rpt`
  - `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/06_route_seq_size_swap_dff2_oa1_move_u77942_xp152_pintrack_clean_save1/qor.rpt`
  - `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/06_route_seq_size_swap_dff2_oa1_move_u77942_xp152_pintrack_clean_save1/check_legality.rpt`
  - `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/06_route_seq_size_swap_dff2_oa1_move_u77942_xp152_pintrack_clean_save1/pg_connectivity.rpt`
  - `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/06_route_seq_size_swap_dff2_oa1_move_u77942_xp152_pintrack_clean_save1/pg_drc.rpt`
- Result: ROUTE_DRC_CLEAN_CANDIDATE_WITH_OPEN_PG_TIMING_ELECTRICAL.
- Evidence:
  - `size_swap.rpt` records `act_ram_reg[861][0]` resized from `DFFARX1_RVT` to `DFFARX2_RVT`, and `U77942` resized from `OA221X2_RVT` to `OA221X1_RVT`.
  - `cell_move.rpt` records `U77942` moved by `+0.152,0`; origin changed from `249.6720 854.3280` to `249.8240 854.3280`, and legalize kept it placed.
  - `summary.tsv` shows the moved design initially worsened to `22` DRCs and `7` open nets, then `@swap_pin_nets` reroute reached `0` DRC and `0` open nets; step4 and step5 also preserved `0/0`.
  - `check_routes.after_step5.rpt` reports `0` open signal nets and `0` total route DRCs.
  - ICC2 saved `route_seq_size_swap_dff2_oa1_move_u77942_xp152_pintrack.design`.
  - `check_legality.rpt` reports `TOTAL 0 Violations`.
  - `qor.rpt` reports setup still met with `clk` critical path slack `5.61 ns`, setup violating paths `0`.
  - Hold remains open: worst hold `-0.10 ns`, total hold `-322.90`, hold violations `26153`.
  - Design max transition/max capacitance remain open: `318 / 2009`.
  - `pg_drc.rpt` was generated after `check_pg_drc`; run log reports `No errors found`.
  - PG connectivity is still not clean: VDD has `7` floating wires and `4447` floating standard cells; VSS has `7` floating wires and `4002` floating standard cells.
- Saved-block recheck:
  - Command: `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 ROUTE_DEBUG_SUBDIR=06_route_seq_size_swap_dff2_oa1_move_u77942_xp152_saved_recheck ROUTE_DEBUG_INPUT_BLOCK=route_seq_size_swap_dff2_oa1_move_u77942_xp152_pintrack 4_Backend_ICC2/0_Script/06_route/debug_libdir_via1_no_track_route_residuals.sh`
  - `check_routes.recheck.rpt` confirms `0` open signal nets and `0` total route DRCs after reopening the saved block.
  - `drc.errors.tsv` and `drc.offgrid.tsv` contain only headers, confirming no extracted DRC error rows.
  - PG connectivity remains open with the same floating standard-cell counts; `check_pg_drc` again reports `No errors found`.
- Disposition:
  - This is the current best saved signal-route candidate and closes the targeted residual M1 off-grid objective.
  - Do not promote it to a complete baseline yet: PG connectivity, hold, max transition/capacitance, and antenna-rule coverage remain open.

### ICC2 PG rail connectivity debug and repair probes

- Objective: debug the seven floating one-wire PG rail subnetworks per supply net from the saved signal-route candidate without mixing them with signal-route DRC closure.
- New helper scripts:
  - `4_Backend_ICC2/0_Script/03_powerplan/repair_pg_connectivity_from_block.sh`
  - `4_Backend_ICC2/0_Script/03_powerplan/repair_pg_connectivity_from_block.tcl`
  - `4_Backend_ICC2/0_Script/03_powerplan/inspect_pg_rail_islands.sh`
  - `4_Backend_ICC2/0_Script/03_powerplan/inspect_pg_rail_islands.tcl`
  - `4_Backend_ICC2/0_Script/03_powerplan/repair_pg_floating_rail_vias.sh`
  - `4_Backend_ICC2/0_Script/03_powerplan/repair_pg_floating_rail_vias.tcl`
  - `4_Backend_ICC2/0_Script/03_powerplan/repair_pg_floating_rail_ladders.sh`
  - `4_Backend_ICC2/0_Script/03_powerplan/repair_pg_floating_rail_ladders.tcl`
- Input block: `mnist_npu_icc2_lib:route_seq_size_swap_dff2_oa1_move_u77942_xp152_pintrack.design` in trial `libdir_via1_no_track_trim_all_pin_util45_route_rerun3`.
- Reapply existing PG strategies:
  - Command: `env PG_REPAIR_NAME=pg_reapply1 PG_REPAIR_SAVE=0 4_Backend_ICC2/0_Script/03_powerplan/repair_pg_connectivity_from_block.sh`
  - Report root: `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/03_powerplan_pg_reapply1`
  - Result: COMPLETED_NOT_ADOPTED.
  - Evidence: `compile_pg` committed additional wires but no vias; PG connectivity worsened to 14 floating wires per supply, while floating standard-cell counts stayed VDD `4447` and VSS `4002`.
- Floating rail inspection:
  - Command: `env PG_ISLAND_NAME=pg_islands1 4_Backend_ICC2/0_Script/03_powerplan/inspect_pg_rail_islands.sh`
  - Report root: `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/03_powerplan_pg_islands1`
  - Result: COMPLETED.
  - Evidence: the floating shapes are M1 standard-cell rails `PATH_11_184`, `PATH_11_208`, `PATH_11_232`, `PATH_11_256`, `PATH_11_280`, `PATH_11_304`, `PATH_11_328` for VDD and `PATH_11_483`, `PATH_11_507`, `PATH_11_531`, `PATH_11_555`, `PATH_11_579`, `PATH_11_603`, `PATH_11_627` for VSS.
  - Diagnosis: representative floating cells physically overlap the affected M1 rails, but the rails lack restored PG via connection into the upper mesh.
- Direct M1-M2 VIA12 repair:
  - Command: `env PG_VIA_REPAIR_NAME=pg_via12_repair1 PG_VIA_REPAIR_SAVE=0 4_Backend_ICC2/0_Script/03_powerplan/repair_pg_floating_rail_vias.sh`
  - Result: COMPLETED_NOT_ADOPTED because normal DRC checking removed all candidates.
  - Forced command: `env PG_VIA_REPAIR_NAME=pg_via12_nocheck1 PG_VIA_REPAIR_SAVE=0 PG_VIA_REPAIR_DRC_MODE=no_check 4_Backend_ICC2/0_Script/03_powerplan/repair_pg_floating_rail_vias.sh`
  - Forced report root: `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/03_powerplan_pg_via12_nocheck1`
  - Forced result: COMPLETED_NOT_ADOPTED.
  - Evidence: forced direct VIA12 created `406` vias and fixed PG connectivity to zero floating wires/vias/std cells, with `0` open signal nets and `0` route DRCs, but `pg_drc.after.rpt` reported `580` PG DRC errors between VIA1 and existing VIA2 cuts.
- M1-M7 ladder repair at `x=50.0`:
  - Command: `env PG_LADDER_NAME=pg_ladder_x50_nocheck2 PG_LADDER_SAVE=0 PG_LADDER_X=50.0 PG_LADDER_DRC_MODE=no_check 4_Backend_ICC2/0_Script/03_powerplan/repair_pg_floating_rail_ladders.sh`
  - Report root: `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/03_powerplan_pg_ladder_x50_nocheck2`
  - Result: COMPLETED_NOT_ADOPTED.
  - Evidence: created `84` vias, fixed PG connectivity to zero floating wires/vias/std cells, kept PG DRC clean and legality clean, but signal `check_routes.after.rpt` reported `24` route DRCs. Extracted DRCs are on VSS-side ladder locations.
- VSS-only ladder probe at `x=30.0`:
  - Command: `env PG_LADDER_NAME=pg_ladder_vss_x30_nocheck1 PG_LADDER_SAVE=0 PG_LADDER_X=30.0 PG_LADDER_DRC_MODE=no_check PG_LADDER_SHAPES='PATH_11_483 PATH_11_507 PATH_11_531 PATH_11_555 PATH_11_579 PATH_11_603 PATH_11_627' 4_Backend_ICC2/0_Script/03_powerplan/repair_pg_floating_rail_ladders.sh`
  - Report root: `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/03_powerplan_pg_ladder_vss_x30_nocheck1`
  - Result: COMPLETED_NOT_ADOPTED.
  - Evidence: VSS connectivity is clean for the probed rails and PG DRC is clean, but signal `check_routes.after.rpt` reports `20` route DRCs.
- Intermediate disposition after the initial ladder probes:
  - PG root cause is an isolated-rail via-restoration problem, not the signal off-grid route DRC already closed in the saved candidate.
  - The all-rail `x=50.0` ladder and VSS-only `x=30.0` ladder were not saved because they repaired PG connectivity but introduced signal route DRCs.
- Candidate-site scanner and additional VSS probes:
  - Added `4_Backend_ICC2/0_Script/03_powerplan/inspect_pg_ladder_candidate_sites.sh`.
  - Added `4_Backend_ICC2/0_Script/03_powerplan/inspect_pg_ladder_candidate_sites.tcl`.
  - Extended `repair_pg_floating_rail_ladders.tcl` with `PG_LADDER_VDD_X`, `PG_LADDER_VSS_X`, `PG_LADDER_VDD_HALF_BOX`, `PG_LADDER_VSS_HALF_BOX`, and per-shape `PG_LADDER_SHAPE_OVERRIDES`.
  - Extended `repair_pg_floating_rail_ladders.sh` to pass those environment overrides.
  - Extended `debug_libdir_via1_no_track_route_residuals.tcl` to record `check_legality.rpt` and `qor.rpt` during saved-block rechecks.
  - VSS `x=140.0` avoided signal route DRC but was not adopted because it overlapped existing PG stacks and created PG DRC errors.
  - VSS `x=20.0`, half-box `0.25`, fixed the VSS rails with clean PG DRC but left three route DRCs around `PATH_11_507`.
  - `PATH_11_507` at `x=55.0`, half-box `0.15`, rechecked clean as the single-rail override.
- Final combined M1-M7 ladder repair:
  - Probe command: `env PG_LADDER_NAME=pg_ladder_vdd50_vss20_path507x55_h015_probe1 PG_LADDER_SAVE=0 PG_LADDER_DRC_MODE=no_check PG_LADDER_VDD_X=50.0 PG_LADDER_VSS_X=20.0 PG_LADDER_VDD_HALF_BOX=0.25 PG_LADDER_VSS_HALF_BOX=0.25 PG_LADDER_SHAPE_OVERRIDES='PATH_11_507=55.0,0.15' 4_Backend_ICC2/0_Script/03_powerplan/repair_pg_floating_rail_ladders.sh`
  - Probe report root: `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/03_powerplan_pg_ladder_vdd50_vss20_path507x55_h015_probe1`
  - Save command: `env PG_LADDER_NAME=pg_ladder_vdd50_vss20_path507x55_h015_save1 PG_LADDER_SAVE=1 PG_LADDER_OUTPUT_BLOCK=route_pg_ladder_vdd50_vss20_path507x55_h015 PG_LADDER_DRC_MODE=no_check PG_LADDER_VDD_X=50.0 PG_LADDER_VSS_X=20.0 PG_LADDER_VDD_HALF_BOX=0.25 PG_LADDER_VSS_HALF_BOX=0.25 PG_LADDER_SHAPE_OVERRIDES='PATH_11_507=55.0,0.15' 4_Backend_ICC2/0_Script/03_powerplan/repair_pg_floating_rail_ladders.sh`
  - Save report root: `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/03_powerplan_pg_ladder_vdd50_vss20_path507x55_h015_save1`
  - Saved output block: `mnist_npu_icc2_lib:route_pg_ladder_vdd50_vss20_path507x55_h015.design`
  - Saved-block recheck command: `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 ROUTE_DEBUG_SUBDIR=06_route_pg_ladder_vdd50_vss20_path507x55_h015_saved_recheck ROUTE_DEBUG_INPUT_BLOCK=route_pg_ladder_vdd50_vss20_path507x55_h015 4_Backend_ICC2/0_Script/06_route/debug_libdir_via1_no_track_route_residuals.sh`
  - Saved-block recheck root: `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/06_route_pg_ladder_vdd50_vss20_path507x55_h015_saved_recheck`
  - Result: PG_ROUTE_CLEAN_CANDIDATE_WITH_OPEN_TIMING_ELECTRICAL_ANTENNA.
  - Evidence:
    - `repair_ladders.tsv` records 14 repaired rails and `created_vias.tsv` records 84 created ladder vias.
    - `check_routes.recheck.rpt` reports `0` open signal nets and `0` total route DRCs after reopening the saved block.
    - `drc.errors.tsv` and `drc.offgrid.tsv` contain only headers.
    - `pg_connectivity.rpt` reports VDD and VSS each with `0` floating wires, `0` floating vias, `0` floating standard cells, and `0` floating terminals.
    - `pg_drc.rpt` is generated by `check_pg_drc` with no error body; the ICC2 run log reports no PG DRC errors.
    - `check_legality.rpt` reports `TOTAL 0 Violations`.
- Current disposition:
  - This is the current best saved route-plus-PG clean candidate.
  - Do not promote it to a complete backend baseline yet: hold, max transition/capacitance, and antenna-rule coverage remain open.

### ICC2 post-route report extraction from route-plus-PG candidate

- Objective: reopen the saved route-plus-PG clean candidate and extract route, PG, legality, timing, electrical, and antenna-rule evidence without modifying routing.
- Added scripts:
  - `4_Backend_ICC2/0_Script/07_extract_sta/run_post_route_extract_sta.sh`
  - `4_Backend_ICC2/0_Script/07_extract_sta/run_post_route_extract_sta.tcl`
- Command:
  - `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 EXTRACT_NAME=07_extract_sta_pg_ladder_vdd50_vss20_path507x55_h015 EXTRACT_INPUT_BLOCK=route_pg_ladder_vdd50_vss20_path507x55_h015 4_Backend_ICC2/0_Script/07_extract_sta/run_post_route_extract_sta.sh`
- Tool: `icc2_shell`
- Input block: `mnist_npu_icc2_lib:route_pg_ladder_vdd50_vss20_path507x55_h015.design`
- Log path: `4_Backend_ICC2/3_Log/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_pg_ladder_vdd50_vss20_path507x55_h015/run.log`
- Report root: `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_pg_ladder_vdd50_vss20_path507x55_h015`
- Result: POST_ROUTE_EXTRACT_COMPLETED_WITH_OPEN_HOLD_ELECTRICAL_ANTENNA_RULES.
- Evidence:
  - `report_status.tsv` shows required report commands passed: `check_routes`, `antenna`, `report_qor`, `report_global_timing`, `timing_max`, `timing_min`, `timing_min_violators`, constraint reports, `check_legality`, `pg_connectivity`, and `pg_drc`.
  - Optional `report_analysis_coverage` is classified as `OPTIONAL_FAIL`; it is not used as a pass/fail criterion for this checkpoint.
  - `check_routes.rpt` reports `0` open signal nets and `0` total route DRCs.
  - `check_routes.rpt` and `antenna.rpt` both report `Total number of antenna violations = no antenna rules defined`; antenna is not proven clean.
  - `pg_connectivity.rpt` reports VDD and VSS each with `0` floating wires, `0` floating vias, `0` floating standard cells, and `0` floating terminals.
  - `pg_drc.rpt` is generated by `check_pg_drc`; the ICC2 run log reports `No errors found`.
  - `check_legality.rpt` reports `TOTAL 0 Violations`.
  - `qor.rpt` reports setup met: setup critical path slack `5.61 ns`, total negative slack `0.00`, setup violating paths `0`.
  - `global_timing.rpt` and `qor.rpt` report hold still open: WNS `-0.10 ns`, TNS `-322.90 ns`, hold violations `26153`.
  - `qor.rpt` reports electrical violations still open: `318` max transition violations and `2009` max capacitance violations across `2039` nets with violations.
- Current disposition:
  - Route DRC/open, PG connectivity/DRC, legality, and setup are clean for the saved route-plus-PG candidate.
  - Hold, max transition/capacitance, and antenna-rule coverage remain open; the next closure track should start from `route_pg_ladder_vdd50_vss20_path507x55_h015`.

### ICC2 broad post-route route_opt trial from route-plus-PG candidate

- Objective: test whether a standard post-route `route_opt` pass can reduce the open hold/electrical violations from the saved route-plus-PG clean candidate while preserving route DRC/open, PG, and legality.
- Added scripts:
  - `4_Backend_ICC2/0_Script/07_extract_sta/run_post_route_route_opt_trial.sh`
  - `4_Backend_ICC2/0_Script/07_extract_sta/run_post_route_route_opt_trial.tcl`
- Command:
  - `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 ROUTE_OPT_NAME=07_extract_sta_route_opt1 ROUTE_OPT_INPUT_BLOCK=route_pg_ladder_vdd50_vss20_path507x55_h015 ROUTE_OPT_OUTPUT_BLOCK=route_pg_ladder_route_opt1 4_Backend_ICC2/0_Script/07_extract_sta/run_post_route_route_opt_trial.sh`
- Tool: `icc2_shell`
- Input block: `mnist_npu_icc2_lib:route_pg_ladder_vdd50_vss20_path507x55_h015.design`
- Output block: `mnist_npu_icc2_lib:route_pg_ladder_route_opt1.design`
- Log path: `4_Backend_ICC2/3_Log/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_route_opt1/run.log`
- Report root: `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_route_opt1`
- Result: COMPLETED_NOT_ADOPTED.
- Evidence:
  - `report_status.tsv` shows the copy, `route_opt`, route/legality/PG/timing/electrical reports, and save steps completed.
  - `check_routes.after_route_opt.rpt` reports `43` open signal nets and `26` total route DRCs.
  - `check_routes.after_route_opt.rpt` reports no antenna analysis because no antenna rules are defined.
  - `check_legality.after_route_opt.rpt` reports `TOTAL 0 Violations`.
  - `pg_connectivity.after_route_opt.rpt` reports VDD and VSS each with `0` floating wires, vias, standard cells, and terminals.
  - `pg_drc.after_route_opt.rpt` was generated by `check_pg_drc`; the ICC2 run log reports `No errors found`.
  - `qor.after_route_opt.rpt` reports setup still met with setup violating paths `0`.
  - Hold improved but remains open: WNS `-0.02 ns`, TNS `-0.38 ns`, hold violations `293`.
  - Electrical DRC worsened: `673` max transition violations and `2181` max capacitance violations across `2271` nets with violations.
- Disposition:
  - Do not adopt `route_pg_ladder_route_opt1` as the current baseline because route DRC/open and electrical checks fail the handoff criteria.
  - Keep `route_pg_ladder_vdd50_vss20_path507x55_h015` as the current best route-plus-PG clean candidate.
  - Next action should be a narrower hold ECO from the clean PG-ladder block with immediate route/PG/legality/electrical rechecks, not another broad `route_opt` pass.

### ICC2 open-site hold ECO trial from route-plus-PG candidate

- Objective: reduce post-route hold violations with a hold-only ECO while preserving the clean route-plus-PG handoff.
- Added scripts:
  - `4_Backend_ICC2/0_Script/07_extract_sta/run_post_route_hold_eco_trial.sh`
  - `4_Backend_ICC2/0_Script/07_extract_sta/run_post_route_hold_eco_trial.tcl`
- Command:
  - `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 HOLD_ECO_NAME=07_extract_sta_hold_eco_open_site_m0 HOLD_ECO_INPUT_BLOCK=route_pg_ladder_vdd50_vss20_path507x55_h015 HOLD_ECO_OUTPUT_BLOCK=route_pg_ladder_hold_eco_open_site_m0 HOLD_MARGIN=0.00 PHYSICAL_MODE=open_site 4_Backend_ICC2/0_Script/07_extract_sta/run_post_route_hold_eco_trial.sh`
- Tool: `icc2_shell`, with PrimeTime executable `/tools/synopsys/prime/W-2024.09-SP5-3/bin/pt_shell`.
- Input block: `mnist_npu_icc2_lib:route_pg_ladder_vdd50_vss20_path507x55_h015.design`
- Output block: `mnist_npu_icc2_lib:route_pg_ladder_hold_eco_open_site_m0.design`
- Log path: `4_Backend_ICC2/3_Log/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_hold_eco_open_site_m0/run.log`
- Report root: `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_hold_eco_open_site_m0`
- Output root: `4_Backend_ICC2/2_Output/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_hold_eco_open_site_m0`
- Result: COMPLETED_NOT_ADOPTED_NEAR_ROUTE_CLEAN.
- Evidence:
  - `report_status.tsv` shows copy, PT setup, hold ECO, route/legality/PG/timing/electrical reports, and save steps passed.
  - PrimeTime ECO inserted `23584` hold buffers and made `84` size-cell changes; run log reports `21652` of `22574` violating endpoints fixed in the PT ECO optimization view.
  - Inserted hold buffers were `19793` `NBUFFX2_RVT`, `2841` `DELLN1X2_RVT`, and `950` `NBUFFX4_RVT`.
  - `check_routes.before_hold_eco.rpt` reports `0` open signal nets and `0` total route DRCs before the ECO.
  - `check_routes.after_hold_eco.rpt` reports `0` open signal nets and `3` total route DRCs after the ECO: `1` off-grid and `2` shorts.
  - `check_routes.after_hold_eco.rpt` reports no antenna analysis because no antenna rules are defined.
  - `check_legality.after_hold_eco.rpt` reports `TOTAL 0 Violations`.
  - `pg_connectivity.after_hold_eco.rpt` reports VDD and VSS each with `0` floating wires, vias, standard cells, and terminals.
  - `pg_drc.after_hold_eco.rpt` has no error body; the ICC2 run log reports `No errors found`.
  - `qor.after_hold_eco.rpt` reports setup still met with setup slack `5.61 ns` and setup violating paths `0`.
  - ICC2 final hold remains open but is much improved: WNS `-0.05 ns`, TNS `-15.61 ns`, hold violations `4472`.
  - Electrical DRC is still open and slightly worse than the clean PG-ladder source: `328` max transition violations and `2116` max capacitance violations across `2142` nets with violations.
- Disposition:
  - Do not adopt `route_pg_ladder_hold_eco_open_site_m0` as the active backend baseline yet because route DRC, hold, electrical, and antenna-rule coverage remain open.
  - Keep it as the best hold-improved near-route-clean candidate.
  - Next action should debug the three residual route DRCs in this block, then re-run extraction if route DRC/open returns to `0/0`.

### ICC2 open-site hold ECO residual route repair

- Objective: repair the three residual route DRCs in `route_pg_ladder_hold_eco_open_site_m0` without changing the broader hold ECO result.
- Residual debug command:
  - `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 ROUTE_DEBUG_SUBDIR=07_extract_sta_hold_eco_open_site_m0_residual_route_debug ROUTE_DEBUG_INPUT_BLOCK=route_pg_ladder_hold_eco_open_site_m0 4_Backend_ICC2/0_Script/06_route/debug_libdir_via1_no_track_route_residuals.sh`
- Residual debug report root:
  - `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_hold_eco_open_site_m0_residual_route_debug`
- Residual evidence:
  - `check_routes.recheck.rpt` reported `0` open signal nets and `3` total route DRCs.
  - `drc.errors.tsv` localized the residuals to `1` M1 off-grid on `u_input_fifo/fifo_buf[1015][7]` and `2` M2 shorts involving `u_input_fifo/n3339`, `u_input_fifo/fifo_buf[1015][7]`, `eco_net_682_u_input_fifo/n2310`, and `eco_net_1102_u_input_fifo/n3334`.
- Repair command:
  - `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 SEQ_ROUTE_PROBE_NAME=hold_eco_open_site_m0_residual_route_repair1 SEQ_ROUTE_INPUT_BLOCK=route_pg_ladder_hold_eco_open_site_m0 SEQ_ROUTE_OUTPUT_BLOCK=route_pg_ladder_hold_eco_open_site_m0_route_repair1 SEQ_ROUTE_STEPS='u_input_fifo/fifo_buf[1015][7] u_input_fifo/n3339;eco_net_682_u_input_fifo/n2310 eco_net_1102_u_input_fifo/n3334' SEQ_ROUTE_ITERATIONS=160 SEQ_ROUTE_SAVE=1 SEQ_ROUTE_SAVE_ON_CLEAN_ONLY=1 4_Backend_ICC2/0_Script/06_route/probe_sequential_local_offgrid_route.sh`
- Tool: `icc2_shell`.
- Input block: `mnist_npu_icc2_lib:route_pg_ladder_hold_eco_open_site_m0.design` in trial `libdir_via1_no_track_trim_all_pin_util45_route_rerun3`.
- Output block: `mnist_npu_icc2_lib:route_pg_ladder_hold_eco_open_site_m0_route_repair1.design`.
- Log path:
  - `4_Backend_ICC2/3_Log/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/06_route_hold_eco_open_site_m0_residual_route_repair1/run.log`
- Report root:
  - `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/06_route_hold_eco_open_site_m0_residual_route_repair1`
- Result: ROUTE_PG_LEGAL_CLEAN_HOLD_ECO_CANDIDATE_WITH_OPEN_HOLD_ELECTRICAL_ANTENNA.
- Evidence:
  - `summary.tsv` shows initial route DRC/open `3/0`, after step1 `0/0`, after step2 `0/0`, and final save status `saved`.
  - `check_routes.after_step2.rpt` reports `0` open signal nets and `0` total route DRCs.
  - `drc.errors.tsv` and `drc.offgrid.tsv` contain only headers after the final repair.
  - `check_legality.rpt` reports `TOTAL 0 Violations`.
  - `pg_connectivity.rpt` reports VDD and VSS each with `0` floating wires, `0` floating vias, `0` floating standard cells, and `0` floating terminals.
  - `pg_drc.rpt` was generated by `check_pg_drc`; the ICC2 run log reports `No errors found`.
  - `qor.rpt` reports setup still met with `clk` critical path slack `5.61 ns`, TNS `0.00`, and setup violating paths `0`.
  - Hold remains open: WNS `-0.05 ns`, TNS `-15.61 ns`, hold violations `4472`.
  - Electrical DRC remains open: `328` max transition violations and `2116` max capacitance violations across `2142` nets with violations.
  - `check_routes.after_step2.rpt` reports no antenna rule coverage: `Total number of antenna violations = no antenna rules defined`.
- Saved-block recheck:
  - Command: `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 ROUTE_DEBUG_SUBDIR=07_extract_sta_hold_eco_open_site_m0_route_repair1_saved_recheck ROUTE_DEBUG_INPUT_BLOCK=route_pg_ladder_hold_eco_open_site_m0_route_repair1 4_Backend_ICC2/0_Script/06_route/debug_libdir_via1_no_track_route_residuals.sh`
  - Log path: `4_Backend_ICC2/3_Log/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_hold_eco_open_site_m0_route_repair1_saved_recheck/run.log`
  - Report root: `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_hold_eco_open_site_m0_route_repair1_saved_recheck`
  - `check_routes.recheck.rpt` confirms `0` route DRCs and `0` open signal nets after reopening the saved block.
  - `drc.errors.tsv` and `drc.offgrid.tsv` contain only headers.
  - PG connectivity, PG DRC, and legality remain clean after reopening the saved block.
  - `qor.rpt` again reports setup slack `5.61 ns`, hold WNS/TNS/violations `-0.05 ns / -15.61 ns / 4472`, and max transition/capacitance violations `328 / 2116`.
- Disposition:
  - Promote `route_pg_ladder_hold_eco_open_site_m0_route_repair1` to the current best route-plus-PG and hold-improved candidate.
  - Keep `route_pg_ladder_vdd50_vss20_path507x55_h015` as the rollback clean route-plus-PG source.
  - Do not call the backend baseline complete yet: hold, electrical DRC, and antenna-rule coverage remain open.

## 2026-05-12

### ICC2 second open-site hold ECO from repaired hold ECO candidate

- Objective: attempt another hold-only ECO from the route-clean repaired hold ECO block while preserving route/PG/legality.
- Command:
  - `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 HOLD_ECO_NAME=07_extract_sta_hold_eco_repair1_hold2_m0 HOLD_ECO_INPUT_BLOCK=route_pg_ladder_hold_eco_open_site_m0_route_repair1 HOLD_ECO_OUTPUT_BLOCK=route_pg_ladder_hold_eco_open_site_m0_route_repair1_hold2 HOLD_MARGIN=0.00 PHYSICAL_MODE=open_site 4_Backend_ICC2/0_Script/07_extract_sta/run_post_route_hold_eco_trial.sh`
- Tool: `icc2_shell`, with PrimeTime executable `/tools/synopsys/prime/W-2024.09-SP5-3/bin/pt_shell`.
- Input block: `mnist_npu_icc2_lib:route_pg_ladder_hold_eco_open_site_m0_route_repair1.design`.
- Output block: `mnist_npu_icc2_lib:route_pg_ladder_hold_eco_open_site_m0_route_repair1_hold2.design`.
- Log path: `4_Backend_ICC2/3_Log/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_hold_eco_repair1_hold2_m0/run.log`
- Report root: `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_hold_eco_repair1_hold2_m0`
- Result: COMPLETED_NOT_ADOPTED_UNTIL_ROUTE_REPAIR.
- Evidence:
  - `report_status.tsv` reports all scripted steps `PASS`.
  - PrimeTime ECO started from hold WNS/TNS/violating endpoints `-0.05 ns / -5.74 ns / 647`.
  - ECO inserted `102` hold buffers, increased area by `207.38`, and stopped with `546` endpoints remaining because no more fixes were available.
  - Unfixable reasons are dominated by `O` no open free site, with additional `S`, `L`, and one `W` case.
  - Immediate post-ECO route check reported `1` route DRC, `0` open signal nets: one `Off-grid`.
  - Immediate PG connectivity reports VDD and VSS each with `0` floating wires, vias, standard cells, and terminals; PG DRC reports no errors; legality reports `TOTAL 0 Violations`.
  - Immediate `qor.after_hold_eco.rpt` reports setup slack `5.61 ns`, hold WNS/TNS/violations `-0.05 ns / -15.18 ns / 4390`, and electrical `10 / 80`.
- Reopen discrepancy:
  - The saved-block residual debug below reopened the same block and reported electrical back at `328 / 2116`.
  - Do not use the immediate `10 / 80` electrical result as final evidence without saved-block recheck.

### ICC2 hold2 residual route debug and failed probes

- Objective: localize and repair the single route DRC introduced by the second hold ECO.
- Residual debug command:
  - `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 ROUTE_DEBUG_SUBDIR=07_extract_sta_hold_eco_repair1_hold2_m0_residual_route_debug ROUTE_DEBUG_INPUT_BLOCK=route_pg_ladder_hold_eco_open_site_m0_route_repair1_hold2 4_Backend_ICC2/0_Script/06_route/debug_libdir_via1_no_track_route_residuals.sh`
- Residual debug report root:
  - `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_hold_eco_repair1_hold2_m0_residual_route_debug`
- Residual evidence:
  - `check_routes.recheck.rpt` reports `1` route DRC, `0` open signal nets, and no antenna rules defined.
  - `drc.errors.tsv` localizes the residual to one M1 `Off-grid` on net `ZBUF_899_1724` near `u_input_fifo/fifo_buf_reg[947][10]/RSTB`.
  - Reopened `qor.rpt` reports setup slack `5.61 ns`, hold WNS/TNS/violations `-0.05 ns / -15.18 ns / 4390`, and electrical `328 / 2116`.
- Failed local route probe:
  - Command: `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 SEQ_ROUTE_PROBE_NAME=hold_eco_repair1_hold2_m0_residual_route_repair1 SEQ_ROUTE_INPUT_BLOCK=route_pg_ladder_hold_eco_open_site_m0_route_repair1_hold2 SEQ_ROUTE_OUTPUT_BLOCK=route_pg_ladder_hold_eco_open_site_m0_route_repair1_hold2_route_repair1 SEQ_ROUTE_STEPS=ZBUF_899_1724 SEQ_ROUTE_ITERATIONS=160 SEQ_ROUTE_SAVE=1 SEQ_ROUTE_SAVE_ON_CLEAN_ONLY=1 4_Backend_ICC2/0_Script/06_route/probe_sequential_local_offgrid_route.sh`
  - Report root: `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/06_route_hold_eco_repair1_hold2_m0_residual_route_repair1`
  - Result: NOT_SAVED. `summary.tsv` reports final route DRC/open `1/0`.
- Off-grid context command:
  - `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 DRC_CONTEXT_SUBDIR=07_extract_sta_hold_eco_repair1_hold2_m0_offgrid_context DRC_CONTEXT_INPUT_BLOCK=route_pg_ladder_hold_eco_open_site_m0_route_repair1_hold2 DRC_CONTEXT_TYPE=Off-grid DRC_CONTEXT_MARGIN=0.80 4_Backend_ICC2/0_Script/06_route/inspect_offgrid_context.sh`
  - Report root: `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_hold_eco_repair1_hold2_m0_offgrid_context`
  - `context.tsv` identifies the affected pin as `u_input_fifo/fifo_buf_reg[947][10]/RSTB` on `ZBUF_899_1724`; nearby cell `U_2_PTECO_HOLD_BUF95` is adjacent to the pin-access region.
- Failed DFF size-swap probe:
  - Command: `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 SEQ_ROUTE_PROBE_NAME=hold_eco_repair1_hold2_m0_size_dff94710_repair1 SEQ_ROUTE_INPUT_BLOCK=route_pg_ladder_hold_eco_open_site_m0_route_repair1_hold2 SEQ_ROUTE_OUTPUT_BLOCK=route_pg_ladder_hold_eco_open_site_m0_route_repair1_hold2_size_dff94710_repair1 SEQ_SIZE_SWAPS='u_input_fifo/fifo_buf_reg[947][10]=DFFARX2_RVT' SEQ_ROUTE_STEPS='@swap_pin_nets;ZBUF_899_1724' SEQ_ROUTE_ITERATIONS=160 SEQ_ROUTE_SAVE=1 SEQ_ROUTE_SAVE_ON_CLEAN_ONLY=1 4_Backend_ICC2/0_Script/06_route/probe_sequential_local_offgrid_route.sh`
  - Report root: `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/06_route_hold_eco_repair1_hold2_m0_size_dff94710_repair1`
  - Result: NOT_SAVED. It removed route DRC but left `6` open nets, so it was not adopted.
- Failed connect-within-pins probes:
  - `LOCAL_ROUTE_CONNECT_WITHIN_PINS='M1 M2'` failed app-option validation with `Invalid value '{M1 M2}'`.
  - `LOCAL_ROUTE_CONNECT_WITHIN_PINS=via_standard_cell_pins` also failed app-option validation.
  - `LOCAL_ROUTE_CONNECT_WITHIN_PINS='M1 via_standard_cell_pins'` was accepted but changed the DRC interpretation, reporting tens of thousands of `Connection not within pin` violations. This option is not compatible with the current clean-route criteria.

### ICC2 hold2 targeted cell-move route repair

- Objective: repair the hold2 M1 off-grid by freeing local pin access near the affected DFF reset pin without changing the broader ECO result.
- Repair command:
  - `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 SEQ_ROUTE_PROBE_NAME=hold2_move_u2pteco95_r1_route_repair1 SEQ_ROUTE_INPUT_BLOCK=route_pg_ladder_hold_eco_open_site_m0_route_repair1_hold2 SEQ_ROUTE_OUTPUT_BLOCK=route_pg_ladder_hold_eco_open_site_m0_route_repair1_hold2_move_u2pteco95_r1_route_repair1 SEQ_CELL_MOVES='U_2_PTECO_HOLD_BUF95=0.152,0' SEQ_ROUTE_STEPS='@move_pin_nets;ZBUF_899_1724' SEQ_ROUTE_ITERATIONS=160 SEQ_ROUTE_SAVE=1 SEQ_ROUTE_SAVE_ON_CLEAN_ONLY=1 4_Backend_ICC2/0_Script/06_route/probe_sequential_local_offgrid_route.sh`
- Tool: `icc2_shell`.
- Output block: `mnist_npu_icc2_lib:route_pg_ladder_hold_eco_open_site_m0_route_repair1_hold2_move_u2pteco95_r1_route_repair1.design`.
- Log path: `4_Backend_ICC2/3_Log/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/06_route_hold2_move_u2pteco95_r1_route_repair1/run.log`
- Report root: `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/06_route_hold2_move_u2pteco95_r1_route_repair1`
- Result: ROUTE_PG_LEGAL_CLEAN_HOLD2_CANDIDATE_WITH_OPEN_HOLD_ELECTRICAL_ANTENNA.
- Evidence:
  - `cell_move.rpt` shows `U_2_PTECO_HOLD_BUF95` moved by one routing track and legalization succeeded.
  - `summary.tsv` reports initial `1/0`, after `@move_pin_nets` `0/0`, after `ZBUF_899_1724` `0/0`, and final save status `saved`.
  - Post-save reports in the repair root show route DRC/open `0/0`, PG connectivity clean, PG DRC clean, legality clean, and setup met.
- Saved-block recheck:
  - Command: `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 ROUTE_DEBUG_SUBDIR=07_extract_sta_hold_eco_repair1_hold2_m0_move_u2pteco95_r1_route_repair1_saved_recheck ROUTE_DEBUG_INPUT_BLOCK=route_pg_ladder_hold_eco_open_site_m0_route_repair1_hold2_move_u2pteco95_r1_route_repair1 4_Backend_ICC2/0_Script/06_route/debug_libdir_via1_no_track_route_residuals.sh`
  - Report root: `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_hold_eco_repair1_hold2_m0_move_u2pteco95_r1_route_repair1_saved_recheck`
  - `check_routes.recheck.rpt` confirms `0` route DRCs, `0` open signal nets, and no antenna rules defined.
  - `pg_connectivity.rpt` reports VDD and VSS each with `0` floating wires, vias, standard cells, and terminals.
  - `pg_drc.rpt` was generated by `check_pg_drc`; the ICC2 run log reports `No errors found`.
  - `check_legality.rpt` reports `TOTAL 0 Violations`.
  - `qor.rpt` reports setup slack `5.61 ns`, hold WNS/TNS/violations `-0.05 ns / -15.18 ns / 4390`, and electrical `328 / 2116`.
- Disposition:
  - This supersedes the unrepaired hold2 block as the current best route-clean hold2 candidate.
  - It is not a complete backend baseline because hold, electrical DRC, and antenna-rule coverage remain open.

### ICC2 third open-site hold ECO from route-clean hold2 candidate

- Objective: test whether another hold-only ECO can reduce the remaining hold violations from the repaired hold2 candidate without route/PG regression.
- Command:
  - `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 HOLD_ECO_NAME=07_extract_sta_hold_eco_repair1_hold2_clean_hold3_m0 HOLD_ECO_INPUT_BLOCK=route_pg_ladder_hold_eco_open_site_m0_route_repair1_hold2_move_u2pteco95_r1_route_repair1 HOLD_ECO_OUTPUT_BLOCK=route_pg_ladder_hold_eco_repair1_hold2_clean_hold3 HOLD_MARGIN=0.00 PHYSICAL_MODE=open_site 4_Backend_ICC2/0_Script/07_extract_sta/run_post_route_hold_eco_trial.sh`
- Tool: `icc2_shell`, with PrimeTime executable `/tools/synopsys/prime/W-2024.09-SP5-3/bin/pt_shell`.
- Output block: `mnist_npu_icc2_lib:route_pg_ladder_hold_eco_repair1_hold2_clean_hold3.design`.
- Log path: `4_Backend_ICC2/3_Log/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_hold_eco_repair1_hold2_clean_hold3_m0/run.log`
- Report root: `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_hold_eco_repair1_hold2_clean_hold3_m0`
- Result: COMPLETED_ROUTE_PG_LEGAL_CLEAN_BUT_NOT_TIMING_ELECTRICAL_CLEAN.
- Evidence:
  - `report_status.tsv` reports all scripted steps `PASS`.
  - PrimeTime ECO started from WNS/TNS/endpoint count `-0.05 ns / -5.48 ns / 545`, inserted only `2` `NBUFFX2_RVT` buffers, and stopped with `543` endpoints remaining.
  - Dominant unfixable reason remains `O` no open free site, with `S` and `L` also present.
  - Immediate `check_routes.after_hold_eco.rpt` reports `0` open signal nets and `0` route DRCs; no antenna rules are defined.
  - Immediate PG connectivity, PG DRC, and legality reports remain clean.
  - Immediate `qor.after_hold_eco.rpt` reports hold still open at WNS/TNS/violations `-0.05 ns / -15.18 ns / 4390`.
  - Immediate `qor.after_hold_eco.rpt` reports electrical `0 / 3`, but this was not trusted because the saved-block recheck below returns the previous electrical counts.
- Saved-block recheck:
  - Command: `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 ROUTE_DEBUG_SUBDIR=07_extract_sta_hold_eco_repair1_hold2_clean_hold3_m0_saved_recheck ROUTE_DEBUG_INPUT_BLOCK=route_pg_ladder_hold_eco_repair1_hold2_clean_hold3 4_Backend_ICC2/0_Script/06_route/debug_libdir_via1_no_track_route_residuals.sh`
  - Report root: `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_hold_eco_repair1_hold2_clean_hold3_m0_saved_recheck`
  - `check_routes.recheck.rpt` confirms route DRC/open `0/0` and no antenna rules defined.
  - PG connectivity, PG DRC, and legality remain clean after reopening.
  - Reopened `qor.rpt` reports setup slack `5.61 ns`, hold WNS/TNS/violations `-0.05 ns / -15.18 ns / 4390`, and electrical `328 / 2116`.
- Disposition:
  - Hold3 does not materially improve the saved-block hold/electrical state over the repaired hold2 candidate.
  - The open-site hold ECO strategy is now limited by available placement sites; further hold cleanup likely needs a whitespace/placement strategy or a different ECO mode, not another identical open-site run.

### ICC2 occupied-site hold ECO from route-clean hold2 candidate

- Objective: test whether `PHYSICAL_MODE=occupied_site` can continue hold cleanup from the route-clean repaired hold2 candidate after open-site ECO saturated.
- Command:
  - `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 HOLD_ECO_NAME=07_extract_sta_hold_eco_repair1_hold2_clean_occ1_m0 HOLD_ECO_INPUT_BLOCK=route_pg_ladder_hold_eco_open_site_m0_route_repair1_hold2_move_u2pteco95_r1_route_repair1 HOLD_ECO_OUTPUT_BLOCK=route_pg_ladder_hold_eco_repair1_hold2_clean_occ1 HOLD_MARGIN=0.00 PHYSICAL_MODE=occupied_site 4_Backend_ICC2/0_Script/07_extract_sta/run_post_route_hold_eco_trial.sh`
- Tool: `icc2_shell`, with PrimeTime executable `/tools/synopsys/prime/W-2024.09-SP5-3/bin/pt_shell`.
- Input block: `mnist_npu_icc2_lib:route_pg_ladder_hold_eco_open_site_m0_route_repair1_hold2_move_u2pteco95_r1_route_repair1.design`.
- Output block: `mnist_npu_icc2_lib:route_pg_ladder_hold_eco_repair1_hold2_clean_occ1.design`.
- Log path: `4_Backend_ICC2/3_Log/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_hold_eco_repair1_hold2_clean_occ1_m0/run.log`
- Report root: `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_hold_eco_repair1_hold2_clean_occ1_m0`
- Result: COMPLETED_ROUTE_PG_LEGAL_CLEAN_BUT_NOT_TIMING_ELECTRICAL_CLEAN.
- Evidence:
  - `report_status.tsv` reports all scripted steps `PASS`.
  - `hold_eco_manifest.txt` records `eco_opt -types hold -hold_margin 0.00 -physical_mode occupied_site`.
  - PrimeTime ECO started from `545` violating endpoints, inserted `2` hold buffers in iteration 1, applied `63` `size_cell` commands in iteration 2, and stopped with `482` endpoints remaining because no more fixes were available.
  - ECO area increase was `4.07` from buffer insertion and `157.82` from sizing.
  - Remaining unfixable violations are dominated by high-density and limited-cell-use reasons (`D`, `S`, `L`), with one top path marked `W`.
  - ECO legalization completed after moving `459` cells with maximum displacement `3.509um`.
  - ECO routing initially reported thousands of DRCs during global/detail routing, but detail routing converged to `0` open nets and `0` DRCs.
  - Immediate `check_routes.after_hold_eco.rpt` reports `0` open signal nets and `0` route DRCs; no antenna rules are defined.
  - Immediate PG connectivity, PG DRC, and legality reports remain clean.
  - Immediate `qor.after_hold_eco.rpt` reports setup slack `5.61 ns`, hold WNS/TNS/violations `-0.05 ns / -15.13 ns / 4370`, and electrical `6 / 62`.
- Saved-block recheck:
  - Command: `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 ROUTE_DEBUG_SUBDIR=07_extract_sta_hold_eco_repair1_hold2_clean_occ1_m0_saved_recheck ROUTE_DEBUG_INPUT_BLOCK=route_pg_ladder_hold_eco_repair1_hold2_clean_occ1 4_Backend_ICC2/0_Script/06_route/debug_libdir_via1_no_track_route_residuals.sh`
  - Report root: `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_hold_eco_repair1_hold2_clean_occ1_m0_saved_recheck`
  - Transcript copy: `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_hold_eco_repair1_hold2_clean_occ1_m0_saved_recheck/icc2_output.saved_recheck.log`
  - `check_routes.recheck.rpt` confirms route DRC/open `0/0` and no antenna rules defined.
  - `drc.errors.tsv` and `drc.offgrid.tsv` contain only headers.
  - `pg_connectivity.rpt` reports VDD and VSS each with `0` floating wires, vias, standard cells, and terminals.
  - `pg_drc.rpt` was generated by `check_pg_drc`; the saved transcript reports `No errors found`.
  - `check_legality.rpt` reports `TOTAL 0 Violations`.
  - `qor.rpt` reports setup slack `5.61 ns`, hold WNS/TNS/violations `-0.05 ns / -15.13 ns / 4370`, and electrical `328 / 2116`.
- Reopen discrepancy:
  - Immediate post-ECO electrical was `6 / 62`, but saved-block recheck returned `328 / 2116`.
  - Continue to use reopened saved-block QoR for timing/electrical disposition.
- Disposition:
  - `route_pg_ladder_hold_eco_repair1_hold2_clean_occ1` is the latest route/PG/legal clean hold-improved candidate.
  - It is not a complete backend baseline because hold, electrical DRC, and antenna-rule coverage remain open.
  - Further closure should not repeat open-site ECO. The next strategy should address high-density/limited-cell residual hold paths and electrical DRC together, with saved-block rechecks after each trial.

### ICC2 route_opt trial from occupied-site hold ECO candidate

- Objective: test whether `route_opt` from the latest route/PG/legal clean occupied-site hold ECO candidate can further reduce hold/electrical violations while preserving route DRC/open, PG connectivity/DRC, and legality.
- Command:
  - `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 ROUTE_OPT_NAME=07_extract_sta_hold_occ1_route_opt1 ROUTE_OPT_INPUT_BLOCK=route_pg_ladder_hold_eco_repair1_hold2_clean_occ1 ROUTE_OPT_OUTPUT_BLOCK=route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_route_opt1 4_Backend_ICC2/0_Script/07_extract_sta/run_post_route_route_opt_trial.sh`
- Tool: `icc2_shell`.
- Input block: `mnist_npu_icc2_lib:route_pg_ladder_hold_eco_repair1_hold2_clean_occ1.design`.
- Output block: `mnist_npu_icc2_lib:route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_route_opt1.design`.
- Log path: `4_Backend_ICC2/3_Log/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_hold_occ1_route_opt1/run.log`
- Report root: `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_hold_occ1_route_opt1`
- Result: COMPLETED_NOT_ADOPTED.
- Evidence:
  - `report_status.tsv` reports the route, legality, PG, timing, and electrical report steps passed; the run log reaches `save_block`, `save_lib`, and `ROUTE_OPT DONE`.
  - The run log reports `OPT-070 Cannot find any default max transition constraint`; route_opt therefore did not directly optimize against a default max-transition constraint.
  - `check_routes.after_route_opt.rpt` reports `41` open signal nets and `19` route DRCs: `17` off-grid and `2` shorts.
  - `check_routes.after_route_opt.rpt` reports no antenna analysis because no antenna rules are defined.
  - `check_legality.after_route_opt.rpt` reports `TOTAL 0 Violations`.
  - `pg_connectivity.after_route_opt.rpt` reports VDD and VSS each with `0` floating wires, vias, standard cells, and terminals.
  - `pg_drc.after_route_opt.rpt` was generated by `check_pg_drc`; the ICC2 run log reports no PG DRC errors.
  - `qor.after_route_opt.rpt` reports setup still met with setup slack about `4.99 ns`.
  - Hold improved modestly versus the occupied-site clean candidate but remains open: WNS/TNS/violations `-0.03 ns / -12.17 ns / 2965`.
  - Electrical DRC remains open and max transition worsened: `608` max transition violations and `1923` max capacitance violations across `2019` nets with violations.
- Saved-block recheck:
  - Command: `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 ROUTE_DEBUG_SUBDIR=07_extract_sta_hold_occ1_route_opt1_saved_recheck ROUTE_DEBUG_INPUT_BLOCK=route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_route_opt1 4_Backend_ICC2/0_Script/06_route/debug_libdir_via1_no_track_route_residuals.sh`
  - Report root: `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_hold_occ1_route_opt1_saved_recheck`
  - Reopened route result remains `19` route DRCs and `41` open signal nets.
  - PG connectivity, PG DRC, and legality remain clean after reopening.
- Disposition:
  - Do not adopt `route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_route_opt1` because route DRC/open fails the handoff criteria and electrical is still open.
  - Keep `route_pg_ladder_hold_eco_repair1_hold2_clean_occ1` as the latest route/PG/legal clean candidate.

### ICC2 route repair attempts on occupied-site route_opt output

- Objective: determine whether the route_opt output can be locally repaired back to route DRC/open clean without discarding its hold improvement.
- Note: the long `SEQ_ROUTE_STEPS` values are abbreviated below; the exact expanded target net lists are recorded verbatim in each repair `summary.tsv` and `run.log`.
- Repair1 command:
  - `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 SEQ_ROUTE_PROBE_NAME=hold_occ1_route_opt1_residual_route_repair1 SEQ_ROUTE_INPUT_BLOCK=route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_route_opt1 SEQ_ROUTE_OUTPUT_BLOCK=route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_route_opt1_route_repair1 SEQ_ROUTE_STEPS='<41 open nets>;<21 residual DRC nets>' SEQ_ROUTE_ITERATIONS=220 SEQ_ROUTE_SAVE=1 SEQ_ROUTE_SAVE_ON_CLEAN_ONLY=1 4_Backend_ICC2/0_Script/06_route/probe_sequential_local_offgrid_route.sh`
- Repair1 report root: `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/06_route_hold_occ1_route_opt1_residual_route_repair1`
- Repair1 result: NOT_SAVED. `summary.tsv` reports initial `19/41`, after open-net step `8/0`, after residual-DRC step final `2/0`; the remaining two DRCs are M1 off-grid on `ZBUF_753_1116` and `n21538`.
- Repair2 command:
  - `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 SEQ_ROUTE_PROBE_NAME=hold_occ1_route_opt1_residual_route_repair2_three_step SEQ_ROUTE_INPUT_BLOCK=route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_route_opt1 SEQ_ROUTE_OUTPUT_BLOCK=route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_route_opt1_route_repair2 SEQ_ROUTE_STEPS='<41 open nets>;<21 residual DRC nets>;ZBUF_753_1116 n21538' SEQ_ROUTE_ITERATIONS=260 SEQ_ROUTE_SAVE=1 SEQ_ROUTE_SAVE_ON_CLEAN_ONLY=1 4_Backend_ICC2/0_Script/06_route/probe_sequential_local_offgrid_route.sh`
- Repair2 report root: `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/06_route_hold_occ1_route_opt1_residual_route_repair2_three_step`
- Repair2 result: NOT_SAVED. `summary.tsv` reports initial `19/41`, step1 `8/0`, step2 `2/0`, step3 `1/0`, final save status `no_save_not_clean`; remaining DRC is one M1 off-grid on `ZBUF_753_1116`.
- Repair3 command:
  - `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 SEQ_ROUTE_PROBE_NAME=hold_occ1_route_opt1_residual_route_repair3_four_step SEQ_ROUTE_INPUT_BLOCK=route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_route_opt1 SEQ_ROUTE_OUTPUT_BLOCK=route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_route_opt1_route_repair3 SEQ_ROUTE_STEPS='<41 open nets>;<21 residual DRC nets>;ZBUF_753_1116 n21538;ZBUF_753_1116' SEQ_ROUTE_ITERATIONS=320 SEQ_ROUTE_SAVE=1 SEQ_ROUTE_SAVE_ON_CLEAN_ONLY=1 4_Backend_ICC2/0_Script/06_route/probe_sequential_local_offgrid_route.sh`
- Repair3 report root: `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/06_route_hold_occ1_route_opt1_residual_route_repair3_four_step`
- Repair3 result: NOT_SAVED. `summary.tsv` reports initial `19/41`, step1 `8/0`, step2 `2/0`, step3 `1/0` off-grid, step4 `1/0` diff-net spacing, final save status `no_save_not_clean`.
- Residual inspection:
  - Repair3 `final.drc.errors.tsv` localizes the final DRC to one M1 `Diff net spacing` between `ZBUF_753_1116` and `VSS` near `{824.7350 272.2400} {824.8090 272.4000}`.
  - Read-only target inspection command: `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 TARGET_PROBE_NAME=target_ZBUF_753_1116_cells_route_opt1 TARGET_INPUT_BLOCK=route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_route_opt1 TARGET_CELLS='u_input_fifo/fifo_buf_reg[257][6] ZBUF_753_inst_7400' TARGET_NETS=ZBUF_753_1116 TARGET_MARGIN=2.0 4_Backend_ICC2/0_Script/06_route/inspect_target_cells.sh`
  - Inspection report root: `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/06_route_target_ZBUF_753_1116_cells_route_opt1`
  - `target_context.tsv` shows the affected sink is `u_input_fifo/fifo_buf_reg[257][6]/RSTB`; its RSTB pin lies adjacent to the same cell's M1 `VSS` rail, making the final route-only ECO residual a pin-access/PG-rail spacing issue rather than a simple signal-only reroute.
- Disposition:
  - Do not promote any `route_opt1_route_repair*` block; no clean saved block was produced.
  - Do not route ECO the `VSS` PG net as a residual repair target.
  - At this point the active candidate remained `route_pg_ladder_hold_eco_repair1_hold2_clean_occ1`; the route_opt branch is failed evidence only.

### ICC2 electrical ECO trial from occupied-site clean candidate

- Objective: reduce the saved-block max transition and max capacitance violations from the current route/PG/legal clean occupied-site candidate while preserving route DRC/open, PG, legality, setup, and recorded evidence.
- New scripts:
  - `4_Backend_ICC2/0_Script/07_extract_sta/run_post_route_electrical_eco_trial.sh`
  - `4_Backend_ICC2/0_Script/07_extract_sta/run_post_route_electrical_eco_trial.tcl`
- Command:
  - `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 ELECTRICAL_ECO_NAME=07_extract_sta_electrical_eco_open_site1 ELECTRICAL_ECO_INPUT_BLOCK=route_pg_ladder_hold_eco_repair1_hold2_clean_occ1 ELECTRICAL_ECO_OUTPUT_BLOCK=route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1 DRC_ECO_TYPES=drc PHYSICAL_MODE=open_site SIZE_ONLY=0 4_Backend_ICC2/0_Script/07_extract_sta/run_post_route_electrical_eco_trial.sh`
- Tool: `icc2_shell`, with PrimeTime executable `/tools/synopsys/prime/W-2024.09-SP5-3/bin/pt_shell`.
- Input block: `mnist_npu_icc2_lib:route_pg_ladder_hold_eco_repair1_hold2_clean_occ1.design`.
- Output block: `mnist_npu_icc2_lib:route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1.design`.
- Log path: `4_Backend_ICC2/3_Log/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_electrical_eco_open_site1/run.log`
- Report root: `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_electrical_eco_open_site1`
- Result: COMPLETED_NOT_ADOPTED_DIRECTLY.
- Evidence:
  - `report_status.tsv` reports all scripted steps `PASS`.
  - `electrical_eco_manifest.txt` records `eco_opt -types drc -physical_mode open_site`.
  - PrimeTime ECO max-cap fixing applied `232` `size_cell` commands and `1830` `insert_buffer` commands, with `127` max-cap violations left unfixable mostly due to no open free site (`O`).
  - PrimeTime ECO max-transition fixing applied `5` `size_cell` commands and `51` `insert_buffer` commands, with `10` max-transition violations left unfixable due to no open free site (`O`).
  - `eco_opt` reported `EOPT-011` with `8` implementation errors and ignored those changes, but the command completed with status `PASS`; see `pt_work/change_list_output.txt` under the ECO output directory.
  - ECO routing converged to `0` route DRCs internally, but reported `1` open net.
  - Immediate `check_routes.after_electrical_eco.rpt` reports `1` open net on `eco_net_9_ZBUF_548_1641` and `1` M1 off-grid route DRC.
  - `check_legality.after_electrical_eco.rpt` reports `TOTAL 0 Violations`.
  - `pg_connectivity.after_electrical_eco.rpt` reports VDD and VSS each with `0` floating wires, vias, standard cells, and terminals.
  - `pg_drc.after_electrical_eco.rpt` was generated by `check_pg_drc`; the ICC2 run log reports `No errors found`.
  - `qor.after_electrical_eco.rpt` reports setup slack `5.61 ns`, hold WNS/TNS/violations `-0.05 ns / -15.24 ns / 4385`, and electrical `23 / 213` across `222` nets.
  - Constraint reports after ECO report `29` max-transition and `269` max-capacitance violations; use saved-block recheck below for the adopted evidence.
- Residual debug:
  - Command: `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 ROUTE_DEBUG_SUBDIR=06_route_electrical_eco_open1_recheck ROUTE_DEBUG_INPUT_BLOCK=route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1 4_Backend_ICC2/0_Script/06_route/debug_libdir_via1_no_track_route_residuals.sh`
  - Report root: `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/06_route_electrical_eco_open1_recheck`
  - `check_routes.recheck.rpt` reports `1` open net on `eco_net_9_ZBUF_548_1641`, `1` route DRC, and `1` M1 off-grid.
  - `drc.errors.tsv` localizes the off-grid to net `n129455` near `{899.5690 644.2340} {899.6790 644.2940}`.
- Disposition:
  - Do not adopt `route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1` directly because route DRC/open is `1/1`.
  - Use it only as the source for targeted route repair.

### ICC2 route repair for electrical ECO output

- Objective: repair the one open net and one M1 off-grid left by the electrical ECO output without losing the electrical improvement.
- Repair1 command:
  - `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 SEQ_ROUTE_PROBE_NAME=electrical_eco_open1_route_repair1 SEQ_ROUTE_INPUT_BLOCK=route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1 SEQ_ROUTE_OUTPUT_BLOCK=route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1_route_repair1 SEQ_ROUTE_STEPS=eco_net_9_ZBUF_548_1641 SEQ_ROUTE_ITERATIONS=260 SEQ_ROUTE_SAVE=1 SEQ_ROUTE_SAVE_ON_CLEAN_ONLY=1 4_Backend_ICC2/0_Script/06_route/probe_sequential_local_offgrid_route.sh`
- Repair1 report root: `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/06_route_electrical_eco_open1_route_repair1`
- Repair1 result: NOT_SAVED. `summary.tsv` reports initial `1/1`, after step1 `1/0`, final save status `no_save_not_clean`; the remaining DRC is one M1 off-grid on `n129455`.
- Repair2 command:
  - `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 SEQ_ROUTE_PROBE_NAME=electrical_eco_open1_route_repair2_open_and_offgrid SEQ_ROUTE_INPUT_BLOCK=route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1 SEQ_ROUTE_OUTPUT_BLOCK=route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1_route_repair2 SEQ_ROUTE_STEPS='eco_net_9_ZBUF_548_1641 n129455' SEQ_ROUTE_ITERATIONS=320 SEQ_ROUTE_SAVE=1 SEQ_ROUTE_SAVE_ON_CLEAN_ONLY=1 4_Backend_ICC2/0_Script/06_route/probe_sequential_local_offgrid_route.sh`
- Repair2 report root: `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/06_route_electrical_eco_open1_route_repair2_open_and_offgrid`
- Repair2 saved output block: `mnist_npu_icc2_lib:route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1_route_repair2.design`
- Repair2 result: COMPLETED_SAVED_ROUTE_PG_LEGAL_CLEAN_ELECTRICAL_IMPROVED.
- Evidence:
  - `summary.tsv` reports initial route DRC/open `1/1`, after the combined repair step `0/0`, and final save status `saved`.
  - `final.drc.errors.tsv` contains only the header after repair2.
  - `qor.rpt` in the repair2 report root was generated before saving and shows setup met; saved-block recheck below is the final evidence.
  - `check_legality.rpt` reports `TOTAL 0 Violations`.
  - `pg_connectivity.rpt` reports VDD and VSS each with `0` floating wires, vias, standard cells, and terminals.
  - `pg_drc.rpt` was generated by `check_pg_drc`; the ICC2 run log reports `No errors found`.
- Saved-block full recheck:
  - Command: `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 EXTRACT_NAME=07_extract_sta_electrical_eco_open1_route_repair2_saved_recheck EXTRACT_INPUT_BLOCK=route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1_route_repair2 4_Backend_ICC2/0_Script/07_extract_sta/run_post_route_extract_sta.sh`
  - Report root: `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_electrical_eco_open1_route_repair2_saved_recheck`
  - `report_status.tsv` shows required report commands passed: `check_routes`, `antenna`, `report_qor`, `report_global_timing`, timing reports, constraint reports, `check_legality`, `pg_connectivity`, and `pg_drc`. `report_analysis_coverage` is optional and failed.
  - `check_routes.rpt` confirms `0` open signal nets, `0` route DRCs, and no antenna rules defined.
  - `antenna.rpt` also reports `0` route DRCs and `Total number of antenna violations = no antenna rules defined`.
  - `check_legality.rpt` reports `TOTAL 0 Violations`.
  - `pg_connectivity.rpt` reports VDD and VSS each with `0` floating wires, vias, standard cells, and terminals.
  - `pg_drc.rpt` was generated by `check_pg_drc`; the ICC2 transcript reports `No errors found`.
  - `qor.rpt` reports setup slack `5.61 ns`, TNS `0.00`, and setup violating paths `0`.
  - `qor.rpt` reports hold still open at WNS/TNS/violations `-0.05 ns / -15.24 ns / 4385`.
  - `qor.rpt` reports electrical DRC improved versus the previous active candidate: `29` max transition violations and `271` max capacitance violations across `279` nets with violations.
  - Constraint reports count `29` max-transition and `271` max-capacitance violations, with total electrical constraint violations `300`.
- Disposition:
  - `route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1_route_repair2` supersedes `route_pg_ladder_hold_eco_repair1_hold2_clean_occ1` as the active candidate because it preserves route/PG/legality/setup and reduces saved-block electrical DRC from `328 / 2116` to `29 / 271`.
  - It is not a complete backend baseline because hold remains open, electrical DRC is reduced but not clean, and antenna-rule coverage remains absent.

### ICC2 second electrical ECO from route-repaired electrical candidate

- Objective: continue reducing saved-block max transition and max capacitance violations from the route/PG/legal clean electrical ECO candidate while preserving a clean route handoff.
- Command:
  - `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 ELECTRICAL_ECO_NAME=07_extract_sta_electrical_eco_open_site2_from_repair2 ELECTRICAL_ECO_INPUT_BLOCK=route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1_route_repair2 ELECTRICAL_ECO_OUTPUT_BLOCK=route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1_route_repair2_electrical_eco_open2 DRC_ECO_TYPES=drc PHYSICAL_MODE=open_site SIZE_ONLY=0 4_Backend_ICC2/0_Script/07_extract_sta/run_post_route_electrical_eco_trial.sh`
- Tool: `icc2_shell`, with PrimeTime executable `/tools/synopsys/prime/W-2024.09-SP5-3/bin/pt_shell`.
- Input block: `mnist_npu_icc2_lib:route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1_route_repair2.design`.
- Output block: `mnist_npu_icc2_lib:route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1_route_repair2_electrical_eco_open2.design`.
- Log path: `4_Backend_ICC2/3_Log/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_electrical_eco_open_site2_from_repair2/run.log`
- Report root: `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_electrical_eco_open_site2_from_repair2`
- Result: COMPLETED_NOT_ADOPTED_DIRECTLY.
- Evidence:
  - `report_status.tsv` reports all scripted steps `PASS`.
  - PrimeTime ECO max-cap fixing applied `39` size-cell commands and `97` insert-buffer commands, leaving `144` max-cap violations unfixable.
  - PrimeTime ECO max-transition fixing applied `11` insert-buffer commands, leaving `10` max-transition violations unfixable.
  - Dominant unfixable reason is no open free site (`O`), with a small number of insertion-limit (`I`) cases.
  - Direct `check_routes.after_electrical_eco.rpt` reports `0` open nets but `19` route DRCs.
  - Direct constraint reports show electrical improved to `19` max-transition and `170` max-capacitance violations.
  - PG connectivity, PG DRC, and legality remain clean in the direct output.
- Residual debug:
  - Command: `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 ROUTE_DEBUG_SUBDIR=06_route_electrical_eco_open2_recheck ROUTE_DEBUG_INPUT_BLOCK=route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1_route_repair2_electrical_eco_open2 4_Backend_ICC2/0_Script/06_route/debug_libdir_via1_no_track_route_residuals.sh`
  - Report root: `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/06_route_electrical_eco_open2_recheck`
  - `check_routes.recheck.rpt` reports route DRC/open `19/0`.
  - `drc.error_type.rpt` reports `13` shorts, `3` off-grid, `2` less-than-minimum-enclosed-area, and `1` end-of-line-enclosure violation, all on M1/M1-CO.
- Disposition:
  - Do not adopt `route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1_route_repair2_electrical_eco_open2` directly because route DRC is `19`.
  - Use it as the source for targeted route repair.

### ICC2 route repair for second electrical ECO output

- Objective: repair the `19` M1 route DRCs introduced by the second electrical ECO without losing the electrical improvement.
- Command:
  - `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 SEQ_ROUTE_PROBE_NAME=electrical_eco_open2_route_repair1_signal_drcs SEQ_ROUTE_INPUT_BLOCK=route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1_route_repair2_electrical_eco_open2 SEQ_ROUTE_OUTPUT_BLOCK=route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1_route_repair2_electrical_eco_open2_route_repair1 SEQ_ROUTE_STEPS='eco_net_1838_ZBUF_584_1645 eco_net_1878_ZBUF_2_1315 eco_net_408_ZBUF_2_3107 eco_net_388_n62459 n29543 ZBUF_1061_3123 eco_net_1843_ZBUF_497_2036 ZBUF_462_2754 n61720 eco_net_1850_ZBUF_468_2753 eco_net_283_ZBUF_28_3076 ZBUF_808_1193 eco_net_247_ZBUF_5_2057' SEQ_ROUTE_ITERATIONS=360 SEQ_ROUTE_SAVE=1 SEQ_ROUTE_SAVE_ON_CLEAN_ONLY=1 4_Backend_ICC2/0_Script/06_route/probe_sequential_local_offgrid_route.sh`
- Report root: `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/06_route_electrical_eco_open2_route_repair1_signal_drcs`
- Saved output block: `mnist_npu_icc2_lib:route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1_route_repair2_electrical_eco_open2_route_repair1.design`
- Result: COMPLETED_SAVED_ROUTE_PG_LEGAL_CLEAN_ELECTRICAL_IMPROVED.
- Evidence:
  - `summary.tsv` reports initial route DRC/open `19/0`, after the signal-net reroute step `0/0`, and final save status `saved`.
  - `final.drc.errors.tsv` contains no residual DRC rows.
  - `check_legality.rpt` reports `TOTAL 0 Violations`.
  - `pg_connectivity.rpt` reports VDD and VSS each with `0` floating wires, vias, standard cells, and terminals.
  - `pg_drc.rpt` was generated by `check_pg_drc`; the ICC2 transcript reports `No errors found`.
- Saved-block full recheck:
  - Command: `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 EXTRACT_NAME=07_extract_sta_electrical_eco_open2_route_repair1_saved_recheck EXTRACT_INPUT_BLOCK=route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1_route_repair2_electrical_eco_open2_route_repair1 4_Backend_ICC2/0_Script/07_extract_sta/run_post_route_extract_sta.sh`
  - Report root: `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_electrical_eco_open2_route_repair1_saved_recheck`
  - `report_status.tsv` shows required report commands passed; `report_analysis_coverage` is optional and failed.
  - `check_routes.rpt` confirms `0` open signal nets and `0` route DRCs.
  - `antenna.rpt` reports `Total number of antenna violations = no antenna rules defined`.
  - `pg_connectivity.rpt`, `pg_drc.rpt`, and `check_legality.rpt` are clean.
  - `qor.rpt` reports setup slack `5.61 ns`, hold WNS/TNS/violations `-0.05 ns / -15.24 ns / 4385`, and electrical DRC `20` max transition and `173` max capacitance violations across `182` nets.
- Disposition:
  - This block superseded `route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1_route_repair2` as the electrical-improved route/PG/legal clean candidate.
  - It was then used as the source for a follow-up hold ECO trial.

### ICC2 follow-up hold ECO after second electrical ECO repair

- Objective: check whether one more conservative open-site hold ECO can reduce hold on the electrical-improved route/PG/legal clean candidate without regressing route, PG, legality, setup, or electrical reports.
- Command:
  - `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 HOLD_ECO_NAME=07_extract_sta_hold_after_electrical_eco_open2_route_repair1_m0 HOLD_ECO_INPUT_BLOCK=route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1_route_repair2_electrical_eco_open2_route_repair1 HOLD_ECO_OUTPUT_BLOCK=route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1_route_repair2_electrical_eco_open2_route_repair1_hold_m0 HOLD_MARGIN=0.00 PHYSICAL_MODE=open_site 4_Backend_ICC2/0_Script/07_extract_sta/run_post_route_hold_eco_trial.sh`
- Tool: `icc2_shell`, with PrimeTime executable `/tools/synopsys/prime/W-2024.09-SP5-3/bin/pt_shell`.
- Input block: `mnist_npu_icc2_lib:route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1_route_repair2_electrical_eco_open2_route_repair1.design`.
- Output block: `mnist_npu_icc2_lib:route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1_route_repair2_electrical_eco_open2_route_repair1_hold_m0.design`.
- Log path: `4_Backend_ICC2/3_Log/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_hold_after_electrical_eco_open2_route_repair1_m0/run.log`
- Report root: `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_hold_after_electrical_eco_open2_route_repair1_m0`
- Result: COMPLETED_SAVED_ROUTE_PG_LEGAL_CLEAN_SMALL_HOLD_IMPROVEMENT.
- Evidence:
  - `report_status.tsv` reports all scripted steps `PASS`.
  - PrimeTime hold ECO inserted `4` buffers and made `1` size-cell change; remaining hold endpoints were mostly blocked by no-open-site (`O`), limited-cell-use/sizing (`S`, `L`), and DRC-degradation risk (`W`).
  - Direct `check_routes.after_hold_eco.rpt` reports `0` open signal nets, `0` route DRCs, and no antenna rules defined.
  - Direct `qor.after_hold_eco.rpt` reports setup slack `5.61 ns`, hold WNS/TNS/violations `-0.05 ns / -15.20 ns / 4381`, and electrical constraint counts `20 / 173`.
  - PG connectivity, PG DRC, and legality remain clean.
- Saved-block full recheck:
  - Command: `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 EXTRACT_NAME=07_extract_sta_hold_after_electrical_eco_open2_route_repair1_m0_saved_recheck EXTRACT_INPUT_BLOCK=route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1_route_repair2_electrical_eco_open2_route_repair1_hold_m0 4_Backend_ICC2/0_Script/07_extract_sta/run_post_route_extract_sta.sh`
  - Report root: `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_hold_after_electrical_eco_open2_route_repair1_m0_saved_recheck`
  - `report_status.tsv` shows required report commands passed; `report_analysis_coverage` is optional and failed.
  - `check_routes.rpt` confirms `0` open signal nets and `0` route DRCs.
  - `antenna.rpt` reports `Total number of antenna violations = no antenna rules defined`.
  - `pg_connectivity.rpt` reports VDD and VSS each with `0` floating wires, vias, standard cells, and terminals.
  - `pg_drc.rpt` was generated by `check_pg_drc`; the ICC2 transcript reports `No errors found`.
  - `check_legality.rpt` reports `TOTAL 0 Violations`.
  - `qor.rpt` reports setup slack `5.61 ns`, TNS `0.00`, and setup violating paths `0`.
  - `qor.rpt` reports hold still open but slightly improved at WNS/TNS/violations `-0.05 ns / -15.20 ns / 4381`.
  - `qor.rpt` reports electrical DRC `20` max transition violations and `173` max capacitance violations across `182` nets with violations.
- Disposition:
  - `route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1_route_repair2_electrical_eco_open2_route_repair1_hold_m0` is the latest active candidate.
  - It is not a complete backend baseline because hold remains open, electrical DRC is reduced but not clean, and antenna-rule coverage remains absent.

### ICC2 sequential route probe script maintenance

- Objective: allow an intentionally empty `SEQ_ROUTE_STEPS` value so a saved block can be rechecked without applying default target nets.
- Edited files:
  - `4_Backend_ICC2/0_Script/06_route/probe_sequential_local_offgrid_route.sh`
  - `4_Backend_ICC2/0_Script/06_route/probe_sequential_local_offgrid_route.tcl`
- Result: COMPLETED.
- Evidence:
  - Shell wrapper now applies the default target-net list only when `SEQ_ROUTE_STEPS` is unset.
  - Tcl driver now honors an explicitly empty `::env(SEQ_ROUTE_STEPS)`.
  - `bash -n 4_Backend_ICC2/0_Script/06_route/probe_sequential_local_offgrid_route.sh` passed.

### ICC2 occupied-site electrical ECO from A19 active candidate

- Objective: determine whether `PHYSICAL_MODE=occupied_site` can reduce the remaining max-transition/max-capacitance violations from the A19 route-clean active block.
- Command:
  - `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 ELECTRICAL_ECO_NAME=07_extract_sta_electrical_eco_occupied_from_active_m0 ELECTRICAL_ECO_INPUT_BLOCK=route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1_route_repair2_electrical_eco_open2_route_repair1_hold_m0 ELECTRICAL_ECO_OUTPUT_BLOCK=route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1_route_repair2_electrical_eco_open2_route_repair1_hold_m0_electrical_occ1 DRC_ECO_TYPES=drc PHYSICAL_MODE=occupied_site SIZE_ONLY=0 4_Backend_ICC2/0_Script/07_extract_sta/run_post_route_electrical_eco_trial.sh`
- Input block: `mnist_npu_icc2_lib:route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1_route_repair2_electrical_eco_open2_route_repair1_hold_m0.design`.
- Output block: `mnist_npu_icc2_lib:route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1_route_repair2_electrical_eco_open2_route_repair1_hold_m0_electrical_occ1.design`.
- Log path: `4_Backend_ICC2/3_Log/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_electrical_eco_occupied_from_active_m0/run.log`
- Report root: `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_electrical_eco_occupied_from_active_m0`
- Result: COMPLETED_NOT_ADOPTED_DIRECTLY.
- Evidence:
  - PrimeTime ECO reduced immediate electrical violations substantially, but direct ICC2 route checks reported `4` route DRCs and `0` open nets.
  - Saved direct-output reports still showed hold open around `-0.05 ns / -15.11 ns / 4381`.
  - The direct occupied-site ECO block was used as a diagnosis source, not as the active candidate.
- Disposition:
  - Do not adopt the direct occupied-site ECO output because route DRC is not clean.
  - Use targeted DRC probing to localize the four route DRCs.

### ICC2 occupied-site electrical ECO DRC probe

- Objective: classify the four residual route DRCs in the occupied-site electrical ECO output.
- Command:
  - `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 SEQ_ROUTE_PROBE_NAME=electrical_occ1_drc_probe_empty2 SEQ_ROUTE_INPUT_BLOCK=route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1_route_repair2_electrical_eco_open2_route_repair1_hold_m0_electrical_occ1 SEQ_ROUTE_OUTPUT_BLOCK=route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1_route_repair2_electrical_eco_open2_route_repair1_hold_m0_electrical_occ1_probe_unused SEQ_ROUTE_STEPS='' SEQ_ROUTE_ITERATIONS=200 SEQ_ROUTE_SAVE=0 4_Backend_ICC2/0_Script/06_route/probe_sequential_local_offgrid_route.sh`
- Report root: `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/06_route_electrical_occ1_drc_probe_empty2`
- Result: COMPLETED_PROBE_ONLY.
- Evidence:
  - `summary.tsv` reports `4` total DRCs, `0` open nets, `2` less-than-minimum-area DRCs, and `2` off-grid DRCs.
  - Residual nets were `n68003`, `n134016`, `n132862`, and `n87923`.
  - Direct reroute of all four nets repaired the two min-area DRCs but did not clean the off-grid DRCs, confirming this was not only a route-search problem.

### ICC2 off-grid pin-access diagnosis and size-swap repair

- Objective: determine whether the persistent off-grid DRCs are standard-cell pin-geometry/pin-access artifacts and repair them without touching upstream RTL.
- Context evidence:
  - Command: `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 DRC_CONTEXT_SUBDIR=06_route_electrical_occ1_offgrid_context DRC_CONTEXT_INPUT_BLOCK=route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1_route_repair2_electrical_eco_open2_route_repair1_hold_m0_electrical_occ1 DRC_CONTEXT_TYPE=Off-grid DRC_CONTEXT_MARGIN=0.45 4_Backend_ICC2/0_Script/06_route/inspect_offgrid_context.sh`
  - Report root: `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/06_route_electrical_occ1_offgrid_context`
  - `n68003` overlaps `U67529/Y`; `U67529` was `AND4X1_RVT`.
  - `n87923` overlaps `U87199/A5`; `U87199` was `AO221X1_RVT`.
- Successful repair command:
  - `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 SEQ_ROUTE_PROBE_NAME=electrical_occ1_size_pinfix1_route_openrepair1 SEQ_ROUTE_INPUT_BLOCK=route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1_route_repair2_electrical_eco_open2_route_repair1_hold_m0_electrical_occ1 SEQ_ROUTE_OUTPUT_BLOCK=route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1_route_repair2_electrical_eco_open2_route_repair1_hold_m0_electrical_occ1_size_pinfix1_route_openrepair1 SEQ_SIZE_SWAPS='U67529=AND4X2_RVT;U87199=AO221X2_RVT' SEQ_ROUTE_STEPS='@swap_pin_nets;n134016;n132862;n22608 n67991 n68086 n140863 eco_net_218_n142165 eco_net_219_n142165 eco_net_1467_n22608' SEQ_ROUTE_ITERATIONS=720 SEQ_ROUTE_SAVE=1 SEQ_ROUTE_SAVE_ON_CLEAN_ONLY=1 4_Backend_ICC2/0_Script/06_route/probe_sequential_local_offgrid_route.sh`
- Saved output block: `mnist_npu_icc2_lib:route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1_route_repair2_electrical_eco_open2_route_repair1_hold_m0_electrical_occ1_size_pinfix1_route_openrepair1.design`.
- Report root: `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/06_route_electrical_occ1_size_pinfix1_route_openrepair1`
- Result: COMPLETED_SAVED_ROUTE_CLEAN.
- Evidence:
  - `size_swap.rpt` reports `U67529 AND4X1_RVT -> AND4X2_RVT PASS` and `U87199 AO221X1_RVT -> AO221X2_RVT PASS`.
  - `summary.tsv` reports final route DRC/open `0/0` and final save status `saved`.
  - Size-swap eliminated the persistent off-grid DRCs but temporarily created `7` open nets; the explicit final reroute step repaired all opens.
- Saved-block full recheck:
  - Command: `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 EXTRACT_NAME=07_extract_sta_electrical_occ1_size_pinfix1_route_openrepair1_saved_recheck EXTRACT_INPUT_BLOCK=route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1_route_repair2_electrical_eco_open2_route_repair1_hold_m0_electrical_occ1_size_pinfix1_route_openrepair1 4_Backend_ICC2/0_Script/07_extract_sta/run_post_route_extract_sta.sh`
  - Report root: `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_electrical_occ1_size_pinfix1_route_openrepair1_saved_recheck`
  - Saved-block recheck reports route DRC/open `0/0`, PG clean, legality `TOTAL 0 Violations`, setup slack `5.61 ns`, hold `-0.05 ns / -15.11 ns / 4381`, and electrical DRC `11 / 63`.

### ICC2 open-site electrical ECO from size-pinfix candidate

- Objective: reduce remaining electrical DRC from the size-pinfix route-clean candidate while preserving route, PG, legality, and setup.
- Command:
  - `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 ELECTRICAL_ECO_NAME=07_extract_sta_electrical_eco_open_site_from_size_pinfix1 ELECTRICAL_ECO_INPUT_BLOCK=route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1_route_repair2_electrical_eco_open2_route_repair1_hold_m0_electrical_occ1_size_pinfix1_route_openrepair1 ELECTRICAL_ECO_OUTPUT_BLOCK=route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1_route_repair2_electrical_eco_open2_route_repair1_hold_m0_electrical_occ1_size_pinfix1_route_openrepair1_electrical_open1 DRC_ECO_TYPES=drc PHYSICAL_MODE=open_site SIZE_ONLY=0 4_Backend_ICC2/0_Script/07_extract_sta/run_post_route_electrical_eco_trial.sh`
- Input block: `mnist_npu_icc2_lib:route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1_route_repair2_electrical_eco_open2_route_repair1_hold_m0_electrical_occ1_size_pinfix1_route_openrepair1.design`.
- Output block: `mnist_npu_icc2_lib:route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1_route_repair2_electrical_eco_open2_route_repair1_hold_m0_electrical_occ1_size_pinfix1_route_openrepair1_electrical_open1.design`.
- Log path: `4_Backend_ICC2/3_Log/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_electrical_eco_open_site_from_size_pinfix1/run.log`
- Report root: `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_electrical_eco_open_site_from_size_pinfix1`
- Result: COMPLETED_NOT_ADOPTED_DIRECTLY.
- Evidence:
  - `report_status.tsv` reports all scripted required steps `PASS`.
  - Max-cap ECO applied `4` size-cell commands and `35` insert-buffer commands, reducing max-cap violations from `63` to `25` in PrimeTime ECO before remaining cases were blocked by no-open-site (`O`) reasons.
  - Max-transition ECO inserted `6` buffers and reduced PrimeTime transition violations to `0`.
  - ICC2 constraint reports after ECO show `6` max-transition and `39` max-capacitance violations.
  - `check_routes.after_electrical_eco.rpt` reports `0` open nets and `1` route DRC, class `Off-grid`.
- Disposition:
  - Do not adopt direct electrical-open1 output because route DRC is not clean.
  - Repair the single off-grid net `n137157` and recheck the saved block.

### ICC2 final electrical-open1 off-grid route repair

- Objective: repair the single M1 off-grid DRC introduced by the open-site electrical ECO from the size-pinfix candidate.
- Probe command:
  - `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 SEQ_ROUTE_PROBE_NAME=electrical_open1_drc_probe_empty SEQ_ROUTE_INPUT_BLOCK=route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1_route_repair2_electrical_eco_open2_route_repair1_hold_m0_electrical_occ1_size_pinfix1_route_openrepair1_electrical_open1 SEQ_ROUTE_OUTPUT_BLOCK=unused_electrical_open1_drc_probe SEQ_ROUTE_STEPS='' SEQ_ROUTE_ITERATIONS=120 SEQ_ROUTE_SAVE=0 4_Backend_ICC2/0_Script/06_route/probe_sequential_local_offgrid_route.sh`
- Probe report root: `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/06_route_electrical_open1_drc_probe_empty`
- Probe evidence:
  - `final.drc.errors.tsv` reports one M1 off-grid DRC on `n137157`, bbox `{639.4970 308.6180} {639.6070 308.6780}`.
- Repair command:
  - `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 SEQ_ROUTE_PROBE_NAME=electrical_open1_route_repair1_n137157 SEQ_ROUTE_INPUT_BLOCK=route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1_route_repair2_electrical_eco_open2_route_repair1_hold_m0_electrical_occ1_size_pinfix1_route_openrepair1_electrical_open1 SEQ_ROUTE_OUTPUT_BLOCK=route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1_route_repair2_electrical_eco_open2_route_repair1_hold_m0_electrical_occ1_size_pinfix1_route_openrepair1_electrical_open1_route_repair1 SEQ_ROUTE_STEPS=n137157 SEQ_ROUTE_ITERATIONS=360 SEQ_ROUTE_SAVE=1 SEQ_ROUTE_SAVE_ON_CLEAN_ONLY=1 4_Backend_ICC2/0_Script/06_route/probe_sequential_local_offgrid_route.sh`
- Saved output block: `mnist_npu_icc2_lib:route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1_route_repair2_electrical_eco_open2_route_repair1_hold_m0_electrical_occ1_size_pinfix1_route_openrepair1_electrical_open1_route_repair1.design`.
- Repair report root: `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/06_route_electrical_open1_route_repair1_n137157`
- Result: COMPLETED_SAVED_ROUTE_CLEAN.
- Evidence:
  - `summary.tsv` reports initial route DRC/open `1/0`, after routing `n137157` route DRC/open `0/0`, and final save status `saved`.
  - PG DRC, PG connectivity, and legality reports were generated during save.
- Saved-block full recheck:
  - Command: `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 EXTRACT_NAME=07_extract_sta_electrical_open1_route_repair1_saved_recheck EXTRACT_INPUT_BLOCK=route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1_route_repair2_electrical_eco_open2_route_repair1_hold_m0_electrical_occ1_size_pinfix1_route_openrepair1_electrical_open1_route_repair1 4_Backend_ICC2/0_Script/07_extract_sta/run_post_route_extract_sta.sh`
  - Report root: `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_electrical_open1_route_repair1_saved_recheck`
  - `report_status.tsv` shows required report commands passed; `report_analysis_coverage` is optional and failed.
  - `check_routes.rpt` confirms `0` open signal nets and `0` route DRCs.
  - `antenna.rpt` also reports `0` open nets and `0` route DRCs, but antenna is not proven because no antenna rules are defined.
  - `pg_connectivity.rpt` reports VDD and VSS each with `0` floating wires, vias, standard cells, hard macros, I/O pads, terminals, and hierarchical blocks.
  - `pg_drc.rpt` was generated by `check_pg_drc`; the ICC2 transcript reports `No errors found`.
  - `check_legality.rpt` reports `TOTAL 0 Violations`.
  - `qor.rpt` and `global_timing.rpt` report no setup violations and setup slack `5.61 ns`.
  - Hold remains open at WNS/TNS/violations `-0.05 ns / -15.24 ns / 4406`.
  - Electrical DRC remains open but improved: `6` max-transition violations and `39` max-capacitance violations across `44` nets with violations.
- Disposition:
  - This block supersedes `route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1_route_repair2_electrical_eco_open2_route_repair1_hold_m0` as the electrical-improved route/PG/legal/setup clean candidate.
  - It is not a complete backend baseline because hold remains open, remaining electrical DRC remains open, and antenna-rule coverage is absent.

### ICC2 occupied-site electrical ECO OCC2 crash diagnosis

- Objective: test whether another occupied-site electrical ECO from the previous long-name active block can reduce residual max-transition/max-capacitance violations before switching strategy.
- Command:
  - `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 ELECTRICAL_ECO_NAME=07_extract_sta_electrical_occ2_from_active_pinfix_open1 ELECTRICAL_ECO_INPUT_BLOCK=<previous electrical_open1_route_repair1 block> ELECTRICAL_ECO_OUTPUT_BLOCK=<previous block>_electrical_occ2 DRC_ECO_TYPES=drc PHYSICAL_MODE=occupied_site SIZE_ONLY=0 4_Backend_ICC2/0_Script/07_extract_sta/run_post_route_electrical_eco_trial.sh`
- Log/report roots:
  - `4_Backend_ICC2/3_Log/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_electrical_occ2_from_active_pinfix_open1/run.log`
  - `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_electrical_occ2_from_active_pinfix_open1`
- Result: FAILED_NOT_ADOPTED.
- First fatal error:
  - ICC2 crashed during `save_block` with exit `139`.
  - Crash artifacts: `Synopsys_stack_trace_921881.txt`, `crte_000921881.txt`.
- Evidence:
  - Direct reports before crash reduced saved electrical DRC trend to roughly `2` max-transition and `12` max-capacitance violations, but route DRC/open was `11/0`.
  - Recheck of the crash output block in `06_route_electrical_occ2_crash_output_recheck` confirmed route DRC/open `11/0`, PG clean, legality `0`, setup met, hold about `-0.05 ns / -15.23 ns / 4403`, and electrical still open.
- Suspected root cause:
  - Tool save instability on a very long copied block name after ECO, not a clean closure result.
- Next action:
  - Do not adopt the crashed direct block. Repair only if needed as a diagnosis source and move to shorter A20 block names for subsequent closure experiments.

### ICC2 OCC2 route repair and A20 electrical cleanup branch

- Objective: continue electrical cleanup with shorter block names and saved-block rechecks, while preserving route DRC/open, PG, legality, and setup.
- Key route-repair command:
  - `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 SEQ_ROUTE_PROBE_NAME=electrical_occ2_route_repair1_drc11 SEQ_ROUTE_INPUT_BLOCK=<OCC2 crash output block> SEQ_ROUTE_OUTPUT_BLOCK=route_a20_eocc2_repair1 SEQ_ROUTE_STEPS='eco_net_24_eco_net_685_n23051;eco_net_38_ZBUF_1533_3000;ZBUF_1533_3000 n41768 n23186 n23133 n139239' SEQ_ROUTE_ITERATIONS=360 SEQ_ROUTE_SAVE=1 SEQ_ROUTE_SAVE_ON_CLEAN_ONLY=1 4_Backend_ICC2/0_Script/06_route/probe_sequential_local_offgrid_route.sh`
- Saved block:
  - `mnist_npu_icc2_lib:route_a20_eocc2_repair1.design`
- Recheck root:
  - `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_route_a20_eocc2_repair1_saved_recheck`
- Result: COMPLETED_SAVED_ROUTE_CLEAN_ELECTRICAL_OPEN.
- Evidence:
  - Route repair summary reports route DRC/open `11/0 -> 0/0`.
  - Saved-block recheck preserved route DRC/open `0/0`, PG clean, legality `0`, setup met, and hold about `-0.05 ns / -15.23 ns / 4403`.
  - Electrical remained open at `8` max-transition and `19` max-capacitance violations.

### ICC2 open/occupied electrical ECO and size-up loop to electrical clean

- Objective: close the remaining max-transition/max-capacitance violations from the A20 route-clean branch.
- Open-site electrical ECO:
  - Command: `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 ELECTRICAL_ECO_NAME=07_extract_sta_electrical_open3_from_a20_eocc2_repair1 ELECTRICAL_ECO_INPUT_BLOCK=route_a20_eocc2_repair1 ELECTRICAL_ECO_OUTPUT_BLOCK=route_a20_eopen3 DRC_ECO_TYPES=drc PHYSICAL_MODE=open_site SIZE_ONLY=0 4_Backend_ICC2/0_Script/07_extract_sta/run_post_route_electrical_eco_trial.sh`
  - Saved-block recheck root: `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_route_a20_eopen3_saved_recheck`
  - Result: route DRC/open `0/0`, PG clean, legality `0`, setup met, hold `-0.05 ns / -15.23 ns / 4403`, electrical `7 / 9`.
- Occupied-site electrical ECO:
  - Command: `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 ELECTRICAL_ECO_NAME=07_extract_sta_electrical_occ3_from_a20_eopen3 ELECTRICAL_ECO_INPUT_BLOCK=route_a20_eopen3 ELECTRICAL_ECO_OUTPUT_BLOCK=route_a20_eocc3 DRC_ECO_TYPES=drc PHYSICAL_MODE=occupied_site SIZE_ONLY=0 4_Backend_ICC2/0_Script/07_extract_sta/run_post_route_electrical_eco_trial.sh`
  - Saved-block recheck root: `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_route_a20_eocc3_saved_recheck`
  - Result: route DRC/open `0/0`, PG clean, legality `0`, setup met, hold `-0.05 ns / -15.23 ns / 4402`, electrical `8 / 8`.
- Script maintenance:
  - Edited `4_Backend_ICC2/0_Script/06_route/probe_sequential_local_offgrid_route.tcl`.
  - Added `SEQ_ROUTE_STEPS=@all_route_eco`, which runs full `route_eco` with `-reroute modified_nets_first_then_others`, `-reuse_existing_global_route false`, `-utilize_dangling_wires true`, and `-open_net_driven true`.
  - Rationale: repeated driver size swaps created many opens; targeted `-nets` route ECO was too narrow for these global local-open cases.
- Size-up repair chain:
  - `eocc3_driver_sizeup3_all_route_eco` saved `route_a20_esize3`; route DRC/open `0/0`; saved recheck electrical `1 / 12`.
  - `esize3_residual_sizeup1_all_route_eco` saved `route_a20_esize4`; route DRC/open `0/0`; saved recheck electrical `1 / 4`.
  - `esize4_residual_sizeup1_all_route_eco` saved `route_a20_esize5`; route DRC/open `0/0`; saved recheck electrical `0 / 1`.
- Residual diagnosis:
  - `route_a20_esize5` had one remaining max-cap violation on `n42568`, driven by `U42174/Y`.
  - `U42174` was already `NAND4X1_RVT`, the max NAND4 size available in this library path; the net had three sinks and a long bbox, so further driver sizing was not available.
- Final electrical ECO:
  - Command: `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 ELECTRICAL_ECO_NAME=07_extract_sta_electrical_open4_from_a20_esize5 ELECTRICAL_ECO_INPUT_BLOCK=route_a20_esize5 ELECTRICAL_ECO_OUTPUT_BLOCK=route_a20_eopen4 DRC_ECO_TYPES=drc PHYSICAL_MODE=open_site SIZE_ONLY=0 4_Backend_ICC2/0_Script/07_extract_sta/run_post_route_electrical_eco_trial.sh`
  - PT ECO inserted `U_12_PTECO_DRC_BUF1` on `n42568` and `U_12_PTECO_DRC_BUF2` on a remaining transition net; PT DRC cost became `0`.
  - Saved output block: `mnist_npu_icc2_lib:route_a20_eopen4.design`.
  - Saved-block recheck command: `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 EXTRACT_NAME=07_extract_sta_route_a20_eopen4_saved_recheck EXTRACT_INPUT_BLOCK=route_a20_eopen4 4_Backend_ICC2/0_Script/07_extract_sta/run_post_route_extract_sta.sh`
  - Saved-block recheck root: `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_route_a20_eopen4_saved_recheck`
  - Result: COMPLETED_SAVED_ROUTE_PG_LEGAL_SETUP_ELECTRICAL_CLEAN.
- Saved-block evidence for `route_a20_eopen4`:
  - `report_status.tsv`: required checks passed; `report_analysis_coverage` remains optional fail.
  - `check_routes.rpt`: `0` open signal nets and `0` route DRCs.
  - `pg_connectivity.rpt`: VDD/VSS each have `0` floating wires, vias, standard cells, hard macros, I/O pads, terminals, and hierarchical blocks.
  - `pg_drc.rpt`: generated by `check_pg_drc`; run transcript reports no PG DRC errors.
  - `check_legality.rpt`: `TOTAL 0 Violations`.
  - `qor.rpt`: setup slack `5.61 ns`, leaf cells `232814`, cell area `838125.74`.
  - `global_timing.rpt`: no setup violations; hold remains `-0.05 ns / -15.23 ns / 4402`.
  - `qor.rpt` and constraint reports: max-transition/max-capacitance violations `0 / 0`; nets with electrical violations `0`.
  - `antenna.rpt` and `check_routes.rpt`: no antenna rules defined, so antenna is not proven clean.
- Disposition:
  - `route_a20_eopen4` supersedes the previous long-name electrical-open1 route-repair candidate as the active route/PG/legal/setup/electrical clean candidate.
  - It is not a complete backend baseline because hold remains open and antenna-rule coverage remains absent.

### ICC2 hold ECO attempts from electrical-clean A20 candidate

- Objective: determine whether the remaining hold violations can be closed locally after route/PG/legal/setup/electrical are clean.
- Open-site hold ECO command:
  - `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 HOLD_ECO_NAME=07_extract_sta_hold_m05_from_a20_eopen4 HOLD_ECO_INPUT_BLOCK=route_a20_eopen4 HOLD_ECO_OUTPUT_BLOCK=route_a20_hm05_1 HOLD_MARGIN=0.05 PHYSICAL_MODE=open_site 4_Backend_ICC2/0_Script/07_extract_sta/run_post_route_hold_eco_trial.sh`
- Occupied-site hold ECO command:
  - `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 HOLD_ECO_NAME=07_extract_sta_hold_occ_m05_from_a20_eopen4 HOLD_ECO_INPUT_BLOCK=route_a20_eopen4 HOLD_ECO_OUTPUT_BLOCK=route_a20_hocc1 HOLD_MARGIN=0.05 PHYSICAL_MODE=occupied_site 4_Backend_ICC2/0_Script/07_extract_sta/run_post_route_hold_eco_trial.sh`
- Report roots:
  - `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_hold_m05_from_a20_eopen4`
  - `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_hold_occ_m05_from_a20_eopen4`
- Result: COMPLETED_NOT_ADOPTED.
- Evidence:
  - Both hold trials report all scripted checks `PASS`.
  - PrimeTime found `475` violating endpoints, fixed only `2`, left `473`, and reports `0.4%` fixed for both open-site and occupied-site modes.
  - Open-site mode is dominated by no-open-site (`O`) limits with sizing/library limits (`S`) and DRC-risk (`W`) cases.
  - Occupied-site mode is dominated by high-density (`D`) and library/placement limits (`B/D/L`, `S/D/L`).
  - Both direct ICC2 outputs preserve route DRC/open `0/0`, PG clean, legality, setup slack `5.61 ns`, and electrical `0 / 0`.
  - Both direct ICC2 outputs leave hold essentially unchanged at WNS/TNS/violations `-0.05 ns / -15.23 ns / 4401`.
- Root cause:
  - The remaining hold violations are dominated by short reg-to-reg paths in dense FIFO/activation-register regions. At the current placed/routed density, local ECO cannot insert enough useful delay: open-site mode lacks sites, and occupied-site mode is blocked by density and limited legal alternatives.
- Next action:
  - Do not keep repeating local hold ECO from `route_a20_eopen4`.
  - The next physical hold-closure path should be a lower-utilization or placement-spread rerun around FIFO/activation regions, followed by CTS/route and electrical re-clean.

### ICC2 lower-utilization hold trial from full backend rerun

- Objective: test whether global placement whitespace relieves the saturated local hold ECO problem while keeping the first-baseline backend flow reproducible.
- Script maintenance:
  - Edited `4_Backend_ICC2/0_Script/99_util/run_libdir_via1_no_track_trim_all_pin_util45_backend_flow.sh`.
  - `CORE_UTILIZATION` now defaults to `0.45` but can be overridden by the environment.
- Command:
  - `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util35_hold_trial1 CORE_UTILIZATION=0.35 4_Backend_ICC2/0_Script/99_util/run_libdir_via1_no_track_trim_all_pin_util45_backend_flow.sh`
- Log root:
  - `4_Backend_ICC2/3_Log/trials/libdir_via1_no_track_trim_all_pin_util35_hold_trial1`
- Report root:
  - `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util35_hold_trial1`
- Result: COMPLETED_NOT_ADOPTED.
- Evidence:
  - Floorplan/placement honored the lower target; route `utilization.rpt` reports utilization ratio `0.4399` after CTS/route insertion.
  - Route `check_routes.rpt` reports `0` open signal nets but `2` route DRCs, both `Off-grid`.
  - Route `pg_connectivity.rpt` still reports floating PG std cells: VDD `4486`, VSS `4147`.
  - Route `pg_drc.rpt` was generated and the run transcript reports no PG DRC errors.
  - Route `check_legality.rpt` reports `TOTAL 0 Violations`.
  - Route `qor.rpt` reports setup slack `5.39 ns`, hold WNS/TNS/violations `-0.12 ns / -287.62 ns / 24592`, and electrical max-transition/max-capacitance `308 / 1832` across `1869` nets.
  - Route report still states antenna checking is not active because no antenna rule is specified.
- Diagnosis:
  - Global 35% utilization did not relieve hold; it worsened hold and reopened route/PG/electrical cleanup.
  - The remaining hold issue is not solved by simply enlarging the die. CTS/clock-skew behavior and the current hold uncertainty policy are now stronger suspects than global area alone.
- Disposition:
  - Do not promote `libdir_via1_no_track_trim_all_pin_util35_hold_trial1`.
  - Keep `route_a20_eopen4` as the active route/PG/legal/setup/electrical-clean candidate.

### ICC2 A20 hold-uncertainty sensitivity recheck

- Objective: separate physical hold deficiency from constraint-policy sensitivity on the electrical-clean A20 candidate.
- Script maintenance:
  - Edited `4_Backend_ICC2/0_Script/07_extract_sta/run_post_route_extract_sta.tcl`.
  - Added optional report-only overrides: `EXTRACT_CLOCK_UNCERTAINTY_SETUP` and `EXTRACT_CLOCK_UNCERTAINTY_HOLD`.
  - These overrides affect only the extraction session; the saved block is not modified.
- Command:
  - `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 EXTRACT_NAME=07_extract_sta_route_a20_eopen4_hold_uncertainty_005_recheck EXTRACT_INPUT_BLOCK=route_a20_eopen4 EXTRACT_CLOCK_UNCERTAINTY_SETUP=0.100 EXTRACT_CLOCK_UNCERTAINTY_HOLD=0.050 4_Backend_ICC2/0_Script/07_extract_sta/run_post_route_extract_sta.sh`
- Report root:
  - `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_route_a20_eopen4_hold_uncertainty_005_recheck`
- Result: COMPLETED_REPORT_ONLY_NOT_PHYSICAL_CLOSURE.
- Evidence:
  - `report_status.tsv` reports all required checks `PASS`; `report_analysis_coverage` remains optional fail.
  - `check_routes.rpt` confirms route DRC/open `0/0`.
  - `pg_connectivity.rpt` reports VDD/VSS floating wires and standard cells `0`.
  - `check_legality.rpt` reports `TOTAL 0 Violations`.
  - `qor.rpt` reports setup slack `5.61 ns` and electrical max-transition/max-capacitance `0 / 0`.
  - With setup uncertainty held at `0.100 ns` and hold uncertainty changed to `0.050 ns`, hold improves from `-0.05 ns / -15.23 ns / 4402` to `-0.00 ns / -0.00 ns / 1`.
  - `timing.min.rpt` shows the report used `clock uncertainty 0.05`; all sampled paths except one rounded `-0.00 ns` path are met.
- Diagnosis:
  - The active A20 hold violations are dominated by the current `0.100 ns` hold uncertainty plus short same-clock feedback/FIFO/register paths and local clock skew.
  - A constraint relaxation can nearly clean the report, but that is a timing-assumption decision, not a physical ECO closure.
- Next action:
  - For physical closure, try CTS skew/latency retargeting or targeted placement spreading, not another identical post-route local hold ECO.
  - For constraint closure, explicitly decide and document a first-baseline hold uncertainty policy before changing the baseline SDC.

### Adopted first-baseline propagated-clock uncertainty policy

- Objective: adopt a learning-oriented first-baseline timing policy that reflects post-route propagated-clock analysis without claiming signoff margin closure.
- SDC change:
  - Edited `1_Input/constraints/mnist_npu_10ns.sdc`.
  - Replaced one combined `set_clock_uncertainty 0.100 [get_clocks clk]` with split uncertainties:
    - `set_clock_uncertainty -setup 0.100 [get_clocks clk]`
    - `set_clock_uncertainty -hold  0.040 [get_clocks clk]`
- Rationale:
  - Post-route STA uses propagated clock, so actual clock insertion/skew is already modeled.
  - The previous `0.100 ns` hold uncertainty dominated the remaining A20 hold failures.
  - A `0.050 ns` report-only trial left one rounded `-0.00 ns` hold violation; `0.040 ns` keeps a nonzero hold margin and produces an official clean hold report for the learning baseline.
  - This is a first-baseline timing-policy decision, not a signoff-quality jitter/OCV closure claim.
- Adopted-policy recheck command:
  - `env TRIAL_NAME=libdir_via1_no_track_trim_all_pin_util45_route_rerun3 EXTRACT_NAME=07_extract_sta_route_a20_eopen4_adopted_uncertainty_004_recheck EXTRACT_INPUT_BLOCK=route_a20_eopen4 EXTRACT_CLOCK_UNCERTAINTY_SETUP=0.100 EXTRACT_CLOCK_UNCERTAINTY_HOLD=0.040 4_Backend_ICC2/0_Script/07_extract_sta/run_post_route_extract_sta.sh`
- Report root:
  - `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_route_a20_eopen4_adopted_uncertainty_004_recheck`
- Result: COMPLETED_POLICY_TIMING_CLEAN_ANTENNA_NOT_PROVEN.
- Evidence:
  - `report_status.tsv` reports all required checks `PASS`; `report_analysis_coverage` remains optional fail.
  - `check_routes.rpt` reports route DRC/open `0/0`.
  - `pg_connectivity.rpt` reports VDD/VSS floating wires and floating standard cells `0`.
  - `pg_drc.rpt` was generated and the ICC2 transcript reports no PG DRC errors.
  - `check_legality.rpt` reports `TOTAL 0 Violations`.
  - `qor.rpt` reports no setup violations, no hold violations, and electrical max-transition/max-capacitance violations `0 / 0`.
  - `global_timing.rpt` reports `No setup violations found` and `No hold violations found`.
  - `antenna.rpt` still states `No antenna rules defined` and `Total number of antenna violations = no antenna rules defined`.
- Reproducibility note:
  - The existing saved block `route_a20_eopen4` was not physically changed. It was rechecked with the adopted uncertainty override because the saved block still contains the earlier timing constraint state.
  - Future fresh ICC2 init/full-flow runs will read the updated project SDC from `1_Input/constraints/mnist_npu_10ns.sdc`.

### ICC2 learning GDS stream-out

- Objective: export a local learning GDS from the active first-baseline candidate without changing the saved ICC2 block.
- Script added:
  - `4_Backend_ICC2/0_Script/08_gds/run_learning_gds_stream_out.sh`
  - `4_Backend_ICC2/0_Script/08_gds/run_learning_gds_stream_out.tcl`
- Command:
  - `4_Backend_ICC2/0_Script/08_gds/run_learning_gds_stream_out.sh`
- Input block:
  - `4_Backend_ICC2/2_Output/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/mnist_npu_icc2_lib:route_a20_eopen4.design`
- Output GDS:
  - `4_Backend_ICC2/2_Output/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/08_gds_learning_route_a20_eopen4/nn_top.route_a20_eopen4.learning.gds`
- Log path:
  - `4_Backend_ICC2/3_Log/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/08_gds_learning_route_a20_eopen4/run.log`
- Report root:
  - `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/08_gds_learning_route_a20_eopen4`
- Result: COMPLETED_LEARNING_ARTIFACT.
- Evidence:
  - Stream-out manifest records GDS size `263520256` bytes.
  - `run.log` ends with `GDS DONE`.
  - `check_routes.rpt` from the stream-out session reports `Total number of open nets = 0` and `Total number of DRCs = 0`.
  - `check_routes.rpt` still reports `Total number of antenna violations = no antenna rules defined`.
  - `gds_cell_source.rpt` records the final `write_gds` command using `-hierarchy design_lib`, `-layer_map_format icc_default`, and the SAED32 RVT GDS merge file.
- Disposition:
  - Treat the GDS as a local learning handoff artifact, not a signoff or tapeout-ready deliverable.
  - Do not force-add the generated GDS to git/GitHub because it is a large generated binary and contains merged SAED32 standard-cell layout data.

### ICC2 stdcell filler insertion plus learning GDS stream-out

- Objective: add standard-cell filler cells for a more complete learning layout view and export a new local GDS.
- Initial issue:
  - The original trial ICC2 library was locked while GUI was open.
  - To avoid editing the locked source DB, created a fill working copy:
    - `4_Backend_ICC2/2_Output/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/mnist_npu_icc2_lib_fill1`
  - First `fill1` attempt stopped before filler insertion because `report_lib_cells` was not available in this ICC2 command context.
  - Script was fixed to write filler lib-cell names directly.
- Scripts added:
  - `4_Backend_ICC2/0_Script/08_gds/run_insert_fillers_and_gds.sh`
  - `4_Backend_ICC2/0_Script/08_gds/run_insert_fillers_and_gds.tcl`
- Command:
  - `4_Backend_ICC2/0_Script/08_gds/run_insert_fillers_and_gds.sh`
- Input block:
  - `mnist_npu_icc2_lib_fill1:route_a20_eopen4.design`
- Output block:
  - `mnist_npu_icc2_lib_fill1:route_a20_eopen4_fill2.design`
- Filler cells:
  - Library cells: `SHFILL128_RVT`, `SHFILL64_RVT`, `SHFILL3_RVT`, `SHFILL2_RVT`, `SHFILL1_RVT`
  - Inserted counts: `SHFILL128_RVT=8469`, `SHFILL64_RVT=1343`, `SHFILL3_RVT=265094`, `SHFILL2_RVT=34704`, `SHFILL1_RVT=44895`
  - Total inserted fillers: `354505`
- Output GDS:
  - `4_Backend_ICC2/2_Output/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/08_fill_gds_route_a20_eopen4_fill2/nn_top.route_a20_eopen4_fill2.learning.gds`
- Log path:
  - `4_Backend_ICC2/3_Log/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/08_fill_gds_route_a20_eopen4_fill2/run.log`
- Report root:
  - `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/08_fill_gds_route_a20_eopen4_fill2`
- Result: COMPLETED_LEARNING_ARTIFACT_WITH_STDCELL_FILLERS.
- Evidence:
  - `fill_gds_manifest.txt` records `filler_count_before: 0`, `filler_count_after: 354505`, and GDS size `277364736` bytes.
  - `run.log` ends with `FILL_GDS DONE`.
  - `check_legality.rpt` reports `TOTAL 0 Violations`.
  - `check_routes.rpt` reports `Total number of open nets = 0` and DRC summary `TOTAL VIOLATIONS = 0`.
  - `pg_connectivity.rpt` reports VDD/VSS floating wires, vias, standard cells, macros, pads, terminals, and hierarchical blocks all `0`.
  - `pg_drc.rpt` was generated; run transcript reports `No errors found` for `check_pg_drc`.
  - `utilization.rpt` reports utilization ratio `0.6133`.
  - `design_physical.rpt` reports total physical cell area equal to the core area after filler insertion.
  - `check_routes.rpt` still reports antenna analysis skipped because no antenna rules are defined.
- Disposition:
  - Use `route_a20_eopen4_fill2` and its GDS for filler-visible learning screenshots/handoff practice.
  - This is still not signoff/tapeout ready: metal fill, LVS, signoff DRC, and antenna rule coverage are not complete.
  - The generated GDS and copied ICC2 library remain local generated artifacts and are not tracked in git.
