# Project Status

## Current Status

- Status: `A4_POWERPLAN_DONE_WITH_OPEN_PG_CONNECTIVITY`
- Stage: A4 ICC2 init/floorplan/powerplan
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

## Next Checkpoint

Proceed to placement and re-check PG connectivity:

1. Create ICC2 placement script from the saved `powerplan` block.
2. Run initial placement/legalization.
3. Re-run timing, legality, and PG connectivity checks after cells are placed.
4. Decide whether the 55% floorplan is route-feasible or needs a lower utilization trial.

## Accepted First-Baseline Risks

- DC max capacitance violations: `17694`.
- DC max transition violations: `2518`.
- DC hold violations: worst about `-0.01 ns`, total `-1.06`, paths `221`.
- SAED32 `check_library` scan FF `test_cell` messages are recorded as DFT/library risk.
- SRAM macro replacement is disabled; memories are implemented as FF arrays for this first handoff.
- FM RTL interpretation array-bound/signedness warnings are accepted because R2N passed, but retained as an RTL-quality risk.
- ICC2 init currently carries reset-related timing warnings and 16 mapped-netlist no-driver warnings for classification before floorplan closure.
- PG connectivity is not clean before placement: both VDD and VSS report `175574` floating standard cells. Re-check after placement before calling PG clean.
