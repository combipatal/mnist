# AGENTS.md instructions for /DATA/home/edu135/MNIST

## Project Purpose

This repository is an MNIST NPU ASIC implementation-flow project.

The first required milestone is one complete FE-to-BE baseline:

```text
RTL intake
Design Compiler synthesis
Formality R2N
ICC2 init_design
floorplan
powerplan
placement
CTS
route
post-route timing/report extraction
DRC/antenna/legality/PG checks
RESULT_SUMMARY
```

The goal is flow establishment, not RTL architecture optimization.

## Fixed First Baseline

The first run is:

```text
mnist_npu_rvt_tt_10ns_route
```

Meaning:

```text
source: wILLIEWILLYWILLIe/MNIST-NPU-ASIC
top: nn_top
library: SAED32 RVT
corner: TT 1.05V 25C
clock period: 10 ns
backend utilization target: 55%
aspect ratio: 1:1
macro replacement: disabled for first pass
```

Use this baseline until it is either completed or blocked with a documented root cause.

## Recording Discipline

Do not leave important decisions only in chat or terminal output. Record them in the project.

Use these files:

```text
00_Project_Tracking/SOURCE_REVISION.md
  Source URL, frozen commit, license/source notes.

00_Project_Tracking/DECISION_LOG.md
  Fixed choices and rationale.

00_Project_Tracking/PROJECT_STATUS.md
  Current phase and next milestone checklist.

00_Project_Tracking/RUN_LOG.md
  Commands run, stage status, pass/fail notes, report paths.

00_Project_Tracking/RESULT_SUMMARY.md
  Final tables for synthesis, Formality, ICC2, timing, DRC, PG, legality.
```

When a tool run completes, update `RUN_LOG.md` and the relevant result table. If a run fails, record:

```text
stage
command
log path
first fatal error
suspected root cause
next action
```

## Communication Style

Keep communication concise and technical.

Use fuller wording only when needed for:

```text
destructive action confirmation
licensed EDA tool approval
multi-step instructions where short wording may cause mistakes
user asks for explanation or clarification
```

## Learning-Oriented Scripts

The user is learning EDA flow and Tcl. Prefer readable, direct Tcl over highly reusable framework code.

For scripts:

```text
simple variables
explicit file paths
one clear step after another
few procs unless genuinely needed
short comments before important blocks
```

Avoid over-engineered abstractions in the first-pass DC/FM/ICC2 scripts. Make the flow easy to read, debug, and study.

## Evidence Policy

Every major claim must point to an artifact.

Examples:

```text
RTL source frozen -> SOURCE_REVISION.md + git commit hash
Synthesis completed -> DC log + check_design report + mapped netlist + DDC
R2N passed -> Formality verify report
ICC2 init completed -> linked design save + check_design report
Floorplan completed -> saved design + utilization/floorplan report
Powerplan completed -> PG connectivity/PG DRC reports
Placement completed -> place QoR + legality + timing reports
CTS completed -> clock QoR + timing reports
Route completed -> route check + DRC/antenna + timing reports
```

Do not claim:

```text
signoff-clean
DRC clean
hold clean
IR/EM complete
LVS clean
ATPG complete
tapeout ready
```

unless there is explicit evidence in reports and docs.

## Folder Conventions

This project follows the planned MNIST implementation-flow layout:

```text
0_RTL/
1_Input/
2_Synthesis/
3_Formality/
4_Backend_ICC2/
scripts/
docs/
00_Project_Tracking/
```

Each major tool stage keeps:

```text
0_Script/
2_Output/
3_Log/
4_Report/
```

ICC2 scripts are grouped by step:

```text
4_Backend_ICC2/0_Script/00_setup/
4_Backend_ICC2/0_Script/01_init_design/
4_Backend_ICC2/0_Script/02_floorplan/
4_Backend_ICC2/0_Script/03_powerplan/
4_Backend_ICC2/0_Script/04_place/
4_Backend_ICC2/0_Script/05_cts/
4_Backend_ICC2/0_Script/06_route/
4_Backend_ICC2/0_Script/07_extract_sta/
4_Backend_ICC2/0_Script/99_util/
```

## Source Policy

The upstream RTL is cloned under:

```text
0_RTL/MNIST-NPU-ASIC/
```

Do not directly edit upstream RTL unless explicitly required. Prefer project-specific wrappers, patches, or generated helper files under:

```text
1_Input/
docs/
scripts/
```

Record upstream source state in:

```text
00_Project_Tracking/SOURCE_REVISION.md
docs/rtl_intake.md
```

## Filelist Policy

Use project filelists under:

```text
1_Input/filelists/
```

First-pass synthesis filelist:

```text
1_Input/filelists/rtl.f
```

Exclude simulation-only, UVM-only, and previous tool-output netlists from synthesis and Formality reference filelists.

For the first baseline, include the active package-based RTL only:

```text
nn_pkg.sv
weight_pkg.sv
fifo.sv
npu_mac.sv
argmax.sv
nn_top.sv
```

Do not include older `$readmemh`-based files unless dependency analysis proves they are needed.

## Tool And Library Decisions

Initial DC/Formality library:

```text
/DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_rvt/db_nldm/saed32rvt_tt1p05v25c.db
```

Initial ICC2 technology and physical files:

```text
/DATA/home/edu135/lib/SAED32_EDK/tech/milkyway/saed32nm_1p9m_mw.tf
/DATA/home/edu135/lib/SAED32_EDK/lib/stdcell_rvt/lef/saed32nm_rvt_1p9m.lef
/DATA/home/edu135/lib/SAED32_EDK/tech/star_rcxt/saed32nm_1p9m_nominal.tluplus
/DATA/home/edu135/lib/SAED32_EDK/tech/star_rcxt/saed32nm_tf_itf_tluplus.map
```

First-pass constraints:

```text
clock: clk
period: 10 ns
reset: reset
IO delay: simple baseline values until interface timing is refined
false paths: only with documented reason
```

## EDA Tool Execution

Run licensed EDA tools outside the sandbox.

Applies to:

```text
dc_shell
fm_shell
icc2_shell
lm_shell
pt_shell
lmutil
```

Use the sandbox only for lightweight file inspection, parsing, and documentation edits.

## First Debug Checkpoint

Before full synthesis, run only:

```text
DC analyze
DC elaborate nn_top
DC link
check_design
```

Do not proceed to ICC2 until the DC netlist, DDC, SDC, and SVF are generated or the failure is documented with root cause.
