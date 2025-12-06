
---

## `AE4/README.md` (ReScue-R performance – Fig. 10)

# AE4 – ReScue-R Performance (Fig. 10)

This directory contains RTL code, bitstreams and scripts to reproduce the **performance impact of ReScue-R**, including configurations:

1. Baseline (no repair)
2. ReScue-R without Bloom filter
3. ReScue-R with Bloom filter (e.g., 512Kb)

These results correspond to **Fig. 10** in the paper.

---

## 1. Contents

- `afu_top/`
  - RTL code for afu_top.

- `program_script/`
  - Bitstream archive for ReScue-R (e.g., `v243_RBES_rescue_r_512Kb_bf.zip`).
  - CDF file (e.g., `AE4_RESCUE_R_512Kb.cdf`).
  - Helper scripts: `program_fpga.sh`, `power_cycle.sh`, `pflpath.sh`.

- `set_default/`
  - `set_base.sh`: configures baseline (no repair).
  - Additional configuration scripts if needed.

- `run_spec/`
  - `run_spec_base.sh`: runs baseline SPEC/GAP.
  - `run_spec_256k_repair_nobf.sh`: runs ReScue-R without Bloom filter.
  - `run_spec_256k_repair.sh`: runs ReScue-R with Bloom filter.
  - `extract_spec_times.sh`: extracts execution times from log files.

---

## 2. Prerequisites

- SPEC CPU2017 and GAPBS installed and configured.
- The same host and FPGA environment as used for AE1/AE23.

---

## 3. FPGA Programming (ReScue-R)

```bash
cd HPCA-2026-ReScue/AE4/program_script

# Unpack bitstream if required
unzip v243_RBES_rescue_r_512Kb_bf.zip

# Update CDF path
bash pflpath.sh AE4_RESCUE_R_512Kb.cdf

# Program ReScue-R bitstream
bash program_fpga.sh AE4_RESCUE_R_512Kb.cdf

# Power-cycle board / host
bash power_cycle.sh
```

## 4. Performance Experiments (Fig. 10)

All performance runs are driven from **run_spec/.** Each script typically runs a subset of SPEC CPU2017 and GAPBS workloads and logs their execution times.

### 4.1 Baseline (no repair)

```bash
cd HPCA-2026-ReScue/AE4/set_default
bash set_base.sh    # configure baseline mode

cd ../run_spec
bash run_spec_base.sh

# After runs finish:
grep log base_spec_int.lis   # optional quick check
bash extract_spec_times.sh <baseline_log_file>
```

### 4.2 ReScue-R With Bloom Filter

This configuration enables the Bloom filter (e.g., 512Kb) to reduce metadata traffic and performance impact.

```bash
cd HPCA-2026-ReScue/AE4/run_spec

bash run_spec_256k_repair.sh

# After runs finish:
grep log 256k_repair_spec_int.lis   # optional check
bash extract_spec_times.sh <bf_log_file>
```

## 4.3 Expected results

- ReScue-R with Bloom filter (e.g., 512Kb):
Significantly reduced overhead (e.g., around ~0.3% for gcc and <0.2% on average across workloads).
