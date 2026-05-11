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

## 2026-05-11

### trim_all_pin util45 Route Evidence Source

- Decision: use `libdir_via1_no_track_trim_all_pin_util45_route_rerun3` as the preserved route database and primary evidence source for the trim_all_pin util45 route result.
- Rationale: `rerun2` completed and reported the same `6` route DRC level, but a later no-CCD diagnostic route was run in that same design library and overwrote the saved `route.design`/`route_auto.design`. `rerun3` recreated the full flow in a clean trial root, saved `route_auto` and `route`, and produced matching final reports.
- Guardrail: use `rerun2` and no-CCD results only as diagnostic/history. Database-based residual debug should start from `4_Backend_ICC2/2_Output/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/mnist_npu_icc2_lib:route.design`.

### trim_all_pin util45 Trial Disposition

- Decision: treat the trim_all_pin util45 rerun3 route as the best current full-flow route-DRC candidate, not as a clean baseline replacement.
- Rationale: official route DRC improved from the 55% first-route baseline's `738` DRCs and the previous VIA1 no-track util45 trial's `59` DRCs down to `6`, with `0` open signal nets and clean legality. However, all six route DRCs remain open as off-grid violations, PG connectivity still has thousands of floating standard cells, hold remains negative, max transition/cap violations remain open, and antenna is not proven because no antenna rules are defined.
- Next action: debug the six residual off-grid DRCs from rerun3 while keeping PG rail connectivity as a separate closure track.

### trim_all_pin util45 Route-only ECO Disposition

- Decision: keep `route_eco_offgrid1` as partial route-only repair evidence, not as a clean baseline replacement.
- Rationale: ECO reduced official route DRC from `6` to `5` and kept open signal nets at `0`, setup met, legality clean, and PG DRC without reported errors. But the router stopped as not converging, all five residual DRCs remain M1 off-grid errors, PG connectivity is unchanged, hold/electrical closure remains open, and antenna rules are still absent.
- Next action: analyze the five residual ECO off-grid objects before running another broad ECO loop; if another change is needed, prefer a targeted pin-access/cell-use or local-route experiment over repeating generic ECO blindly.

### Targeted Residual Route Repair Disposition

- Decision: use targeted pin-access/local-route repair rather than another generic ECO loop for the five `route_eco_offgrid1` residual M1 off-grid DRCs.
- Rationale: local probes showed the residuals were pin-access specific: `ZBUF_714_1050` and `ZBUF_851_152` could be fixed by narrow reroute, while the final `n143522` marker localized to `U77942/A1`/`A3`. Broad ECO had already stopped as not converging.
- Implementation decision: exclude `VDD` and `VSS` from `@swap_pin_nets` with `SEQ_SWAP_NET_EXCLUDE_REGEX=^(VDD|VSS)$`.
- Rationale: the target is signal route DRC. PG connectivity is a separate rail-connectivity problem, and touching PG nets during signal reroute would mix closure tracks.
- Decision: keep saved block `route_seq_size_swap_dff2_oa1_move_u77942_xp152_pintrack` as the current best signal-route candidate.
- Rationale: it applies two controlled cell size changes, moves `U77942` by `+0.152um` in X, and saved-block recheck reports `0` open signal nets and `0` route DRCs.
- Guardrail: do not promote this candidate to a complete clean backend baseline yet. PG connectivity remains open, hold remains negative, max transition/capacitance violations remain open, and antenna rules are still absent.

### PG Rail Connectivity Repair Disposition

- Decision: treat PG connectivity repair as a separate closure track from the already-clean signal route DRC candidate.
- Rationale: `pg_connectivity_detail` shows seven isolated one-wire/zero-via M1 rail subnetworks per supply, while the saved signal-route candidate rechecks with `0` open signal nets and `0` route DRCs.
- Decision: do not adopt direct M1-M2 VIA12 insertion as the PG repair method.
- Rationale: forced direct VIA12 repair creates `406` vias and clears PG connectivity, but creates `580` PG DRC errors between VIA1 and existing VIA2 cut stacks.
- Decision: continue with the M1-M7 ladder topology, but only save a repaired block after route DRC/open, PG connectivity, PG DRC, and legality all recheck clean.
- Rationale: ladder repair at `x=50.0` clears PG connectivity and PG DRC, but currently introduces `24` signal route DRCs on VSS-side locations. VSS-only `x=30.0` still introduces `20` signal route DRCs, so a clean VSS ladder coordinate remains open.

### PG Ladder Clean Candidate Disposition

- Decision: save `route_pg_ladder_vdd50_vss20_path507x55_h015` as the current route-plus-PG clean candidate.
- Implementation: use M1-M7 ladder vias with VDD rails at `x=50.0`, VSS rails at `x=20.0`, and a per-shape override for `PATH_11_507` at `x=55.0` with half-box `0.15`.
- Rationale: the saved-block recheck reports `0` open signal nets, `0` route DRCs, zero VDD/VSS floating wires/vias/std cells/terminals, no PG DRC error body, and `TOTAL 0 Violations` legality.
- Guardrail: do not promote this candidate to a complete backend baseline yet. Hold, max transition/capacitance, and antenna-rule coverage remain open and must be re-extracted or classified from the PG ladder saved block.

### Post-Route Extraction Disposition

- Decision: treat the `07_extract_sta_pg_ladder_vdd50_vss20_path507x55_h015` report set as the current evidence source for the route-plus-PG candidate.
- Rationale: extraction from `route_pg_ladder_vdd50_vss20_path507x55_h015` confirms route DRC/open `0/0`, PG connectivity clean, PG DRC clean, legality `0`, and setup met with slack `5.61 ns`.
- Decision: keep hold, electrical DRC, and antenna-rule coverage as open closure tracks.
- Rationale: post-route extraction reports hold WNS/TNS/violations `-0.10 ns / -322.90 ns / 26153`, max transition/capacitance violations `318 / 2009`, and no antenna rules defined.
- Classification: optional `report_analysis_coverage` failed and is not used as a pass/fail criterion for this ICC2 extraction checkpoint.

### Broad Post-Route route_opt Trial Disposition

- Decision: do not adopt `route_pg_ladder_route_opt1` as the backend baseline.
- Rationale: the broad `route_opt` trial reduced hold violations from WNS/TNS/violations `-0.10 ns / -322.90 ns / 26153` to `-0.02 ns / -0.38 ns / 293`, but it introduced `43` open signal nets, `26` route DRCs, and worsened electrical violations to `673` max transition and `2181` max capacitance.
- Decision: keep `route_pg_ladder_vdd50_vss20_path507x55_h015` as the active route-plus-PG clean candidate.
- Rationale: that block remains the last evidence-backed saved block with route DRC/open `0/0`, PG connectivity clean, PG DRC clean, legality clean, and setup met.
- Next action: use a narrower hold ECO strategy from the clean PG-ladder block with small margins and immediate route/PG/legality/electrical checks after each candidate.

### Open-Site Hold ECO Trial Disposition

- Decision: do not adopt `route_pg_ladder_hold_eco_open_site_m0` as the active backend baseline yet.
- Rationale: open-site hold ECO reduced hold WNS/TNS/violations from `-0.10 ns / -322.90 ns / 26153` to `-0.05 ns / -15.61 ns / 4472`, while preserving PG connectivity, PG DRC, legality, and setup, but it leaves `3` route DRCs and worsens electrical violations to `328` max transition and `2116` max capacitance.
- Decision: keep `route_pg_ladder_hold_eco_open_site_m0` as the best hold-improved near-route-clean candidate.
- Rationale: unlike the broad `route_opt` trial, this hold ECO keeps open signal nets at `0` and leaves only three route DRCs, so it is a better starting point for targeted residual route repair.
- Next action: localize and repair the three residual route DRCs in `route_pg_ladder_hold_eco_open_site_m0`; only promote this path after saved-block recheck returns route DRC/open `0/0`.

### Open-Site Hold ECO Residual Route Repair Disposition

- Decision: promote `route_pg_ladder_hold_eco_open_site_m0_route_repair1` to the current best route-plus-PG and hold-improved candidate.
- Rationale: targeted sequential local reroute repaired the three residual route DRCs from the open-site hold ECO block, saved a new block, and saved-block recheck reports route DRC/open `0/0`, PG floating counts `0`, PG DRC clean, `TOTAL 0 Violations` legality, and setup slack `5.61 ns`.
- Decision: keep `route_pg_ladder_vdd50_vss20_path507x55_h015` as the rollback clean route-plus-PG source.
- Rationale: it is the last pre-hold-ECO clean route-plus-PG checkpoint and is useful if further timing or electrical ECO degrades the repaired hold ECO candidate.
- Guardrail: do not call `route_pg_ladder_hold_eco_open_site_m0_route_repair1` a complete backend baseline yet.
- Rationale: hold remains open at WNS/TNS/violations `-0.05 ns / -15.61 ns / 4472`, electrical DRC remains open at max transition/capacitance `328 / 2116`, and antenna-rule coverage is still absent.

## 2026-05-12

### Repaired Hold2 Candidate Disposition

- Decision: keep `route_pg_ladder_hold_eco_open_site_m0_route_repair1_hold2_move_u2pteco95_r1_route_repair1` as the latest route-clean repaired hold2 candidate.
- Rationale: the second open-site hold ECO inserted `102` hold buffers but introduced one M1 off-grid route DRC on `ZBUF_899_1724`; moving adjacent hold buffer `U_2_PTECO_HOLD_BUF95` by `+0.152um` in X and rerouting local nets closed that route DRC. Saved-block recheck reports route DRC/open `0/0`, PG floating counts `0`, PG DRC clean, legality `TOTAL 0 Violations`, and setup slack `5.61 ns`.
- Guardrail: do not call this a complete backend baseline.
- Rationale: saved-block timing/electrical remain open with hold WNS/TNS/violations `-0.05 ns / -15.18 ns / 4390` and max transition/capacitance `328 / 2116`; antenna-rule coverage is still absent.

### Connect-within-pins Probe Disposition

- Decision: do not use `route.common.connect_within_pins_by_layer_name` as a repair option for this candidate.
- Rationale: mode-only values were invalid, and the accepted layer/mode form `M1 via_standard_cell_pins` changed the route DRC criteria, creating more than fifty thousand `Connection not within pin` violations. This is not compatible with preserving the existing route-clean baseline evidence.
- Next action: prefer local physical edits plus narrow reroute for isolated pin-access DRCs.

### Repeated Open-Site Hold ECO Disposition

- Decision: stop repeating identical `eco_opt -types hold -hold_margin 0.00 -physical_mode open_site` from the hold-improved candidates.
- Rationale: hold3 inserted only `2` additional hold buffers, PrimeTime still reported `543` remaining endpoints, and saved-block recheck remained unchanged at hold WNS/TNS/violations `-0.05 ns / -15.18 ns / 4390`. The dominant unfixable reason is `O` no open free site.
- Next action: change the hold/electrical strategy instead of rerunning the same open-site ECO. Candidate directions are whitespace/placement relief, a controlled non-open-site ECO mode, or a targeted electrical/hold repair with immediate route/PG/legal saved-block rechecks.

### Saved-Block Evidence Policy Reinforcement

- Decision: use reopened saved-block QoR as the evidence source for timing/electrical disposition after ECO.
- Rationale: both hold2 and hold3 immediate post-ECO reports showed much lower electrical counts than reopened saved-block QoR. Hold2 immediate electrical was `10 / 80` while saved-block recheck returned `328 / 2116`; hold3 immediate electrical was `0 / 3` while saved-block recheck again returned `328 / 2116`.
- Guardrail: do not claim electrical clean from immediate post-ECO reports unless a saved-block recheck confirms the same state.

### Occupied-Site Hold ECO Disposition

- Decision: keep `route_pg_ladder_hold_eco_repair1_hold2_clean_occ1` as the latest route/PG/legal clean hold-improved candidate.
- Rationale: `PHYSICAL_MODE=occupied_site` preserved route DRC/open `0/0`, PG floating counts `0`, PG DRC clean, legality `TOTAL 0 Violations`, and setup slack `5.61 ns` after saved-block recheck. It modestly improved saved-block hold to WNS/TNS/violations `-0.05 ns / -15.13 ns / 4370`.
- Guardrail: do not call this a complete backend baseline.
- Rationale: saved-block hold remains open, saved-block electrical remains `328 / 2116`, and antenna-rule coverage is still absent because route reports state no antenna rules are defined.
- Next action: stop for today after recording and pushing. The next technical step should not be another identical open-site run; evaluate high-density residual hold paths and electrical DRC strategy before further ECO.
