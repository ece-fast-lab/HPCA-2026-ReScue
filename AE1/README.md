
---

## `AE1/README.md` (system hang & makeshift – Fig. 4)

```markdown
# AE1 – System Hang Reproduction (Fig. 4)

This directory contains RTL code, scripts and bitstreams to reproduce the **system hang behavior** of an AXI-based CXL memory controller under delayed CXL memory, and to validate the **makeshift solution** that limits the number of in-flight commands.

The resulting behavior corresponds to **Fig. 4** of the HPCA paper.

---

## 1. Contents

- `afu_top/`
  - RTL code for afu_top.

- `program_script/`
  - Bitstream archive for delayed CXL design (e.g., `cxl_type3_v233_de_delay_128.zip`).
  - CDF file for programming (e.g., `AE1_v233_128.cdf`).
  - Helper scripts (e.g., `program_fpga.sh`, `power_cycle.sh`, `pflpath.sh`).

- `set_default/`
  - `buf_reader/`: CSR access helper and microbenchmark configuration.
  - `set_default.sh`: sets default AFU configuration.
  - `set_makeshift.sh`: applies makeshift (limits in-flight commands).

- `ubench_thread_stream/`
  - `compile`: builds the microbenchmark.
  - `mem_benchmark`: wrapper script that sweeps **RD:WR ratios** and **thread counts**.

---

## 2. Prerequisites

- FPGA already connected to the host and visible as a CXL device.
- Quartus programming tools installed and in `PATH`.
- Linux kernel 6.5.5 selected as default.
- `g++` for building the microbenchmark.

See the top-level `README.md` for full hardware/software prerequisites.

---

## 3. Step-by-Step Instructions

### 3.1 Program Delayed CXL Design

```bash
cd HPCA-2026-ReScue/AE1/program_script

# Unpack delayed CXL design bitstream
unzip cxl_type3_v233_de_delay_128.zip

# Update the CDF file path if needed
bash pflpath.sh AE1_v233_128.cdf

# Program the FPGA
bash program_fpga.sh AE1_v233_128.cdf

# Power-cycle the board / host so the new AFU is active
bash power_cycle.sh
```

### 3.2 Build and Configure the Microbenchmark

```bash
# Build helper for CSR access
cd HPCA-2026-ReScue/AE1/set_default/buf_reader
make

# Apply default AFU configuration
cd ..
bash set_default.sh

# Build the microbenchmark
cd ../ubench_thread_stream
source compile
```

### 3.3 Run Microbenchmark (Baseline – No Makeshift)

**mem_benchmark** usage: 

```bash
# Usage:
#   bash mem_benchmark <read_write_ratio> <min_threads> <max_threads>
#
# Example ratios:
#   1   -> RD:WR = 1:0  (read-only)
#   0.5 -> RD:WR = 0.5:0.5 (mixed)
#   0   -> RD:WR = 0:1  (write-only)
```

Run:

```bash
# Mostly reads – no system hang expected
bash mem_benchmark 1   1 32

# Mixed reads/writes – system may hang for large thread counts
bash mem_benchmark 0.5 1 32

# Write-intensive – system may hang for large thread counts
bash mem_benchmark 0   1 32
```

Expected behavior (before makeshift):

- For RD:WR = 1:0, no hang is expected for any thread count.
- As the write ratio increases and more threads are used (e.g., RD:WR = 0.5:0.5 or 0:1 with many threads), the system becomes more prone to hanging and may crash.

If the system hangs, reset or power-cycle the host and re-program the FPGA as needed.

### 3.4 Apply Makeshift and Re-run

After confirming the hang behavior, apply the makeshift configuration:

```bash
cd HPCA-2026-ReScue/AE1/set_default
bash set_makeshift.sh

cd ../ubench_thread_stream

# Repeat the sweep
bash mem_benchmark 1   1 32
bash mem_benchmark 0.5 1 32
bash mem_benchmark 0   1 32
```

Expected behavior (with makeshift):
- No system hang should be observed for any of the tested RD:WR ratios and thread counts.
- This validates that limiting the number of in-flight commands removes the hang even under heavy-write, many-thread conditions.


## 4. Note

Exact thread thresholds for hangs depend on the host system.

You may repeat runs or adjust <min_threads> / <max_threads> for finer exploration.
