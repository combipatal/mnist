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
  - Saved ICC2 library/block was created for the next floorplan stage.
  - Design report shows `175574` leaf cells, `39659` sequential cells, and `0` hard macros.
- Open warnings to classify before floorplan signoff:
  - `DCHK-010`: 16 floating/no-driver nets from the mapped structural netlist.
  - `TCK-001`: async reset endpoints reported unconstrained because reset is false-pathed.
  - `TCK-012`: reset input has no clock-relative delay.
  - ICC2 reports many `CSTR-021` warnings when reading DC-written net `set_load` constraints; next script revision should use a clean backend SDC or filtered handoff SDC.
