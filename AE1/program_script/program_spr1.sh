#!/bin/bash

QUARTUS_PATH="/fast-lab-share/software/quartus/24.3.1/quartus/bin"
CDF_FILE="${1:-id_4.cdf}"  # Use first argument if provided, otherwise default to id_4.cdf

#sudo $QUARTUS_PATH/quartus_pgm -c "USB-BlasterII [3-11]" "$CDF_FILE"
sudo $QUARTUS_PATH/quartus_pgm -c "USB-BlasterII [3-11]" "$CDF_FILE"
