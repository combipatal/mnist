# Project Status

## Current Status

- Status: `LEARNING_GDS_EXPORTED_ANTENNA_NOT_PROVEN`
- Stage: A20 electrical cleanup completed and saved as `route_a20_eopen4`; adopted first-baseline propagated-clock timing policy is setup uncertainty `0.100 ns` and hold uncertainty `0.040 ns`. Under this learning baseline policy, route/PG/legal/setup/hold/electrical are clean, and a local learning GDS was exported. Antenna-rule coverage remains open.
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
- ICC2 occupied-site hold ECO from the repaired hold2 candidate: completed and saved `route_pg_ladder_hold_eco_repair1_hold2_clean_occ1`; it added `2` buffers and `63` sizing edits, preserved route/PG/legality after saved-block recheck, and modestly improved saved-block hold TNS/violations to `-15.13 ns / 4370`
- ICC2 route_opt from occupied-site clean candidate: completed and saved `route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_route_opt1`, but not adopted because route DRC/open regressed to `19/41` even though hold improved to `-0.03 ns / -12.17 ns / 2965`
- ICC2 route repair attempts on the occupied-site route_opt block: completed; best repair reduced route DRC/open to `1/0` but did not save because the residual DRC remained between `ZBUF_753_1116` and `VSS`
- ICC2 post-route electrical ECO from the occupied-site clean candidate: completed and saved `route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1`; electrical improved but route DRC/open became `1/1`
- ICC2 electrical ECO route repair: completed and saved `route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1_route_repair2`; saved-block recheck reports route DRC/open `0/0`, PG floating counts `0`, PG DRC clean, legality `0`, setup slack `5.61 ns`, hold `-0.05 ns / -15.24 ns / 4385`, and electrical `29 / 271`
- ICC2 second post-route electrical ECO from the route-repaired electrical candidate: completed and saved `route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1_route_repair2_electrical_eco_open2`; electrical improved but route DRC/open became `19/0`
- ICC2 second electrical ECO route repair: completed and saved `route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1_route_repair2_electrical_eco_open2_route_repair1`; saved-block recheck reports route DRC/open `0/0`, PG floating counts `0`, PG DRC clean, legality `0`, setup slack `5.61 ns`, hold `-0.05 ns / -15.24 ns / 4385`, and electrical `20 / 173`
- ICC2 follow-up hold ECO from the second electrical ECO repair candidate: completed and saved `route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1_route_repair2_electrical_eco_open2_route_repair1_hold_m0`; saved-block recheck reports route DRC/open `0/0`, PG floating counts `0`, PG DRC clean, legality `0`, setup slack `5.61 ns`, hold `-0.05 ns / -15.20 ns / 4381`, and electrical `20 / 173`
- ICC2 occupied-site electrical ECO from the A19 active candidate: completed but not adopted directly; it reduced immediate electrical counts but introduced `4` route DRCs, used as evidence for pin-access/off-grid root-cause analysis
- ICC2 pin-access size-swap route repair: completed and saved `route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1_route_repair2_electrical_eco_open2_route_repair1_hold_m0_electrical_occ1_size_pinfix1_route_openrepair1`; saved-block recheck reports route DRC/open `0/0`, PG clean, legality `0`, setup slack `5.61 ns`, hold `-0.05 ns / -15.11 ns / 4381`, and electrical `11 / 63`
- ICC2 open-site electrical ECO from the size-pinfix candidate: completed and saved `route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1_route_repair2_electrical_eco_open2_route_repair1_hold_m0_electrical_occ1_size_pinfix1_route_openrepair1_electrical_open1`; electrical improved but one M1 off-grid DRC remained on `n137157`
- ICC2 final electrical-open1 route repair: completed and saved `route_pg_ladder_hold_eco_repair1_hold2_clean_occ1_electrical_eco_open1_route_repair2_electrical_eco_open2_route_repair1_hold_m0_electrical_occ1_size_pinfix1_route_openrepair1_electrical_open1_route_repair1`; saved-block recheck reports route DRC/open `0/0`, PG floating counts `0`, PG DRC clean, legality `0`, setup slack `5.61 ns`, hold `-0.05 ns / -15.24 ns / 4406`, and electrical `6 / 39`
- ICC2 OCC2 occupied-site electrical ECO from the long-name active block: completed reports but crashed on `save_block`; not adopted because direct output had route DRC/open `11/0` and tool exit `139`
- ICC2 OCC2 route repair and shortened A20 branch: completed and saved `route_a20_eocc2_repair1`; saved-block recheck reports route DRC/open `0/0`, PG clean, legality `0`, setup met, hold `-0.05 ns / -15.23 ns / 4403`, and electrical `8 / 19`
- ICC2 A20 open-site and occupied-site electrical ECO loop: completed through `route_a20_eopen3` and `route_a20_eocc3`; route/PG/legal/setup stayed clean, electrical reduced but remained open
- ICC2 A20 size-up plus full route ECO repairs: completed and saved `route_a20_esize3`, `route_a20_esize4`, and `route_a20_esize5`; final saved-block electrical reduced to one max-cap violation on `n42568`
- ICC2 A20 final open-site electrical ECO: completed and saved `route_a20_eopen4`; saved-block recheck reports route DRC/open `0/0`, PG floating counts `0`, PG DRC clean, legality `0`, setup slack `5.61 ns`, hold `-0.05 ns / -15.23 ns / 4402`, and electrical `0 / 0`
- ICC2 A20 hold ECO trials from `route_a20_eopen4`: open-site and occupied-site `HOLD_MARGIN=0.05` both completed but are not adopted; each fixed only `2 / 475` PT endpoints and left direct ICC2 hold at `-0.05 ns / -15.23 ns / 4401`
- ICC2 35% utilization full-backend hold trial completed but is not adopted; route DRC/open was `2/0`, PG connectivity still had VDD/VSS floating std cells `4486 / 4147`, hold worsened to `-0.12 ns / -287.62 ns / 24592`, and electrical reopened to `308 / 1832`
- ICC2 A20 report-only hold-uncertainty sensitivity recheck completed; with setup uncertainty `0.100 ns` and hold uncertainty `0.050 ns`, route/PG/legal/setup/electrical remain clean and hold nearly closes to `-0.00 ns / -0.00 ns / 1`
- Adopted first-baseline SDC policy: `set_clock_uncertainty -setup 0.100` and `set_clock_uncertainty -hold 0.040`
- ICC2 A20 adopted-policy recheck completed at `07_extract_sta_route_a20_eopen4_adopted_uncertainty_004_recheck`; route DRC/open `0/0`, PG floating counts `0`, legality `0`, setup clean, hold clean, and electrical `0 / 0`
- ICC2 learning GDS stream-out completed from `route_a20_eopen4`; local GDS file is `4_Backend_ICC2/2_Output/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/08_gds_learning_route_a20_eopen4/nn_top.route_a20_eopen4.learning.gds` with size `263520256` bytes. The generated GDS remains ignored by git because it is a large generated binary containing merged SAED32 standard-cell layout data.

## Next Checkpoint

The learning baseline is archived locally and the repository records the reproducible scripts and summary evidence:

1. Treat `route_a20_eopen4` as the latest active candidate.
2. Use adopted-policy recheck evidence from `07_extract_sta_route_a20_eopen4_adopted_uncertainty_004_recheck`: route DRC/open `0/0`, PG floating counts `0`, PG DRC clean, legality `0`, setup slack `5.61 ns`, hold `0 / 0 / 0`, and electrical `0 / 0`.
3. Keep the previous long-name electrical-open1 route-repair candidate as rollback only; it is route/PG/legal/setup clean but electrical is still `6 / 39`.
4. Keep `route_a20_esize5` as the rollback point immediately before final electrical buffer insertion; it has one residual max-cap violation on `n42568`.
5. Do not continue repeating local hold ECO on `route_a20_eopen4`; both `open_site` and `occupied_site` with `HOLD_MARGIN=0.05` fixed only `2 / 475` endpoints.
6. Record hold as `POLICY_CLEAN` for this learning baseline, not signoff clean.
7. Do not use the completed 35% global-utilization rerun as the next active branch; it worsened hold and reopened route/PG/electrical cleanup.
8. If a signoff-style closure exercise is required later, restore/raise hold margin and pursue CTS skew/latency retargeting or targeted placement spreading.
9. The existing saved block was rechecked with adopted uncertainty overrides; future fresh ICC2 init/full-flow runs will read the updated project SDC.
10. Do not claim antenna clean because the route checks report no antenna rules defined.
11. Do not call the run signoff clean or antenna clean until antenna-rule coverage is supplied or explicitly waived.
12. Do not force-add the generated GDS to git/GitHub; keep the local artifact path recorded and regenerate it from the committed `08_gds` script when needed.

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
- occupied-site hold ECO from the repaired hold2 candidate preserves route DRC/open `0/0`, PG floating counts `0`, PG DRC clean, legality `0`, and setup slack `5.61 ns`; saved-block hold improves only slightly to `-0.05 ns / -15.13 ns / 4370`, while electrical remains `328 / 2116`.
- route_opt from the occupied-site clean candidate is not adopted: hold improves to `-0.03 ns / -12.17 ns / 2965`, but saved-block route DRC/open is `19/41`, electrical remains open at `608 / 1923`, and local repair attempts do not reach a clean saved block.
- electrical ECO plus targeted route repair was an earlier active candidate: saved-block route DRC/open is `0/0`, PG floating counts are `0`, PG DRC and legality are clean, setup slack is `5.61 ns`, electrical improves to `29 / 271`, but hold remains open at `-0.05 ns / -15.24 ns / 4385` and antenna-rule coverage is still absent.
- second electrical ECO plus targeted route repair further improves saved-block electrical to `20 / 173` while preserving route DRC/open `0/0`, PG clean, legality clean, and setup slack `5.61 ns`.
- follow-up hold ECO after the second electrical repair was an earlier active candidate: saved-block route DRC/open is `0/0`, PG floating counts are `0`, PG DRC and legality are clean, setup slack is `5.61 ns`, hold slightly improves to `-0.05 ns / -15.20 ns / 4381`, electrical remains `20 / 173`, and antenna-rule coverage is still absent.
- occupied-site electrical ECO from the A19 active candidate was not adopted directly because it introduced `4` route DRCs, but it exposed the residual off-grid issue as local standard-cell pin-access/pin-geometry sensitivity.
- size-swap pinfix plus explicit open-net reroute is accepted as a targeted physical repair method for the current branch: `U67529 AND4X1_RVT -> AND4X2_RVT` and `U87199 AO221X1_RVT -> AO221X2_RVT` closed the persistent off-grid DRCs after rerouting affected nets.
- open-site electrical ECO from the size-pinfix candidate plus final `n137157` route repair was the previous active candidate: saved-block route DRC/open is `0/0`, PG floating counts are `0`, PG DRC and legality are clean, setup slack is `5.61 ns`, electrical improves to `6 / 39`, but hold remains open at `-0.05 ns / -15.24 ns / 4406` and antenna-rule coverage is still absent.
- A20 electrical cleanup through `route_a20_eopen4` closes saved-block max-transition/max-capacitance to `0 / 0` while preserving route DRC/open `0/0`, PG clean, legality clean, and setup slack `5.61 ns`.
- `route_a20_eopen4` becomes timing-policy clean under the adopted setup/hold uncertainty `0.100 / 0.040 ns`; antenna-rule coverage is still absent.
- Local hold ECO from `route_a20_eopen4` is saturated: both open-site and occupied-site `HOLD_MARGIN=0.05` runs fixed only `2 / 475` endpoints and left hold essentially unchanged.
