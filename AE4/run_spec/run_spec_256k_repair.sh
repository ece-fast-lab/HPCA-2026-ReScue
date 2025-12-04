#!/bin/bash
CUR_DIR="$(pwd)"

cd /research/chihun/bench/spec2017 || exit 1
source shrc

cd "$CUR_DIR"

cd ../set_default/
bash set_256k_repair.sh 
cd ../run_spec

echo "Running SEPC2017 BASE"
sudo numactl -N 0 -m 1 /research/chihun/bench/spec2017/bin/runcpu --noreportable --size ref --tuning base --iteration 1 --action onlyrun --config myprogram-gcc-linux-x86.cfg --copies=8 502  > 256k_repair_spec_int.lis

