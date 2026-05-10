# Project Status

## Current Status

- Status: `A7_ROUTE_REPAIR_TRIAL_PARTIAL_ECO_OPEN_PG_HOLD_ELECTRICAL`
- Stage: A7 ICC2 route debug and backend repair trials
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

## Next Checkpoint

Proceed with two separate closure tracks:

1. For signal route DRC, prepare a lower-utilization or placement/congestion trial using the VIA1 no-track NDM. Generic route-only ECO reduced DRC to `55` but did not converge.
2. For PG connectivity, debug the seven isolated VDD and seven isolated VSS one-wire/zero-via subnetworks independently from signal route DRC.
3. Decide whether the next full backend trial changes utilization/floorplan, PG rail strategy, or both, but keep those variables separated.
4. Keep route open; do not claim DRC, PG, hold, antenna, or electrical clean until reports prove closure.

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
- libdir VIA1 no-track backend-route trial is the best current route-DRC candidate: DRC improved to `77`, with `0` open signal nets and no needs-fat-contact in the final route report.
- libdir VIA1 no-track trial is still not clean: residual DRC is dominated by `72` off-grid DRCs; PG connectivity, hold, antenna, and electrical closure remain open.
- Residual off-grid extraction shows `72` off-grid DRCs are signal-only; `69` are on M1 and `3` are on M2.
- Route-only ECO on the VIA1 no-track trial improved DRC from `77` to `55`, but did not converge to clean.
- PG connectivity detail shows seven isolated one-wire/zero-via subnetworks per supply net; this is not explained by the signal off-grid DRCs.
