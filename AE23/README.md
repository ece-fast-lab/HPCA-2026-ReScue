
---

## `AE23/README.md` (ReScue-S latency & performance – Figs. 11, 12, 13)

# AE23 – ReScue-S Latency & Performance (Figs. 11, 12, 13)

This directory contains bitstreams and scripts to reproduce:

1. **Latency distributions** of:
   - Baseline CXL design
   - ReScue-S latency equalizer
   - ReScue-S latency randomizer  
   (Figs. 11 and 12)

2. **Performance overhead of ReScue-S** using SPEC CPU2017 and GAPBS (Fig. 13).

---

## 1. Contents

- `afu_top/`
  - RTL code for afu_top.

- `program_script/`
  - Bitstream archives (e.g., `RANDOM.zip`, `RETIMER.zip`).
  - CDF files (e.g., `AE23_EQ.cdf`, `AE23_RAND.cdf`).
  - Helper scripts: `program_fpga.sh`, `power_cycle.sh`, `pflpath.sh`.

- `set_default/`
  - `buf_reader/`: helper code for CSR interaction.
  - `set_base.sh`: configure baseline mode.
  - `set_eq.sh`: configure ReScue-S **equalizer**.
  - `set_rand.sh`: configure ReScue-S **randomizer**.

- `latency_meas/`
  - `Makefile`, measurement harness, and scripts.
  - `obj/`:
    - `run_meas`: driver to collect latency samples (`base`, `eq`, `rand`).
    - Python scripts:
      - `latency_dist.py`
      - `bank_lat_stdev_naxis.py`

- `run_spec/`
  - Scripts to run SPEC CPU2017 & GAPBS and extract execution times:
    - `set_base.sh`, `set_eq.sh`, `set_rand.sh`
    - `extract_spec_times.sh`
  - Output `.lis` and log files.

---

## 2. Prerequisites

- DRAMA and any other latency-measurement dependencies installed.
- SPEC CPU2017 and GAPBS installed and configured on the host (see their documentation).
- Python 3 with `numpy`, `matplotlib`, `pandas`.
- `g++` for building measurement and benchmark harnesses.

See the root `README.md` for full environment details.

---

## 3. Latency Experiments (Figs. 11 & 12)

### 3.1 Program Baseline / Equalizer Bitstream

First, program the **equalizer** bitstream (baseline and equalizer share this bitstream; configuration is done via CSR):

```bash
cd HPCA-2026-ReScue/AE23/program_script

# Unpack bitstreams if needed
unzip RANDOM.zip
unzip RETIMER.zip

# Set the correct path in the CDF
bash pflpath.sh AE23_EQ.cdf

# Program FPGA with EQ/retimer design
bash program_fpga.sh AE23_EQ.cdf

# Power-cycle the board / host
bash power_cycle.sh
```

### 3.2 Build Measurement Program

```bash
# CSR helper
cd HPCA-2026-ReScue/AE23/set_default/buf_reader
make

# Build latency measurement code
cd ../../latency_meas
make
cd obj
```
### 3.3 Baseline Latency

```bash
# Configure baseline mode
cd ../../set_default
bash set_base.sh

# Run baseline latency measurement
cd ../latency_meas/obj
source run_meas base    # generates base.csv

# Optional: adjust number of iterations inside run_meas if needed
chmod 777 base.csv

# Create a Python virtual environment (optional but recommended)
python3 -m venv .venv
source .venv/bin/activate

# Generate plots for baseline
pip install numpy matplotlib pandas
python latency_dist.py base.csv
python bank_lat_stdev_naxis.py base.csv

deactivate

# Expected output PNGs:
#   base_time_distribution.png
#   base_pair_scatter.png
```

Expected results:
- Baseline shows two distinct latency groups in both the time-distribution plot and scatter plot.

### 3.4 ReScue-S Equalizer Latency

```bash
# Configure equalizer mode
cd ../../set_default
bash set_eq.sh

cd ../latency_meas/obj
source run_meas eq      # generates eq.csv
chmod 777 eq.csv

source .venv/bin/activate    # if previously created
python latency_dist.py eq.csv
python bank_lat_stdev_naxis.py eq.csv
deactivate

# Expected output PNGs:
#   eq_time_distribution.png
#   eq_pair_scatter.png
```

Expected results:
- Equalizer merges the two baseline latency groups into a single, narrower group.

### 3.5 ReScue-S Randomizer Latency

Reprogram the FPGA with the randomizer bitstream:
```bash
cd HPCA-2026-ReScue/AE23/program_script

bash pflpath.sh AE23_RAND.cdf
bash program_fpga.sh AE23_RAND.cdf
bash power_cycle.sh
```

After the system is back up:
```bash
# Configure randomizer mode
cd HPCA-2026-ReScue/AE23/set_default
bash set_rand.sh

cd ../latency_meas/obj
source run_meas rand    # generates rand.csv
chmod 777 rand.csv

source .venv/bin/activate
python latency_dist.py rand.csv
python bank_lat_stdev_naxis.py rand.csv
deactivate

# Expected output PNGs:
#   rand_time_distribution.png
#   rand_pair_scatter.png
```

Expected results:
- Randomizer also shows a single latency group, similar to equalizer.
- Average latency with randomization is slightly lower than with pure equalization.

## 4. Performance Experiments (ReScue-S – Fig. 13)

These experiments evaluate the percentage execution time overhead of ReScue-S using SPEC CPU2017 and GAPBS.

### 4.1 Baseline

```bash
# After programming the EQ bitstream (AE23_EQ.cdf) again, if needed:
cd HPCA-2026-ReScue/AE23/program_script
bash program_fpga.sh AE23_EQ.cdf
bash power_cycle.sh

# Configure baseline mode
cd HPCA-2026-ReScue/AE23/set_default
bash set_base.sh

# Run SPEC/GAP under baseline
cd ../run_spec
bash run_spec_base.sh   # applies baseline configuration for runs
# Run your SPEC(2017) and GAPBS scripts here, redirected to log
# After runs finish:
bash extract_spec_times.sh <log_file_for_baseline>
```

### 4.2 ReScue-S Equalizer

```bash
# Configure equalizer mode
cd HPCA-2026-ReScue/AE23/set_default
bash set_eq.sh

cd ../run_spec
bash run_spec_eq.sh
# Run SPEC/GAP under equalizer configuration
bash extract_spec_times.sh <log_file_for_eq>

```

### 4.3 ReScue-S RAndomizer

```bash
cd HPCA-2026-ReScue/AE23/program_script
bash program_fpga.sh AE23_RAND.cdf
bash power_cycle.sh

cd ../set_default
bash set_rand.sh

cd ../run_spec
bash run_spec_rand.sh
# Run SPEC/GAP under randomizer configuration
bash extract_spec_times.sh <log_file_for_rand>
```

### 4.4 Expected results
- Compute execution time overhead by comparing baseline vs. equalizer vs. randomizer.
- On average, ReScue-S should incur less than ~1.1% performance overhead across SPEC and GAP workloads (individual workloads may vary).
