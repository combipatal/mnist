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

Next controlled step:

1. Classify the `77` residual DRCs in the trial route, especially off-grid objects and coordinates.
2. Debug PG connectivity separately from signal route DRC.
3. If residual off-grid is not a route-only repair, run a lower-utilization backend trial with the VIA1 no-track NDM.
4. If cell pin access remains the blocker, consider a DC cell-use policy rerun based on the ibex closure notes.
