# Backend Route DRC Debug Notes - 2026-05-10

## Objective

Classify the first route baseline DRC and test the most relevant SAED32 backend fixes from sibling projects without overwriting the fixed MNIST baseline.

## References Reviewed

The following sibling-project records use the same SAED32 library family and were used only as references:

- `/DATA/home/edu135/ibex/docs/backend_library_policy.md`
- `/DATA/home/edu135/ibex/docs/ibex_backend_route_closure_case_study.md`
- `/DATA/home/edu135/ibex/init/context_bootstrap.md`
- `/DATA/home/edu135/CV32E40P/docs/backend/libdir_modify_lef_trial_2026_05_09.md`
- `/DATA/home/edu135/CV32E40P/docs/backend/contact_code_diagnosis.md`
- `/DATA/home/edu135/CV32E40P/docs/backend/pin_access_track_probe.md`
- `/DATA/home/edu135/CV32E40P/docs/backend/scan_def_and_advanced_legalizer_trials.md`

Relevant reference conclusion:

- ibex closed route DRC with modified LEFs plus a patched VIA1 technology policy.
- CV32E40P showed that modified LEFs can remove needs-fat-contact DRCs but leave residual off-grid DRCs.
- Simple M1 retrack, generic route repair, and utilization-only changes were not reliable standalone fixes in the references.

## MNIST Baseline Route Problem

Baseline report:

- `4_Backend_ICC2/4_Report/06_route/check_routes.rpt`

Baseline result:

| Metric | Value |
| --- | --- |
| Open signal nets | `0` |
| Total route DRC | `738` |
| Diff-net spacing | `285` |
| Minimum-area | `4` |
| Needs-fat-contact | `183` |
| Off-grid | `240` |
| Short | `26` |

Debug matrix:

- `4_Backend_ICC2/4_Report/06_route/drc_debug/drc.matrix.rpt`

The matrix shows the DRCs are concentrated on M1, M2, VIA1, and M1-M2 contact classes. That matches the sibling-project root-cause family: SAED32 lower-metal pin access, VIA1 legality, and local routing-resource pressure.

## Trials

| Trial | Result | Interpretation |
| --- | --- | --- |
| `route_eco` on baseline route | DRC `738` to `709` | Not enough; generic ECO reroute is not the main fix. |
| libdir modified LEF placement-only trial | Placement congestion/PG did not improve | Not adopted as baseline replacement. |
| libdir modified LEF plus VIA1 pitch/no-track full backend trial | Final route DRC `77` | Best current route-DRC candidate, but still open. |
| Same VIA1 no-track setup with 45% floorplan target | Final route DRC `59` | Congestion relief helps, but lower utilization alone is not closure. |

## libdir VIA1 no-track Trial

Build command:

```text
4_Backend_ICC2/0_Script/00_setup/build_saed32_rvt_ndm_libdir_via1_no_track.sh
```

Backend trial command:

```text
4_Backend_ICC2/0_Script/99_util/run_libdir_via1_no_track_backend_flow.sh
```

Trial report:

- `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_route/06_route/check_routes.rpt`

Trial result:

| Metric | Value |
| --- | --- |
| Open signal nets | `0` |
| Total route DRC | `77` |
| Diff-net spacing | `3` |
| Minimum-area | `1` |
| Needs-fat-contact | `0` |
| Off-grid | `72` |
| Same-net spacing | `1` |
| Short | `0` |
| Legality | `TOTAL 0 Violations` |
| Setup | worst setup slack `5.60 ns`, setup violating paths `0` |
| Hold | worst `-0.10 ns`, total `-235.75`, hold violations `22731` |
| PG DRC | no errors in route log |

Open issues:

- Residual DRC is not clean; most remaining violations are off-grid.
- PG connectivity is still open: VDD has `4697` floating standard cells, VSS has `4151`.
- Hold and electrical checks remain open.
- Antenna is not proven clean because no antenna rules are defined.

## Current Conclusion

The sibling-project VIA1 no-track policy is materially relevant to MNIST. It removes the needs-fat-contact class and reduces route DRC from `738` to `77`, but it does not complete route closure.

## Residual Off-grid Classification

Debug command:

```text
4_Backend_ICC2/0_Script/06_route/debug_libdir_via1_no_track_route_residuals.sh
```

Debug artifacts:

- `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_route/06_route_debug/drc.errors.tsv`
- `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_route/06_route_debug/drc.offgrid.tsv`
- `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_route/06_route_debug/drc.matrix.rpt`
- `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_route/06_route_debug/pg_connectivity_detail.rpt`

Residual route DRC:

| Metric | Value |
| --- | --- |
| Total DRC | `77` |
| Off-grid | `72` |
| Off-grid by layer | `69` M1, `3` M2 |
| Off-grid PG-object references | `0` |
| Off-grid signal-only entries | `72` |
| Top repeated off-grid object | `n47593`, 3 entries |
| Largest 100um coordinate bucket | `500,700`, 12 entries |

The residual off-grid violations are signal-route objects, not PG wires. This separates signal route DRC from the PG connectivity issue.

## PG Connectivity Classification

The trial PG report still says VDD has `4697` floating standard cells and VSS has `4151`. The detail report shows the shape more clearly:

| Net | Disjoint networks | Main network std cells | Isolated subnetwork shape |
| --- | --- | --- | --- |
| VDD | `8` | `201997` | seven subnetworks, each `1` wire, `0` vias, `0` terminals |
| VSS | `8` | `202543` | seven subnetworks, each `1` wire, `0` vias, `0` terminals |

This is a PG rail/connectivity issue. It should be debugged independently from signal off-grid DRC.

## Route-only ECO Check

Command:

```text
4_Backend_ICC2/0_Script/06_route/run_libdir_via1_no_track_route_eco_offgrid1.sh
```

Result:

| Metric | Value |
| --- | --- |
| Pre-check DRC | `77` |
| Changed nets | `364` |
| Best intermediate DRC | `38`, then non-monotonic |
| Final post-check DRC | `55` |
| Final DRC classes | `2` diff-net spacing, `53` off-grid |
| Open signal nets | `0` |
| PG connectivity | unchanged |

Generic route-only ECO is useful but insufficient. It partially reduces residual signal DRC, but it does not converge to clean and does not address PG connectivity.

## 45% Utilization Trial

Command:

```text
4_Backend_ICC2/0_Script/99_util/run_libdir_via1_no_track_util45_backend_flow.sh
```

Result:

| Metric | Value |
| --- | --- |
| Open signal nets | `0` |
| Official route DRC | `59` |
| DRC classes | `1` diff-net spacing, `57` off-grid, `1` short |
| Final utilization | `0.5669` |
| Legality | `TOTAL 0 Violations` |
| PG connectivity | VDD `4447` floating std cells, VSS `4002` floating std cells |
| Setup | worst setup slack `5.60 ns` |
| Electrical | `307` max transition, `2018` max capacitance violations |

This is an improvement from `77` to `59`, but it does not close the route. The final utilization also rises well above the 45% floorplan target, so the result should be interpreted as partial congestion relief rather than a root-cause fix.

## Sibling-project Closure Clues

ibex and CV32E40P point to the same SAED32 lower-metal physical-library family:

- ibex reached a debug route-clean candidate with modified LEFs, VIA1 pitch/no-track techfile policy, and upstream cell-use policy.
- CV32E40P showed that allowing M9 did not address the lower-metal root cause and worsened one trial.
- CV32E40P reduced a comparable route candidate from `67` DRC to `1` DRC by rebuilding NDMs with `configure_frame_options -mode keep_obs_and_trim_all_pin`.

MNIST currently has no `MUX41X2_RVT` in the mapped netlist. It does have `39` `MUX41X1_RVT`, `74` `NOR2X0_RVT`, and `1` `NOR2X2_RVT`. Therefore, the next narrower experiment is NDM frame trimming before a broader DC cell-use rerun.

Next controlled step:

1. Build `libdir_via1_no_track_trim_all_pin` RVT NDM.
2. Run the same 45% backend route trial with that NDM for signal DRC.
3. Debug PG rail generation/connection separately, focusing on the seven isolated VDD and VSS one-wire subnetworks.
4. If residual off-grid remains, consider a DC cell-use policy rerun based on the ibex closure notes.

## trim_all_pin Trial Start

NDM build:

```text
4_Backend_ICC2/0_Script/00_setup/build_saed32_rvt_ndm_libdir_via1_no_track_trim_all_pin.sh
```

Result:

| Metric | Value |
| --- | --- |
| NDM build | PASS |
| Key option | `configure_frame_options -mode keep_obs_and_trim_all_pin` |
| Workspace check | `Workspace check succeeded!` |
| Output NDM | `4_Backend_ICC2/2_Output/00_setup/ndm_libdir_via1_no_track_trim_all_pin/saed32rvt_tt.ndm` |

Backend trial:

```text
4_Backend_ICC2/0_Script/99_util/run_libdir_via1_no_track_trim_all_pin_util45_backend_flow.sh
```

Result so far:

| Metric | Value |
| --- | --- |
| Status | Stopped by user during CTS/clock-opt |
| Route result | Not available |
| Saved blocks | `nn_top`, `floorplan`, `powerplan`, `placement` |
| Placement legality | `TOTAL 0 Violations` |
| Placement utilization | `0.4503` |
| Placement setup | critical slacks `7.39`, `7.92`, `4.89` |
| Placement PG connectivity | VDD `3885` floating std cells, VSS `3308` floating std cells |
| CTS partial evidence | clock tree compilation reached success, but final CTS save/report set was not produced |

This trial cannot be judged for route DRC yet. The next session should confirm no ICC2 process is alive, clean or recreate the stopped trial library because `lib.ndm.master_lock` remains, then rerun CTS/route or rerun the full wrapper for reproducibility.
