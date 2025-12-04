#!/bin/bash
source set_cpu

echo "RESET BF"
sudo ./buf_reader/buf_reader ./buf_reader/result_hcode/RESET_1M.txt

echo "End RESET BF"

sleep 10s


echo "Set 16K Repair"

sudo ./buf_reader/buf_reader ./buf_reader/result_hcode/addresses_m0000000001111111001111111000111111_v1010101010101010101010101010101010_16K.txt

echo "End 16K Repair"


