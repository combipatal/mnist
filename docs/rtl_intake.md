# RTL Intake

## Selected Source

- Source repo: `wILLIEWILLYWILLIe/MNIST-NPU-ASIC`
- Frozen commit: `d1e31ea9e6fdfde157fee62fbf7f91658e382f09`
- RTL directory: `0_RTL/MNIST-NPU-ASIC/neural_net_4layer/hardware/frontend/sv`

## Candidate Top

- Top module: `nn_top`
- Source file: `nn_top.sv`
- Main ports:
  - `clk`
  - `reset`
  - `wr_en`
  - `din`
  - `in_full`
  - `inference_done`
  - `predicted_class`
  - `max_score`

## Synthesis RTL Set

Initial synthesis filelist uses the current package-based NPU implementation:

- `nn_pkg.sv`
- `weight_pkg.sv`
- `fifo.sv`
- `npu_mac.sv`
- `argmax.sv`
- `nn_top.sv`

Excluded from first DC baseline:

- `nn_tb.sv`
- `nn_tb_all.sv`
- `hardware/frontend/uvm/*`
- `hardware/backend/genus/nn_top_syn.v`
- `hardware/backend/innovus/*`
- older `layer.sv` and `neuron.sv` unless dependency analysis proves they are still needed

## Initial Risk Notes

- `weight_pkg.sv` is large and may dominate analyze/elaborate runtime.
- The active top appears package-based, but older `layer.sv` and `neuron.sv` still contain `$readmemh`; keep them out of the first synthesis filelist.
- No source license file was found in the repo root during initial intake.
- Next checkpoint is DC `analyze/elaborate/link` with SAED32 RVT TT setup.

