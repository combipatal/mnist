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
