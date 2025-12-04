#!/bin/bash
CREDS="-H 192.17.102.189 -U ADMIN -P QMMNXZKUIM -I lanplus"
ipmitool $CREDS power cycle
