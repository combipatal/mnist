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

### Formality R2N Gate

- Decision: treat `3_Formality/0_Script/run_fm_r2n_topo.sh` PASS as the gate to proceed into ICC2 init_design.
- Rationale: the mapped topographical netlist is equivalent to the RTL reference with 39,681 passing compare points and zero failing/unverified compare points.

### Professional Project Discipline

- Decision: run project stages like a practical ASIC implementation flow.
- Rationale: every stage needs objective, pass/fail criteria, explicit script/log path, first-fatal debug, evidence recording, and risk classification before moving forward.

### ICC2 Init Warning Handling

- Decision: record ICC2 init as linked/saved with open warnings rather than call it clean.
- Rationale: the design imports and links, but async reset endpoints remain intentionally false-pathed and 16 no-driver mapped-netlist nets need classification before later closure.

### ICC2 Backend Constraint Source

- Decision: use the clean project SDC `1_Input/constraints/mnist_npu_10ns.sdc` for ICC2 bring-up instead of the DC-written mapped SDC.
- Rationale: ICC2 does not support the mapped SDC's many net `set_load` commands, while the clean project SDC preserves the baseline clock, IO delay, uncertainty, and reset false-path intent.

### Pre-Placement PG Connectivity Status

- Decision: record the first powerplan as generated but not PG-clean.
- Rationale: `compile_pg` and PG DRC pass, but `check_pg_connectivity` reports all standard cells floating before placement. PG connectivity must be rechecked after placement before claiming clean power connectivity.

### Placement Baseline Continuation

- Decision: keep the 55% utilization placement as the first baseline despite open PG connectivity and congestion.
- Rationale: placement and legalization completed with zero legality violations and PG DRC has no errors, but PG connectivity and global-route congestion are not clean. The first milestone is end-to-end flow establishment, so continue to CTS/route with these risks recorded rather than starting a utilization sweep prematurely.
