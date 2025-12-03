#!/bin/bash

source set_cpu

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <read_write_ratio> <min_threads> <max_threads>"
    exit 1
fi

RATIO=$1
MIN_THREADS=$2
MAX_THREADS=$3
OUTFILE="result_RD${RATIO}.lis"

# Start with a clean file
: > "$OUTFILE"

START_TS=$(date +%s)

TAIL_PID=""
TIMER_PID=""

cleanup() {
    # Stop tail and timer when the script ends
    [ -n "$TAIL_PID" ] && kill "$TAIL_PID" 2>/dev/null
    [ -n "$TIMER_PID" ] && kill "$TIMER_PID" 2>/dev/null
}
trap cleanup EXIT

# 1) Show result file in real time (like tail -f)
tail -f "$OUTFILE" &
TAIL_PID=$!

# 2) Print elapsed time every 1 second (only to stdout)
(
    while true; do
        now=$(date +%s)
        elapsed=$((now - START_TS))
        printf '\rElapsed: %ds\n' "$elapsed"
        sleep 1
    done
) &
TIMER_PID=$!

# 3) Main loop: run benchmark and append output to the log file
for i in $(seq "$MIN_THREADS" "$MAX_THREADS"); do
    # Header line for each run (goes to file; you will see it via tail)
    echo "RD${RATIO} Thread$i" >> "$OUTFILE"

    # Append benchmark output (important: use >>, not >)
    sudo numactl -m 1 ./mem_benchmark "$RATIO" "$i" >> "$OUTFILE"
done

# When the loop exits, trap EXIT will run cleanup()
# so tail + timer stop automatically and the script ends.

