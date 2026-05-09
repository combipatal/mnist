# Project Status

## Current Status

- Status: `ICC2_INIT_PASS_WITH_OPEN_WARNINGS`
- Stage: A4 ICC2 init_design
- Primary RTL cloned: yes
- Source revision frozen: yes
- Candidate top identified: `nn_top`
- Initial RTL filelist created: yes
- DC analyze/elaborate/link: passed
- DC topographical synthesis: passed for first baseline handoff
- Formality R2N: passed
- ICC2 SAED32 RVT NDM build: passed
- ICC2 init_design/link/save: passed with open warnings

## Next Checkpoint

Clean up ICC2 init constraints and proceed to floorplan:

1. Replace or filter the DC-written SDC for ICC2 so unsupported net `set_load` constraints do not flood logs.
2. Classify the 16 no-driver structural nets from `check_design`.
3. Keep async reset false-path handling explicit and record reset-related timing warnings.
4. Create floorplan script with 55% utilization and 1:1 aspect ratio.
5. Save floorplan block and collect utilization/floorplan reports.

## Accepted First-Baseline Risks

- DC max capacitance violations: `17694`.
- DC max transition violations: `2518`.
- DC hold violations: worst about `-0.01 ns`, total `-1.06`, paths `221`.
- SAED32 `check_library` scan FF `test_cell` messages are recorded as DFT/library risk.
- SRAM macro replacement is disabled; memories are implemented as FF arrays for this first handoff.
- FM RTL interpretation array-bound/signedness warnings are accepted because R2N passed, but retained as an RTL-quality risk.
- ICC2 init currently carries reset-related timing warnings and 16 mapped-netlist no-driver warnings for classification before floorplan closure.
