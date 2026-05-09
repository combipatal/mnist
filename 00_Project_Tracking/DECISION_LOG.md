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

### Professional Project Discipline

- Decision: run project stages like a practical ASIC implementation flow.
- Rationale: every stage needs objective, pass/fail criteria, explicit script/log path, first-fatal debug, evidence recording, and risk classification before moving forward.
