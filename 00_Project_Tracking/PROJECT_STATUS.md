# Project Status

## Current Status

- Status: `DC_TOPO_SYNTH_DONE_WITH_ACCEPTED_RISKS`
- Stage: A2 topographical synthesis
- Primary RTL cloned: yes
- Source revision frozen: yes
- Candidate top identified: `nn_top`
- Initial RTL filelist created: yes
- DC analyze/elaborate/link: passed
- DC topographical synthesis: passed for first baseline handoff
- Formality R2N: not run yet

## Next Checkpoint

Run Formality R2N against the topographical synthesis handoff:

1. Create SAED32 setup Tcl.
2. Use RTL filelist as reference and mapped DDC/VG as implementation.
3. Load `2_Synthesis/2_Output/svf/nn_top.topo_10ns.mapped.svf`.
4. Run match/verify.
5. Record pass/fail, first non-equivalent point, and report paths.

## Accepted First-Baseline Risks

- DC max capacitance violations: `17694`.
- DC max transition violations: `2518`.
- DC hold violations: worst about `-0.01 ns`, total `-1.06`, paths `221`.
- SAED32 `check_library` scan FF `test_cell` messages are recorded as DFT/library risk.
- SRAM macro replacement is disabled; memories are implemented as FF arrays for this first handoff.
