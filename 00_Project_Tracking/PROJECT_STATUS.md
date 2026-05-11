# Project Status

## Current Status

- Status: `A15_HOLD_ECO_ROUTE_REPAIRED_OPEN_HOLD_ELECTRICAL_ANTENNA`
- Stage: A15 open-site hold ECO residual route repair completed; current best candidate is route/PG/legal clean but hold, electrical, and antenna-rule coverage remain open
- Primary RTL cloned: yes
- Source revision frozen: yes
- Candidate top identified: `nn_top`
- Initial RTL filelist created: yes
- DC analyze/elaborate/link: passed
- DC topographical synthesis: passed for first baseline handoff
- Formality R2N: passed
- ICC2 SAED32 RVT NDM build: passed
- ICC2 init_design/link/save: passed with open warnings
- ICC2 floorplan: passed with open warnings
- ICC2 powerplan: generated; PG DRC clean, PG connectivity open before placement
- ICC2 placement/legalization: passed with open PG connectivity and congestion warnings
- ICC2 libdir/LEF/modify NDM trial: completed but not adopted
- ICC2 CTS/clock route: passed with open hold, PG connectivity, and electrical violations
- ICC2 route/report extraction: completed with open route DRC, PG connectivity, hold, and electrical violations
- ICC2 route DRC debug: completed; lower-metal/VIA1/contact-dominated DRC confirmed
- ICC2 route ECO DRC repair: completed but not adopted; DRC only improved from 738 to 709
- ICC2 libdir VIA1 no-track backend-route trial: completed; route DRC improved from 738 to 77 but still not clean
- ICC2 libdir VIA1 no-track residual DRC extraction: completed; residual off-grid is signal-only and mostly M1
- ICC2 libdir VIA1 no-track route-only ECO: completed; DRC improved from 77 to 55 but still not clean
- ICC2 libdir VIA1 no-track 45% utilization trial: completed; DRC improved to 59 but still not clean
- Sibling SAED32 backend closure references: reviewed; next controlled trial is VIA1 no-track plus trim_all_pin NDM
- ICC2 libdir VIA1 no-track trim_all_pin RVT NDM build: passed
- ICC2 libdir VIA1 no-track trim_all_pin 45% utilization rerun3: completed through route; route DRC improved to `6` off-grid violations with `0` open signal nets, but route is not clean
- ICC2 libdir VIA1 no-track trim_all_pin route-only ECO: completed; route DRC improved from `6` to `5`, but ECO did not converge to clean
- ICC2 targeted residual route repair: completed; saved block `route_seq_size_swap_dff2_oa1_move_u77942_xp152_pintrack` rechecks with `0` open signal nets and `0` route DRCs
- ICC2 PG rail connectivity debug: completed; root cause narrowed to seven isolated M1 rail subnetworks per supply with missing rail-to-mesh via connection
- ICC2 PG repair: completed for current candidate; saved block `route_pg_ladder_vdd50_vss20_path507x55_h015` rechecks with `0` open signal nets, `0` route DRCs, clean PG connectivity, clean PG DRC, and clean legality
- ICC2 post-route extraction from route-plus-PG candidate: completed; route DRC/open, PG, legality, and setup remain clean, but hold/electrical/antenna-rule coverage remain open
- ICC2 broad post-route `route_opt` trial: completed and saved `route_pg_ladder_route_opt1`, but not adopted because it introduced `43` open signal nets and `26` route DRCs
- ICC2 open-site hold ECO trial: completed and saved `route_pg_ladder_hold_eco_open_site_m0`; route DRC/open was `3/0`, so it was not adopted directly
- ICC2 open-site hold ECO residual route repair: completed and saved `route_pg_ladder_hold_eco_open_site_m0_route_repair1`; saved-block recheck reports route DRC/open `0/0`, clean PG connectivity/DRC, clean legality, and setup met, but hold/electrical/antenna-rule coverage remain open
- ICC2 second open-site hold ECO from the repaired candidate: completed and saved `route_pg_ladder_hold_eco_open_site_m0_route_repair1_hold2`; it inserted `102` hold buffers but left one M1 off-grid route DRC and saved-block hold/electrical still open
- ICC2 hold2 targeted cell-move route repair: completed and saved `route_pg_ladder_hold_eco_open_site_m0_route_repair1_hold2_move_u2pteco95_r1_route_repair1`; saved-block recheck reports route DRC/open `0/0`, clean PG connectivity/DRC, clean legality, and setup met, but hold/electrical remain open
- ICC2 third open-site hold ECO from the repaired hold2 candidate: completed and saved `route_pg_ladder_hold_eco_repair1_hold2_clean_hold3`; it inserted only `2` additional hold buffers and saved-block recheck shows no material hold/electrical improvement

## Next Checkpoint

Proceed from the route-clean repaired hold2/hold3 evidence and change strategy for hold/electrical closure:

1. Treat `route_pg_ladder_hold_eco_open_site_m0_route_repair1_hold2_move_u2pteco95_r1_route_repair1` and `route_pg_ladder_hold_eco_repair1_hold2_clean_hold3` as the latest route/PG/legal clean hold-improved candidates.
2. Use saved-block recheck evidence from `07_extract_sta_hold_eco_repair1_hold2_m0_move_u2pteco95_r1_route_repair1_saved_recheck` and `07_extract_sta_hold_eco_repair1_hold2_clean_hold3_m0_saved_recheck`: route DRC/open `0/0`, PG floating counts `0`, PG DRC clean, legality `0`, and setup slack `5.61 ns`.
3. Keep `route_pg_ladder_vdd50_vss20_path507x55_h015` as the rollback route-plus-PG clean source if further hold/electrical ECO degrades route or PG.
4. Keep `route_pg_ladder_route_opt1` as failed trial evidence only: hold improved to WNS `-0.02 ns`, TNS `-0.38 ns`, `293` violations, but route DRC/open became `26/43`.
5. Repeated `PHYSICAL_MODE=open_site` hold ECO is now saturated by available placement sites: hold3 inserted only `2` buffers and saved-block hold remains WNS/TNS/violations `-0.05 ns / -15.18 ns / 4390`.
6. Current saved-block electrical DRC remains open: `328` max transition violations and `2116` max capacitance violations across `2142` nets with violations.
7. Do not trust immediate post-ECO electrical reports when they disagree with saved-block rechecks; use reopened block QoR as the evidence source.
8. Do not claim antenna clean because the route checks report no antenna rules defined.
9. Do not promote the candidate to a complete baseline until hold, electrical reports, and antenna-rule coverage are resolved or explicitly classified.

## Accepted First-Baseline Risks

- DC max capacitance violations: `17694`.
- DC max transition violations: `2518`.
- DC hold violations: worst about `-0.01 ns`, total `-1.06`, paths `221`.
- SAED32 `check_library` scan FF `test_cell` messages are recorded as DFT/library risk.
- SRAM macro replacement is disabled; memories are implemented as FF arrays for this first handoff.
- FM RTL interpretation array-bound/signedness warnings are accepted because R2N passed, but retained as an RTL-quality risk.
- ICC2 init currently carries reset-related timing warnings and 16 mapped-netlist no-driver warnings for classification before floorplan closure.
- PG connectivity is still not clean after placement: VDD has `3985` floating standard cells and VSS has `3405` floating standard cells.
- Placement congestion is high at 55% utilization: phase1 global-route overflow `45036`, max overflow `5`, GRCs `36186 (4.20%)`.
- `libdir/LEF/modify` RVT NDM was tested and not adopted because PG connectivity and congestion did not improve.
- CTS inserted/routed the clock tree and final clock-route DRC is clean, but hold is still open: worst hold `-0.10 ns`, total hold `-237.12`, violations `23288`.
- CTS PG connectivity is still not clean: VDD has `4653` floating standard cells and VSS has `3963` floating standard cells.
- CTS electrical violations remain open: design max transition/max capacitance violations `187 / 1492`; clock-specific cap DRC count `7`.
- CTS log includes `POW-080` default-voltage warnings; route and future CTS scripts now set default top-level voltage to `1.05 V`.
- Route completed and saved `mnist_npu_icc2_lib:route.design`, but route DRC remains open: `738` total DRCs, `0` open signal nets, no antenna rules defined.
- Route legality is clean: `TOTAL 0 Violations`.
- Route PG DRC reports `No errors found`, but PG connectivity is still not clean: VDD has `4653` floating standard cells and VSS has `3963` floating standard cells.
- Route hold remains open: worst hold `-0.10 ns`, total hold `-288.96`, violations `25344`.
- Route electrical violations remain open: max transition/max capacitance violations `287 / 1958`.
- Route ECO DRC repair was tested and not adopted: DRC only improved from `738` to `709`.
- libdir VIA1 no-track backend-route trial reduced DRC to `77`, with `0` open signal nets and no needs-fat-contact in the final route report.
- libdir VIA1 no-track trial is still not clean: residual DRC is dominated by `72` off-grid DRCs; PG connectivity, hold, antenna, and electrical closure remain open.
- Residual off-grid extraction shows `72` off-grid DRCs are signal-only; `69` are on M1 and `3` are on M2.
- Route-only ECO on the VIA1 no-track trial improved DRC from `77` to `55`, but did not converge to clean.
- VIA1 no-track 45% utilization trial improved official route DRC to `59`, but did not converge to clean; final routed utilization was `0.5669`.
- Sibling CV32E40P evidence shows `trim_all_pin` NDM frame generation can strongly reduce comparable lower-metal residual DRC; sibling ibex evidence shows VIA1 no-track plus upstream cell-use policy can reach route DRC 0.
- trim_all_pin util45 rerun2 reached route and reported `6` route DRCs, but its saved route DB was later overwritten by a no-CCD diagnostic route; use rerun2 reports only as historical evidence.
- trim_all_pin util45 rerun3 completed through route and is the preserved best full-flow route-DRC candidate: `0` open signal nets, `6` route DRCs, all off-grid, and `TOTAL 0 Violations` legality.
- trim_all_pin util45 rerun3 is still not clean: PG connectivity remains open, hold remains significantly negative, max transition/cap remain open, and antenna is not proven because no antenna rules are defined.
- trim_all_pin util45 route-only ECO improved official DRC from `6` to `5`, but stopped as not converging; it is partial repair evidence only.
- targeted size-swap, `U77942` local move, and sequential signal reroute closed the residual route DRC/open checks in saved block `route_seq_size_swap_dff2_oa1_move_u77942_xp152_pintrack`.
- the saved targeted signal-route candidate is not a complete clean backend baseline by itself: PG connectivity was still open there, and hold, max transition/capacitance, and antenna-rule coverage remained open.
- PG connectivity detail shows seven isolated one-wire/zero-via subnetworks per supply net; this is not explained by the signal off-grid DRCs.
- Direct M1-M2 VIA12 PG repair is not acceptable: forced repair fixes connectivity but creates `580` PG DRC errors.
- Combined M1-M7 PG ladder repair is saved as `route_pg_ladder_vdd50_vss20_path507x55_h015`: saved-block recheck reports `0` open signal nets, `0` route DRCs, zero PG floating counts, no PG DRC error body, and `TOTAL 0 Violations` legality.
- post-route extraction from the saved route-plus-PG candidate confirms route DRC/open `0/0`, PG floating counts `0`, PG DRC clean, legality `0`, and setup met.
- the saved route-plus-PG candidate is not a complete backend baseline yet: hold WNS/TNS/violations are `-0.10 ns / -322.90 ns / 26153`, max transition/capacitance violations are `318 / 2009`, and antenna-rule coverage remains missing.
- broad post-route `route_opt` is not adopted: it reduced hold violations to WNS/TNS/violations `-0.02 ns / -0.38 ns / 293`, but introduced `43` open signal nets, `26` route DRCs, and worsened electrical violations to `673 / 2181`.
- open-site hold ECO direct output was not adopted: it reduced hold to WNS/TNS/violations `-0.05 ns / -15.61 ns / 4472` and kept PG/legality clean, but route DRC/open was `3/0`.
- targeted residual route repair from the open-site hold ECO output is now the current best candidate: saved-block recheck reports route DRC/open `0/0`, PG floating counts `0`, PG DRC clean, legality `0`, and setup slack `5.61 ns`; hold remains `-0.05 ns / -15.61 ns / 4472`, electrical remains `328 / 2116`, and antenna-rule coverage is absent.
- repaired hold2/hold3 candidates preserve route DRC/open `0/0`, PG floating counts `0`, PG DRC clean, legality `0`, and setup slack `5.61 ns`, but hold remains `-0.05 ns / -15.18 ns / 4390` and electrical remains `328 / 2116`.
- repeated open-site hold ECO is limited by no-open-site failures; hold3 inserted only `2` additional buffers and did not materially improve the saved-block timing/electrical state.
