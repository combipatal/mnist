# Decision Log

## 2026-05-09

### First Baseline Configuration

- Decision: use `nn_top` as the initial synthesis top.
- Rationale: it is the active package-based top described by the upstream README and avoids older `$readmemh`-based RTL.

### First Library Configuration

- Decision: use SAED32 RVT TT 1.05V 25C for the first DC/Formality/ICC2 baseline.
- Rationale: RVT-only keeps the first flow simple; mixed-VT and multi-corner expansion can follow after one clean route baseline exists.

### First DC Checkpoint

- Decision: run `analyze/elaborate/link/check_design` before full compile.
- Rationale: this catches RTL package, SystemVerilog, filelist, and unresolved-reference issues before spending time on optimization.

### Topographical DC Synthesis

- Decision: use `dc_shell -topographical_mode` and `compile_ultra -spg` for the first mapped synthesis handoff.
- Rationale: the project should use physically aware synthesis before ICC2, including SAED32 Milkyway technology and TLU+ RC data.

### First-Baseline DRC Risk Handling

- Decision: record DC max capacitance/max transition violations and proceed to Formality/ICC2 for the first baseline.
- Rationale: setup timing is clean, the user explicitly accepted maxcap carry-forward, and final cap/transition closure belongs in the physical implementation loop.

### Formality R2N Gate

- Decision: treat `3_Formality/0_Script/run_fm_r2n_topo.sh` PASS as the gate to proceed into ICC2 init_design.
- Rationale: the mapped topographical netlist is equivalent to the RTL reference with 39,681 passing compare points and zero failing/unverified compare points.

### Professional Project Discipline

- Decision: run project stages like a practical ASIC implementation flow.
- Rationale: every stage needs objective, pass/fail criteria, explicit script/log path, first-fatal debug, evidence recording, and risk classification before moving forward.

### ICC2 Init Warning Handling

- Decision: record ICC2 init as linked/saved with open warnings rather than call it clean.
- Rationale: the design imports and links, but async reset endpoints remain intentionally false-pathed and 16 no-driver mapped-netlist nets need classification before later closure.

### ICC2 Backend Constraint Source

- Decision: use the clean project SDC `1_Input/constraints/mnist_npu_10ns.sdc` for ICC2 bring-up instead of the DC-written mapped SDC.
- Rationale: ICC2 does not support the mapped SDC's many net `set_load` commands, while the clean project SDC preserves the baseline clock, IO delay, uncertainty, and reset false-path intent.

### Pre-Placement PG Connectivity Status

- Decision: record the first powerplan as generated but not PG-clean.
- Rationale: `compile_pg` and PG DRC pass, but `check_pg_connectivity` reports all standard cells floating before placement. PG connectivity must be rechecked after placement before claiming clean power connectivity.

### Placement Baseline Continuation

- Decision: keep the 55% utilization placement as the first baseline despite open PG connectivity and congestion.
- Rationale: placement and legalization completed with zero legality violations and PG DRC has no errors, but PG connectivity and global-route congestion are not clean. The first milestone is end-to-end flow establishment, so continue to CTS/route with these risks recorded rather than starting a utilization sweep prematurely.

## 2026-05-10

### libdir/LEF/modify NDM Trial

- Decision: do not replace the first backend baseline with the `libdir/LEF/modify` RVT NDM trial.
- Rationale: the modified NDM builds and links, but placement did not improve the open backend risks. PG connectivity was slightly worse than the baseline and phase1 global-route overflow increased from `45036` to `46959`. Keep the trial scripts for reproducibility, but continue baseline CTS from the original EDK RVT NDM unless a later route failure specifically requires another physical-abstract trial.

### First Route Baseline Disposition

- Decision: record the first route run as completed with open issues, not as a clean route.
- Rationale: `route.design` was saved and post-route reports exist, but `check_routes.rpt` reports `738` DRCs, hold remains negative, PG connectivity still has floating standard cells, max transition/cap violations remain, and antenna rules were not defined.
- Next action: debug the open route/PG/electrical issues from the completed baseline evidence before changing utilization, routing options, or library abstracts.

### Route Rerun Safety

- Decision: add a lock-file guard to `4_Backend_ICC2/0_Script/06_route/run_route_initial.sh`.
- Rationale: a duplicate route launch while ICC2 still held `cts.design` failed with `NDM-029` and partially overwrote the shared route log. Future route reruns should fail before starting ICC2 or clobbering the log when the design library is locked.

### Route DRC Debug Method

- Decision: debug the baseline route DRC as an evidence-driven lower-metal/VIA1 problem before running broad utilization or option sweeps.
- Rationale: the route DRC matrix is dominated by M1, M2, VIA1, and M1-M2 contact classes, and a simple `route_eco` trial reduced total DRC only from `738` to `709`. This points away from a small local reroute issue and toward physical abstract, pin access, and congestion interactions.

### Sibling-Project Library Policy Reference

- Decision: use the ibex and CV32E40P SAED32 backend records as controlled references, but validate any imported fix in a separate MNIST trial output root before changing the fixed baseline.
- Rationale: ibex closed route DRC with modified LEFs plus a VIA1 pitch/no-track technology patch, while CV32E40P showed partial improvement and residual off-grid risk. MNIST must preserve its first-baseline evidence and isolate library-policy experiments for reproducibility.

### libdir VIA1 no-track Trial Disposition

- Decision: keep `libdir_via1_no_track` as the strongest current route-DRC repair candidate, not as a clean baseline replacement.
- Rationale: the trial reduced final route DRC from `738` to `77`, removed needs-fat-contact and short DRCs from the final route report, and kept setup/legality acceptable. However, residual off-grid DRC remains, PG connectivity is still open, hold remains negative, and max transition/cap violations remain open.
- Next action: classify the residual off-grid DRCs from the trial route and then choose between route-level repair, lower-utilization rerun using the same NDM, or a DC cell-use policy rerun informed by ibex.

### Residual Off-grid and PG Separation

- Decision: treat residual route DRC and PG connectivity as separate closure tracks.
- Rationale: residual off-grid extraction from the VIA1 no-track trial shows `72` off-grid entries are signal-only, with `69` on M1 and `3` on M2 and no VDD/VSS object references. In contrast, PG connectivity detail reports seven isolated 1-wire/0-via sub-networks per supply net and thousands of std cells attached to those isolated rail fragments.

### Route-only ECO Disposition for Residual Off-grid

- Decision: do not rely on generic route-only ECO as the main closure path for the residual VIA1 no-track DRC.
- Rationale: route-only ECO on the trial route improved final route DRC from `77` to `55`, but it did not converge to clean and remained dominated by off-grid DRC. This is useful partial repair evidence, not a complete route-closure method.
- Next action: run a controlled placement/congestion or floorplan/utilization trial with the VIA1 no-track NDM, while debugging PG rail connectivity independently.

### Lower-utilization Trial Disposition

- Decision: do not treat lower utilization alone as the route DRC closure strategy.
- Rationale: the 45% floorplan target trial with the same libdir VIA1 no-track NDM improved official route DRC from `77` to `59`, but route remained open and final utilization still rose to `0.5669` after optimization. This confirms congestion relief helps but does not remove the lower-metal/off-grid root cause.
- Next action: test the sibling-project `trim_all_pin` NDM frame-generation policy with the same modified LEF and VIA1 no-track technology patch.

### trim_all_pin NDM Next Trial

- Decision: create a new MNIST RVT NDM trial combining libdir modified LEF, VIA1 pitch/no-track techfile, and `configure_frame_options -mode keep_obs_and_trim_all_pin`.
- Rationale: CV32E40P used this frame-generation policy to reduce a comparable lower-metal route DRC candidate from `67` to `1`. ibex also supports the broader root-cause model that SAED32 lower-metal pin access and physical-library policy dominate these residual DRCs. MNIST's current netlist has no `MUX41X2_RVT`, so NDM frame trimming is a more direct next probe than an immediate DC cell-use rerun.
- Guardrail: keep the result isolated in a trial output root and do not promote it to baseline unless route, legality, PG, timing, and evidence records justify promotion.
