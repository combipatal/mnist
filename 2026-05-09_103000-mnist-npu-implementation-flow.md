# MNIST_NPU_IMPLEMENTATION_FLOW — Project Plan

- 작성 시각: 2026-05-09 10:30 UTC
- 프로젝트 성격: Open-source RTL 기반 FE-to-BE implementation flow 구축
- 1차 목표: 비교/sweep이 아니라, RTL intake부터 backend route/post-route report까지 end-to-end flow 1회 완주
- Source candidate: https://github.com/wILLIEWILLYWILLIe/MNIST-NPU-ASIC
- Backup candidate: https://github.com/Sequner/sTPU

---

## 1. Project Purpose

Open-source MNIST NPU RTL을 input design으로 선정한다. 핵심은 RTL 설계가 아니라 implementation flow 구축이다.

목표 flow:

```text
GitHub RTL intake
→ source revision freeze
→ top/dependency analysis
→ filelist cleanup
→ SDC creation
→ DC synthesis
→ Formality R2N
→ ICC2 init_design
→ floorplan
→ powerplan
→ placement
→ CTS
→ route
→ post-route timing/report extraction
→ DRC/ANT/legality/PG checks
→ RESULT_SUMMARY
```

Portfolio one-liner:

> Open-source MNIST NPU RTL을 대상으로 RTL intake, DC synthesis, Formality R2N, ICC2 floorplan/powerplan/place/CTS/route, post-route analysis까지 연결되는 FE-to-BE implementation flow를 구축했다.

---

## 2. Why This Project

선정 이유:

```text
- NPU target이 명확함
- SystemVerilog RTL
- 4-layer MNIST neural network processor
- NVDLA보다 작아 backend 반복 가능성 높음
- 단순 MAC array보다 프로젝트 크기/이름이 자연스러움
- ASIC flow 흔적이 있어 implementation target으로 적합
```

이 프로젝트는 NVDLA 이후 backend 확장용이다. NVDLA는 큰 accelerator Front-End/Formality/DFT evidence. MNIST_NPU는 더 작은 accelerator RTL을 실제 backend route까지 연결하는 implementation flow target.

---

## 3. First Milestone

1차 목표:

```text
MNIST NPU RTL 1개 baseline을 FE-to-BE 끝까지 연결한다.
```

1차 완료 기준:

```text
- repo cloned and commit frozen
- README/license/source recorded
- top module identified
- RTL dependency/filelist cleaned
- SDC written
- DC analyze/elaborate/link completed
- DC synthesis completed
- netlist/DDC/SDC/SDF/SVF generated
- Formality R2N passed or failing root cause documented
- ICC2 init_design completed
- floorplan generated
- powerplan generated
- placement completed
- CTS completed
- route completed
- open nets / legality / PG / DRC / timing reports collected
- RESULT_SUMMARY.md written
```

Strong done:

```text
- R2N PASS
- route open nets 0
- legality clean
- PG connectivity clean
- route DRC clean or root cause classified
- setup/hold checked after route
- scripts rerunnable from clean workspace
```

---

## 4. Non-goals for First Milestone

First pass에서 하지 않는 것:

```text
- NPU accuracy improvement
- neural network retraining
- RTL redesign
- heavy architecture optimization
- clock/utilization comparison
- power IR/EM signoff
- macro memory replacement
- DFT/ATPG
```

이후 확장:

```text
- clock sweep: 10ns / 7ns / 5ns
- utilization sweep: 50% / 60% / 70%
- place/CTS/route QoR cross-check
- timing ECO case
- SAIF/VCD power estimate if feasible
```

---

## 5. Work Breakdown

### A0 — Repository Intake

Tasks:

```text
1. Clone source repo.
2. Record commit hash.
3. Read README/license.
4. Identify RTL directory.
5. Identify top module.
6. Identify simulation/synthesis scripts if present.
7. Check use of $readmemh, packages, generated weights, vendor primitives.
8. Create local project structure.
```

Deliverables:

```text
00_Project_Tracking/SOURCE_REVISION.md
docs/rtl_intake.md
1_Input/filelists/rtl.f
```

Exit criteria:

```text
top module known
filelist draft exists
license/source recorded
```

### A1 — Front-End Setup

Tasks:

```text
1. Create DC filelist.
2. Create top-level setup Tcl.
3. Create initial SDC.
4. Define clock/reset.
5. Define basic IO delays.
6. Define false paths only with reason.
```

Deliverables:

```text
1_Input/constraints/mnist_npu_10ns.sdc
2_Synthesis/0_Script/run_dc.tcl
2_Synthesis/0_Script/run_dc.sh
```

Exit criteria:

```text
DC analyze/elaborate/link runs without unresolved fatal errors
```

### A2 — DC Synthesis Baseline

Run target:

```text
clock: 10ns
top: selected MNIST NPU top
mode: functional
library: current EDA standard-cell library if possible
```

Tasks:

```text
1. Run synthesis at 10ns.
2. Save DDC/netlist/SDC/SDF/SVF.
3. Generate reports.
4. Classify warnings: harmless / constraint issue / RTL issue / library issue.
```

Reports:

```text
check_design.rpt
report_qor.rpt
report_timing.max.rpt
report_timing.min.rpt
report_area.rpt
report_power.rpt
report_constraint.rpt
report_reference.rpt
```

Exit criteria:

```text
netlist generated
no unresolved references
setup result recorded
```

### A3 — Formality R2N

Tasks:

```text
1. Read RTL reference.
2. Read DC netlist implementation.
3. Read SVF.
4. Apply same top and constants.
5. Run match/verify.
6. Record passing/failing/unverified compare points.
```

Deliverables:

```text
3_Formality/0_Script/run_fm_r2n.tcl
3_Formality/4_Report/r2n.summary.rpt
```

Exit criteria:

```text
R2N PASS preferred
If fail: first failing cone/root cause documented
```

### A4 — ICC2 Init / Floorplan / Powerplan

Tasks:

```text
1. Build/reuse tech/NDM setup.
2. Read synthesized netlist.
3. Read constraints.
4. Link design.
5. Create floorplan.
6. Create power ring/stripe/rail.
7. Check PG connectivity and PG DRC.
```

Initial physical target:

```text
clock: 10ns
utilization: 55~60%
aspect ratio: 1:1
macro: avoid if possible
```

Reports:

```text
check_design.rpt
design_physical.rpt
utilization.rpt
pg_connectivity.rpt
pg_drc.rpt
```

Exit criteria:

```text
linked ICC2 design saved
floorplan exists
PG reports collected
```

### A5 — Placement / CTS / Route

Tasks:

```text
1. Run placement.
2. Legalize and report timing.
3. Run CTS.
4. Report clock QoR.
5. Run routing.
6. Check open nets.
7. Check route DRC and antenna.
8. Extract timing reports.
```

Reports:

```text
place_qor.rpt
place_timing.max.rpt
place_timing.min.rpt
clock_qor.summary.rpt
clock_qor.drc_violators.rpt
route_check_routes.rpt
route_timing.max.rpt
route_timing.min.rpt
check_legality.rpt
antenna.rpt
```

Exit criteria:

```text
route stage completed
open nets recorded
legality recorded
DRC status recorded
timing status recorded
```

### A6 — Summary / Final Report

Tasks:

```text
1. Summarize run status.
2. Create stage table.
3. Link evidence reports.
4. State exact open items.
5. Write next-step comparison candidates only after baseline exists.
```

Deliverables:

```text
00_Project_Tracking/PROJECT_STATUS.md
00_Project_Tracking/RESULT_SUMMARY.md
00_Project_Tracking/RUN_LOG.md
docs/final_fe_to_be_flow_report.md
```

---

## 6. Project Directory Template

```text
MNIST_NPU_IMPLEMENTATION_FLOW/
├── README.md
├── docs/
│   ├── rtl_intake.md
│   ├── constraint_strategy.md
│   ├── backend_flow.md
│   └── final_fe_to_be_flow_report.md
├── 0_RTL/
├── 1_Input/
│   ├── filelists/
│   ├── constraints/
│   └── tech/
├── 2_Synthesis/
│   ├── 0_Script/
│   ├── 2_Output/
│   ├── 3_Log/
│   └── 4_Report/
├── 3_Formality/
│   ├── 0_Script/
│   ├── 3_Log/
│   └── 4_Report/
├── 4_Backend_ICC2/
│   ├── 0_Script/
│   │   ├── 00_setup/
│   │   ├── 01_init_design/
│   │   ├── 02_floorplan/
│   │   ├── 03_powerplan/
│   │   ├── 04_place/
│   │   ├── 05_cts/
│   │   ├── 06_route/
│   │   ├── 07_extract_sta/
│   │   └── 99_util/
│   ├── 2_Output/
│   ├── 3_Log/
│   └── 4_Report/
├── scripts/
│   ├── collect_reports.py
│   ├── parse_qor.py
│   └── make_summary.py
└── 00_Project_Tracking/
    ├── SOURCE_REVISION.md
    ├── PROJECT_STATUS.md
    ├── RESULT_SUMMARY.md
    ├── RUN_LOG.md
    └── DECISION_LOG.md
```

---

## 7. Possible Blockers

```text
- source uses generated weight package or large constants
- top module not backend-friendly
- inferred memory becomes huge
- Formality mismatch due constant arrays/ROM
- synthesis runtime too long
- route DRC from library/tech setup
```

Handling:

```text
Classify blocker first.
Patch filelist/constraints/scripts first.
Only isolate smaller top if full top is not feasible.
Use sTPU backup only if primary repo blocks early.
```

---

## 8. First 2-Day Action Plan

Day 1:

```text
clone MNIST-NPU-ASIC
record commit
inspect RTL structure
create rough filelist
try DC analyze/elaborate/link
record blockers
```

Day 2:

```text
fix filelist/setup
create initial SDC
run first DC synthesis if link succeeds
write SOURCE_REVISION.md and rtl_intake.md
```

Decision after Day 2:

```text
If DC analyze/link OK → proceed MNIST NPU as first baseline.
If source structure blocks heavily → inspect sTPU backup.
```

---

## 9. Claim Boundary

Allowed after first baseline:

```text
FE-to-BE implementation flow 구축
DC synthesis 완료
Formality R2N 검증 수행/PASS if passed
ICC2 floorplan/powerplan/place/CTS/route 수행
post-route timing/DRC/QoR report 확보
```

Use only if true:

```text
signoff-clean
DRC clean
hold clean
IR/EM complete
LVS clean
ATPG complete
```

Status labels:

```text
PASS
PASS_WITH_NOTE
PASS_WITH_OPEN
RECORDED
BLOCKED_WITH_ROOT_CAUSE
```
