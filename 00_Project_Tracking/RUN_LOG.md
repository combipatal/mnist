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
