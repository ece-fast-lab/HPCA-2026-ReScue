#!/bin/bash

LOGFILE="$1"

if [ -z "$LOGFILE" ]; then
  echo "Usage: $0 <spec_log_file>"
  exit 1
fi

grep "Copy " "$LOGFILE" | awk '
{
  # Extract benchmark, run, and elapsed time
  match($0, /Copy [0-9]+ of ([^.]+)\.([^ ]+) .* run ([0-9]+) .*Total elapsed time: ([0-9.]+)/, arr)
  key = arr[1] "." arr[2] "_run" arr[3]
  time = arr[4] + 0

  # Keep the max time and line for each key
  if (!(key in seen)) {
    seen[key] = 1
    order[order_count++] = key
    max_time[key] = time
    line[key] = $0
  } else if (time > max_time[key]) {
    max_time[key] = time
    line[key] = $0
  }
}
END {
  for (i = 0; i < order_count; i++) {
    k = order[i]
    print line[k]
  }
}'

