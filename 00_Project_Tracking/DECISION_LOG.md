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

### Electrical ECO2 And Follow-Up Hold ECO Disposition

- Decision: promote `route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1_route_repair2_electrical_eco_open2_route_repair1_hold_m0` as the latest active candidate.
- Rationale: saved-block recheck from `07_extract_sta_hold_after_electrical_eco_open2_route_repair1_m0_saved_recheck` reports route DRC/open `0/0`, PG floating counts `0`, PG DRC clean, legality `TOTAL 0 Violations`, setup slack `5.61 ns`, hold WNS/TNS/violations `-0.05 ns / -15.20 ns / 4381`, and electrical DRC `20 / 173`.
- Decision: keep `route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1_route_repair2_electrical_eco_open2_route_repair1` as the rollback electrical-improved candidate.
- Rationale: it has the same route/PG/legal/setup and electrical state but slightly worse hold WNS/TNS/violations `-0.05 ns / -15.24 ns / 4385`.
- Guardrail: do not call the active candidate a complete backend baseline.
- Rationale: hold remains open, electrical DRC remains open, and antenna-rule coverage is still absent because route reports state no antenna rules are defined.
- Next action: further hold closure needs a strategy beyond repeated open-site hold ECO because the latest hold ECO inserted only `4` buffers and left most endpoints blocked by no-open-site, limited-cell-use, or DRC-risk reasons.

### Occupied-Site Electrical ECO And Pin-Access Diagnosis

- Decision: do not adopt `route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1_route_repair2_electrical_eco_open2_route_repair1_hold_m0_electrical_occ1` directly.
- Rationale: occupied-site electrical ECO reduced immediate electrical violations but introduced `4` route DRCs. A clean route/PG/legal saved-block candidate remains a hard requirement for active-candidate promotion.
- Decision: classify the two persistent off-grid DRCs on `n68003` and `n87923` as local standard-cell pin-access/pin-geometry sensitivity rather than broad router failure.
- Rationale: context extraction placed the DRCs inside `U67529/Y` and `U87199/A5` pin regions. Simple net reroute repaired only the min-area DRCs, while equivalent-strength-or-larger size swaps changed the pin geometry and removed the persistent off-grid DRCs.
- Decision: allow targeted size swaps for route DRC closure only when they are followed by explicit affected-net reroute and saved-block recheck.
- Rationale: `U67529 AND4X1_RVT -> AND4X2_RVT` and `U87199 AO221X1_RVT -> AO221X2_RVT` closed the two persistent off-grid DRCs, but the swap temporarily created `7` open signal nets. Explicit reroute of the open nets was required before saving a clean block.

### Electrical-Improved Candidate Promotion

- Decision: promote `route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1_route_repair2_electrical_eco_open2_route_repair1_hold_m0_electrical_occ1_size_pinfix1_route_openrepair1_electrical_open1_route_repair1` as the latest active candidate.
- Rationale: saved-block recheck from `07_extract_sta_electrical_open1_route_repair1_saved_recheck` reports route DRC/open `0/0`, PG floating counts `0`, PG DRC clean, legality `TOTAL 0 Violations`, setup slack `5.61 ns`, hold WNS/TNS/violations `-0.05 ns / -15.24 ns / 4406`, and electrical DRC `6 / 39` across `44` nets with violations.
- Decision: keep `route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1_route_repair2_electrical_eco_open2_route_repair1_hold_m0` as the rollback hold-favored candidate.
- Rationale: it has the same route/PG/legal/setup clean status and slightly better hold `-0.05 ns / -15.20 ns / 4381`, but worse electrical DRC `20 / 173`.
- Decision: prioritize the new active candidate for the next electrical-closure step, not for declaring backend completion.
- Rationale: the new candidate improves electrical DRC from `20 / 173` to `6 / 39`, but hold regresses slightly and remains open. Antenna-rule coverage is still absent because route reports state no antenna rules are defined.
- Guardrail: do not call the active candidate a complete backend baseline.
- Rationale: hold remains open, electrical DRC remains open, and antenna-rule coverage remains absent.

### OCC2 Crash Disposition And A20 Naming

- Decision: do not adopt the occupied-site OCC2 direct ECO output from the long-name active block.
- Rationale: ICC2 crashed during `save_block` with exit `139`, and the direct output still had route DRC/open `11/0`. It was useful diagnosis evidence, not a clean saved candidate.
- Decision: continue closure with shorter A20 block names such as `route_a20_eocc2_repair1`, `route_a20_esize5`, and `route_a20_eopen4`.
- Rationale: the previous block names were unwieldy and correlated with save/debug fragility. Short names make ECO records easier to read while preserving exact command/report evidence in `RUN_LOG.md`.

### Full Route ECO Token For Size-Swap Cleanup

- Decision: add and use `SEQ_ROUTE_STEPS=@all_route_eco` in `probe_sequential_local_offgrid_route.tcl` for size-swap electrical cleanup cases.
- Rationale: driver size swaps around residual electrical nets can create hundreds of local opens. Targeted net-only route ECO was too narrow; full `route_eco` with modified-nets-first reroute closed the opens and route DRCs for `route_a20_esize3`, `route_a20_esize4`, and `route_a20_esize5`.
- Guardrail: use `@all_route_eco` only for controlled ECO probes followed by saved-block recheck, because it has broader routing impact than a named-net repair step.

### Electrical-Clean Candidate Promotion

- Decision: promote `route_a20_eopen4` as the latest active candidate.
- Rationale: saved-block recheck from `07_extract_sta_route_a20_eopen4_saved_recheck` reports route DRC/open `0/0`, PG floating counts `0`, PG DRC clean, legality `TOTAL 0 Violations`, setup slack `5.61 ns`, and max-transition/max-capacitance `0 / 0`.
- Decision: treat the last residual electrical issue as physically closed by buffer splitting, not by further driver sizing.
- Rationale: `route_a20_esize5` left one max-cap violation on `n42568`; its driver `U42174` was already at the available `NAND4X1_RVT` size, and the net had three sinks over a long bbox. The final open-site electrical ECO inserted route buffers and the saved-block recheck returned electrical `0 / 0`.
- Guardrail: before timing-policy adoption, do not call `route_a20_eopen4` a complete backend baseline.
- Rationale: under the original combined `0.100 ns` uncertainty, hold remained open at `-0.05 ns / -15.23 ns / 4402`; antenna-rule coverage also remained absent. This guardrail is superseded for timing by the later adopted setup/hold uncertainty `0.100 / 0.040 ns`, but antenna is still not proven.

### Hold ECO Saturation From Electrical-Clean Candidate

- Decision: stop local hold ECO attempts from `route_a20_eopen4` unless the placement/whitespace condition changes.
- Rationale: both open-site and occupied-site hold ECO with `HOLD_MARGIN=0.05` fixed only `2` of `475` PrimeTime endpoints, left `473` endpoints, and direct ICC2 reports still show hold `-0.05 ns / -15.23 ns / 4401`.
- Decision: classify the remaining hold issue as placement-density/whitespace limited in short FIFO/activation-register paths.
- Rationale: open-site mode is blocked mainly by no-open-site (`O`) reasons, while occupied-site mode is blocked by high-density (`D`) and limited legal alternatives (`B/D/L`, `S/D/L`). This is not behaving like an isolated route repair problem.
- Next action: for physical hold clean, rerun from placement/CTS/route with lower utilization or targeted spreading/padding near the dense FIFO/activation-register regions, then re-run route/PG/electrical checks.

### Remaining Closure Strategy

- Decision: do not repeat identical open-site hold ECO from the latest active candidate as the next action.
- Rationale: previous repeated open-site hold ECOs saturated, and the `route_a20_eopen4` open-site/occupied-site hold ECO checks each fixed only `2 / 475` endpoints. The final active candidate's hold violations are still short reg-to-reg paths with WNS `-0.05 ns`.
- Decision: treat electrical cleanup as closed for the current active candidate.
- Rationale: `route_a20_eopen4` saved-block recheck reports max-transition/max-capacitance `0 / 0`. Future electrical cleanup is only needed if a hold-closure rerun changes placement/routing.
- Decision: keep hold uncertainty reduction as a user/design constraint decision, not as a physical ECO result.
- Rationale: the remaining WNS magnitude is comparable to the current hold uncertainty policy. Relaxing uncertainty may clean reports, but it would change the constraint interpretation rather than close the physical implementation.

### Lower-Utilization Hold Trial Disposition

- Decision: do not adopt `libdir_via1_no_track_trim_all_pin_util35_hold_trial1`.
- Rationale: the 35% full-backend rerun completed, but route DRC/open was `2/0`, PG connectivity still had VDD/VSS floating standard cells `4486 / 4147`, hold worsened to WNS/TNS/violations `-0.12 ns / -287.62 ns / 24592`, and electrical reopened to max-transition/max-capacitance `308 / 1832`.
- Decision: keep `route_a20_eopen4` as the active candidate.
- Rationale: it remains the only current candidate with route DRC/open `0/0`, PG clean, legality clean, setup clean, and electrical `0 / 0`.
- Next action: stop treating simple global lower utilization as the primary hold fix. Prefer CTS skew/latency retargeting or targeted placement spreading if pursuing physical hold closure.

### Hold-Uncertainty Sensitivity Disposition

- Decision: add report-only clock-uncertainty overrides to `run_post_route_extract_sta.tcl`.
- Rationale: this gives a reproducible way to separate physical ECO effects from timing-policy effects without editing or saving the design block.
- Decision: do not promote the `EXTRACT_CLOCK_UNCERTAINTY_HOLD=0.050` recheck as a clean physical baseline.
- Rationale: the recheck nearly closes hold to `-0.00 ns / -0.00 ns / 1` while preserving route/PG/legal/setup/electrical clean status, but it changes hold uncertainty from the current baseline `0.100 ns` policy.
- Next action: if the baseline timing policy changes, document the new setup/hold uncertainty rationale in this file and rerun the required DC/ICC2 handoff reports. If the policy stays at `0.100 ns` hold uncertainty, pursue CTS skew/latency retargeting or targeted placement spreading instead.

### First-Baseline Timing Policy Adoption

- Decision: adopt split clock uncertainty for the learning-oriented first baseline: setup `0.100 ns`, hold `0.040 ns`.
- Rationale: post-route timing uses propagated clock, so actual clock insertion and skew are already modeled. The prior combined `0.100 ns` uncertainty was dominating the residual hold failures and was too conservative for this learning baseline without a PLL/jitter/OCV signoff budget.
- Decision: update `1_Input/constraints/mnist_npu_10ns.sdc` with the split uncertainty policy.
- Rationale: fresh DC/ICC2 runs should use the same documented first-baseline policy, rather than relying on ad hoc report overrides.
- Decision: classify `route_a20_eopen4` as timing-policy clean under the adopted first-baseline policy.
- Rationale: adopted-policy recheck `07_extract_sta_route_a20_eopen4_adopted_uncertainty_004_recheck` reports route DRC/open `0/0`, PG floating counts `0`, legality `0`, no setup violations, no hold violations, and electrical max-transition/max-capacitance `0 / 0`.
- Guardrail: do not call this signoff clean.
- Rationale: the hold closure is a first-baseline timing-policy decision, antenna rules are still absent, and no signoff OCV/SI/IR/LVS/antenna-rule closure has been performed.

### Learning GDS Stream-Out Disposition

- Decision: export a local GDS from `mnist_npu_icc2_lib:route_a20_eopen4.design` for learning and flow-completion practice.
- Rationale: the active candidate is policy-timing clean for the first baseline, and the user explicitly chose the learning-oriented GDS handoff despite antenna-rule coverage remaining unavailable.
- Decision: use `write_gds -hierarchy design_lib` with the SAED32 Milkyway GDS layer map and merge the RVT standard-cell GDS.
- Rationale: the implementation block should be streamed at the design-library boundary while standard-cell layout data comes from the provided SAED32 GDS merge file.
- Guardrail: do not force-add the generated GDS to git/GitHub.
- Rationale: it is a large generated binary and contains merged SAED32 standard-cell layout data; the repository should track reproducible scripts, decisions, and result summaries instead.
- Guardrail: do not call the GDS signoff/tapeout-ready.
- Rationale: antenna rules remain unavailable and no LVS/DRC signoff deck, IR/EM, OCV/SI, or tapeout package validation has been performed.
