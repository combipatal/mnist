# Source Revision

## Primary RTL Source

- Repository: https://github.com/wILLIEWILLYWILLIe/MNIST-NPU-ASIC
- Local path: `0_RTL/MNIST-NPU-ASIC`
- Frozen commit: `d1e31ea9e6fdfde157fee62fbf7f91658e382f09`
- Clone date: 2026-05-09

## Source Notes

- Target design is the 4-layer MNIST NPU under `neural_net_4layer/`.
- README describes the design as a 16-bit Q12, 32-lane time-multiplexed NPU.
- README states weights are provided through `weight_pkg.sv` instead of `$readmemh`.
- No top-level `LICENSE` file was found during initial intake.

## Baseline Library Plan

- Library root: `/DATA/home/edu135/lib/SAED32_EDK`
- First-pass cell family: SAED32 RVT
- First-pass corner: TT 1.05V 25C
- First-pass clock target: 10 ns

