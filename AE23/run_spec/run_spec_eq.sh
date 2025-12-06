#!/bin/bash
CUR_DIR="$(pwd)"

cd /research/chihun/bench/spec2017 || exit 1
source shrc

cd "$CUR_DIR"

echo "Running SEPC2017"
sudo numactl -N 0 -m 1 /research/chihun/bench/spec2017/bin/runcpu --noreportable --size ref --tuning base --iteration 1 --action onlyrun --config myprogram-gcc-linux-x86.cfg --copies=8 548 525 502  > eq_spec_int.lis

