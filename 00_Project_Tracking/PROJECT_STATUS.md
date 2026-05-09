# Project Status

## Current Status

- Status: `FM_R2N_PASS`
- Stage: A3 Formality R2N
- Primary RTL cloned: yes
- Source revision frozen: yes
- Candidate top identified: `nn_top`
- Initial RTL filelist created: yes
- DC analyze/elaborate/link: passed
- DC topographical synthesis: passed for first baseline handoff
- Formality R2N: passed

## Next Checkpoint

Run ICC2 init_design against the Formality-verified topographical synthesis handoff:

1. Create ICC2 technology/library setup for SAED32 RVT.
2. Import `2_Synthesis/2_Output/topo_10ns/nn_top.topo_10ns.mapped.vg`.
3. Read `2_Synthesis/2_Output/topo_10ns/nn_top.topo_10ns.mapped.sdc`.
4. Link and run `check_design`/library sanity checks.
5. Save the initialized design and record report paths.

## Accepted First-Baseline Risks

- DC max capacitance violations: `17694`.
- DC max transition violations: `2518`.
- DC hold violations: worst about `-0.01 ns`, total `-1.06`, paths `221`.
- SAED32 `check_library` scan FF `test_cell` messages are recorded as DFT/library risk.
- SRAM macro replacement is disabled; memories are implemented as FF arrays for this first handoff.
- FM RTL interpretation array-bound/signedness warnings are accepted because R2N passed, but retained as an RTL-quality risk.
