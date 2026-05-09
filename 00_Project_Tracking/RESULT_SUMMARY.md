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
| ICC2 init_design | PENDING | TBD |
| Floorplan | PENDING | TBD |
| Powerplan | PENDING | TBD |
| Placement | PENDING | TBD |
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
