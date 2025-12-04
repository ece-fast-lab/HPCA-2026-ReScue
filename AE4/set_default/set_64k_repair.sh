#!/bin/bash
source set_cpu

echo "RESET BF"
sudo ./buf_reader/buf_reader ./buf_reader/result_hcode/RESET_1M.txt

echo "End RESET BF"

sleep 10s


echo "Set 64K Repair"

sudo ./buf_reader/buf_reader ./buf_reader/result_hcode/addresses_m0000000000011111001111111000111111_v1010101010101010101010101010101010_64K.txt

echo "End 64K Repair"


