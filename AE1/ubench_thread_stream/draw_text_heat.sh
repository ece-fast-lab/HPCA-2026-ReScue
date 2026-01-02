#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  draw_text_heatmap.sh [--raw] [--max-thread N] file1.lis [file2.lis ...]

Parses *.lis logs that contain lines like:
  Running streaming benchmark: R/W = 0.50, threads = 8
  Total bandwidth: 12.34 GB/s

Outputs a text-based matrix (threads x read-ratio).

Cells:
  -   : no file provided for that read ratio
  X   : file exists for that read ratio, but bandwidth for that thread is missing (likely hang/timeout)
  num : bandwidth (raw GB/s or normalized 0.0~1.0)

Examples:
  ./draw_text_heatmap.sh result_RD1.lis result_RD0.5.lis result_RD0.lis
  ./draw_text_heatmap.sh --raw *.lis
EOF
}

RAW=0
MAX_THREAD=32

files=()
while (($#)); do
  case "$1" in
    --raw) RAW=1; shift;;
    --max-thread) MAX_THREAD="$2"; shift 2;;
    -h|--help) usage; exit 0;;
    --) shift; break;;
    -*) echo "Unknown option: $1" >&2; usage; exit 1;;
    *) files+=("$1"); shift;;
  esac
done

if ((${#files[@]}==0)); then
  usage >&2
  exit 1
fi

# Fixed read-ratio axis (matches the usual plot)
RATIOS=(1.0 0.9 0.8 0.7 0.6 0.5 0.4 0.3 0.2 0.1 0.0)

declare -A has_file   # ratio -> 1 if provided
declare -A bw         # "thread,ratio" -> bandwidth
MAX_BW=0

extract_ratio() {
  local f="$1" r
  r=$(awk 'match($0,/R\/W = [0-9.]+/){print substr($0,RSTART+6,RLENGTH-6); exit}' "$f" 2>/dev/null || true)
  if [[ -z "${r:-}" ]]; then
    if [[ "$f" =~ RD([0-9]+\.?[0-9]*) ]]; then
      r="${BASH_REMATCH[1]}"
    else
      r=""
    fi
  fi
  [[ -z "${r:-}" ]] && { echo ""; return 0; }
  printf "%.1f" "$r"
}

parse_file() {
  local f="$1" ratio="$2"
  awk -v ratio="$ratio" '
    BEGIN{t=""}
    /Running streaming benchmark:/{
      if (match($0,/threads = [0-9]+/)) t = substr($0,RSTART+10,RLENGTH-10) + 0
      else t=""
      next
    }
    /Total bandwidth:/{
      if (t != "") {
        if (match($0,/Total bandwidth: [0-9.]+/)) {
          bw = substr($0,RSTART+16,RLENGTH-16) + 0
          print ratio, t, bw
        }
        t=""
      }
      next
    }
  ' "$f"
}

for f in "${files[@]}"; do
  [[ -f "$f" ]] || { echo "Missing file: $f" >&2; exit 1; }

  ratio=$(extract_ratio "$f")
  if [[ -z "$ratio" ]]; then
    echo "Cannot determine read ratio from: $f" >&2
    echo "Need 'R/W = 0.xx' line or filename containing 'RD0.xx'" >&2
    exit 1
  fi

  has_file["$ratio"]=1

  while read -r r t b; do
    key="${t},${r}"
    bw["$key"]="$b"
    if awk -v a="$b" -v m="$MAX_BW" 'BEGIN{exit !(a>m)}'; then
      MAX_BW="$b"
    fi
  done < <(parse_file "$f" "$ratio")
done

# Avoid divide-by-zero
awk 'BEGIN{exit !(0=='"$MAX_BW"')}' && MAX_BW=1

printf "# Text heatmap (threads x read ratio)\n"
printf "# max bandwidth observed: %.6g GB/s\n" "$MAX_BW"
printf "# cell = %s\n" "$( ((RAW)) && echo 'raw bandwidth (GB/s)' || echo 'normalized bandwidth (0.0~1.0)')"
printf "\n"

printf "%s" "Threads |"
for r in "${RATIOS[@]}"; do printf " %4s" "$r"; done
printf "\n"

printf "%s" "--------+"
for _ in "${RATIOS[@]}"; do printf "%s" "-----"; done
printf "\n"

for ((t=MAX_THREAD; t>=1; t--)); do
  printf "%7d |" "$t"
  for r in "${RATIOS[@]}"; do
    if [[ -z "${has_file[$r]:-}" ]]; then
      printf " %4s" "-"
      continue
    fi

    key="${t},${r}"
    if [[ -n "${bw[$key]:-}" ]]; then
      b="${bw[$key]}"
      if ((RAW)); then
        printf " %4.1f" "$b"
      else
        n=$(awk -v b="$b" -v m="$MAX_BW" 'BEGIN{printf "%.1f", (m>0? b/m : 0)}')
        printf " %4s" "$n"
      fi
    else
      printf " %4s" "X"
    fi
  done
  printf "\n"
done

printf "\nLegend:\n"
printf "%s\n" "  X : file exists for that read ratio, but the bandwidth line is missing for that thread (likely hang/timeout)"
printf "%s\n" "  - : no file provided for that read ratio (no data)"

