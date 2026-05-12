# MNIST NPU ASIC Implementation Flow

This repository records a learning-oriented RTL-to-GDS ASIC implementation flow
for an MNIST NPU using Synopsys tools and the SAED32 RVT educational library.

The goal of this project is flow establishment and evidence recording, not RTL
architecture optimization or tapeout signoff.

## Baseline

| Item | Value |
| --- | --- |
| Baseline name | `mnist_npu_rvt_tt_10ns_route` |
| RTL source | `wILLIEWILLYWILLIe/MNIST-NPU-ASIC` |
| Frozen RTL commit | `d1e31ea9e6fdfde157fee62fbf7f91658e382f09` |
| Top module | `nn_top` |
| Standard cell library | SAED32 RVT |
| Corner | TT 1.05V 25C |
| Clock period | `10 ns` |
| Backend target utilization | 55% first baseline, with later controlled debug trials |
| Macro replacement | Disabled; memories remain FF-array based for this baseline |

## Current Status

The current learning baseline is:

```text
LEARNING_GDS_EXPORTED_ANTENNA_NOT_PROVEN
```

Active ICC2 block:

```text
4_Backend_ICC2/2_Output/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/mnist_npu_icc2_lib:route_a20_eopen4.design
```

Closure status from recorded reports:

| Item | Status |
| --- | --- |
| DC topographical synthesis | PASS |
| Formality RTL-to-netlist | PASS |
| Route DRC/open nets | CLEAN for active candidate |
| PG connectivity/PG DRC | CLEAN for active candidate |
| Legality | CLEAN for active candidate |
| Setup timing | CLEAN |
| Hold timing | POLICY_CLEAN under setup/hold uncertainty `0.100 / 0.040 ns` |
| Max transition/max capacitance | CLEAN for active candidate |
| Learning GDS | Exported locally |
| Antenna | NOT_PROVEN because no antenna rules are defined |

This is not a signoff-clean or tapeout-ready result. LVS, foundry signoff DRC,
antenna-rule coverage, OCV/SI, IR/EM, ATPG, and tapeout package checks are not
complete.

## Repository Layout

```text
00_Project_Tracking/   Decision log, run log, status, source revision, summaries
1_Input/               Filelists, constraints, and technology setup snippets
2_Synthesis/           Design Compiler scripts and reports
3_Formality/           Formality scripts and reports
4_Backend_ICC2/        ICC2 scripts and reports
docs/                  Additional project notes
scripts/               Project helper scripts
```

Generated logs and implementation databases are intentionally ignored. Report
evidence under `2_Synthesis/4_Report`, `3_Formality/4_Report`, and
`4_Backend_ICC2/4_Report` is tracked for review.

The local GDS is intentionally not tracked in git:

```text
4_Backend_ICC2/2_Output/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/08_gds_learning_route_a20_eopen4/nn_top.route_a20_eopen4.learning.gds
```

It can be regenerated from the committed `08_gds` script.

## Key Evidence Files

| Purpose | File |
| --- | --- |
| Source revision | `00_Project_Tracking/SOURCE_REVISION.md` |
| Current status | `00_Project_Tracking/PROJECT_STATUS.md` |
| Run history | `00_Project_Tracking/RUN_LOG.md` |
| Decisions and rationale | `00_Project_Tracking/DECISION_LOG.md` |
| Result tables | `00_Project_Tracking/RESULT_SUMMARY.md` |
| Synthesis QoR | `2_Synthesis/4_Report/topo_10ns/post_compile.qor.rpt` |
| Formality result evidence | `3_Formality/4_Report/r2n_topo_10ns/` |
| Adopted post-route recheck | `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/07_extract_sta_route_a20_eopen4_adopted_uncertainty_004_recheck/` |
| GDS stream-out manifest | `4_Backend_ICC2/4_Report/trials/libdir_via1_no_track_trim_all_pin_util45_route_rerun3/08_gds_learning_route_a20_eopen4/stream_out_manifest.txt` |

## Reproducing The Main Stages

Licensed Synopsys tools should be run in the normal user shell, not inside a
restricted sandbox.

Run DC topographical synthesis:

```bash
cd /DATA/home/edu135/MNIST
2_Synthesis/0_Script/run_dc_compile_topo.sh
```

Run Formality RTL-to-netlist verification:

```bash
cd /DATA/home/edu135/MNIST
3_Formality/0_Script/run_fm_r2n_topo.sh
```

Regenerate the learning GDS from the active saved ICC2 block:

```bash
cd /DATA/home/edu135/MNIST
4_Backend_ICC2/0_Script/08_gds/run_learning_gds_stream_out.sh
```

The full backend involved several controlled debug and ECO trials. Use
`00_Project_Tracking/RUN_LOG.md` and `00_Project_Tracking/RESULT_SUMMARY.md` to
identify which branch is adopted and which branches are diagnostic only.

## Notes For Fresh Checkouts

The upstream RTL clone under `0_RTL/` is not vendored in this repository. To
recreate it:

```bash
cd /DATA/home/edu135/MNIST
mkdir -p 0_RTL
git clone https://github.com/wILLIEWILLYWILLIe/MNIST-NPU-ASIC.git 0_RTL/MNIST-NPU-ASIC
cd 0_RTL/MNIST-NPU-ASIC
git checkout d1e31ea9e6fdfde157fee62fbf7f91658e382f09
```

The SAED32 library paths are project-local to the lab environment and are
recorded in `1_Input/tech/` and the backend setup scripts.
