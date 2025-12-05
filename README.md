# HPCA-2026-ReScue
Artifact Evaluation for HPCA-2026-ReScue

# ReScue: Reliable and Secure CXL Memory – Artifact

This repository contains the artifact for the HPCA 2026 paper **“ReScue: Reliable and Secure CXL Memory”**. It provides RTL code, FPGA bitstreams, scripts, and instructions to reproduce the key experimental results in the paper.

We expose four main experiment sets:

1. **System hang vulnerability and makeshift fix** (AXI tag limitation under delayed CXL memory, Fig. 4) – `AE1/`
2. **Latency shaping of ReScue-S** (latency equalizer and randomizer, Figs. 11 and 12) – `AE23/`
3. **Performance overhead of ReScue-S** (Fig. 13) – `AE23/`
4. **Performance overhead of ReScue-R** (Fig. 10) – `AE4/`

All experiments are evaluated on an Intel Agilex FPGA–based CXL Type-3 device connected to an Intel Xeon system.

---

## 1. Repository Structure

- `AE1/`  
  Artifact RTL code, scripts and bitstreams to reproduce **system hangs** with delayed CXL memory and validate the **makeshift solution** (Fig. 4).

- `AE23/`  
  RTL code, scripts and bitstreams for:
  - **Latency distribution measurements** of baseline CXL and ReScue-S (equalizer and randomizer) (Figs. 11 and 12).
  - **Performance evaluation of ReScue-S** (SPEC CPU2017) (Fig. 13).

- `AE4/`  
  RTL code, scripts and bitstreams for **performance evaluation of ReScue-R**, including configurations with and without a Bloom filter (Fig. 10).


---

## 2. Prerequisites

### Hardware

- Host: Intel Xeon scalable server with **CXL support**.
- Device: **Intel Agilex 7 I-series FPGA (revision version RBES)** (CXL Type-3 device) configured with Intel Agilex FPGA Hard IP for CXL.

### Software

- OS: Linux with **kernel 6.5.5** (or compatible) configured and selected as default.
- FPGA tools: **Intel Quartus Prime Programmer** (program the provided `.cdf` / `.pof` files).
- Compilers / runtimes:
  - `g++` (version 8 or newer)
  - `Python 3` with the following packages:
    - `numpy`
    - `matplotlib`
    - `pandas`
- Benchmarks (for performance experiments):
  - **SPEC CPU2017** 
  - **GAPBS**:
    - https://github.com/sbeamer/gapbs
  - **DRAMA** (for latency measurement):
    - https://github.com/IAIK/drama

> The microbenchmarks used in AE1 and the latency-measurement harness in AE23 are provided in this repository.

## 3. Basic Setup

### 3.1 Clone the Repository

On the host (connected to the Agilex FPGA board) and programming server:

```bash
git clone https://github.com/ece-fast-lab/HPCA-2026-ReScue.git
cd HPCA-2026-ReScue
```

### 3.2 Common FPGA Programming Wrapper

Most experiments use a bash script to program the FPGA:
```bash
bash program_fpga.sh <bitstream.cdf>
bash power_cycle.sh
bash repo/set_default.sh   # if applicable
```

## 4. Experiments Overview

### 4.1 System Hang & Makeshift (AE1 – Fig. 4)

- Demonstrate that high write intensity + high thread count can trigger system hangs with delayed CXL memory.
- Validate that limiting the number of in-flight commands (makeshift) removes hangs.
- See AE1/README.md

### 4.2 Latency Shaping with ReScue-S (AE23 – Figs. 11 & 12)

- Compare latency distributions of Baseline CXL design, eScue-S latency equalizer and ReScue-S latency randomizer.
- Show that ReScue-S merges two latency groups into a single group and that randomization gives slightly lower average latency than pure equalization.
- See AE23/README.md

### 4.3 Performance of ReScue-S (AE23 – Fig. 13)

- Measure percentage execution time overhead of ReScue-S: Baseline vs. ReScue-S (equalizer) vs. ReScue-S (randomizer).
- See AE23/README.md (Section “Performance Experiments (ReScue-S)”)


### 4.4 Performance of ReScue-R (AE4 – Fig. 10)
- Evaluate performance impact of ReScue-R under: Baseline (no repair), ReScue-R without Bloom filter and ReScue-R with Bloom filter (e.g., 512Kb)
- See AE4/README.md.