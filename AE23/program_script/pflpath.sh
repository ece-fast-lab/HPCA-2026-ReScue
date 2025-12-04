#!/usr/bin/env bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <file.cdf>"
    exit 1
fi

CDF_FILE="$1"

if [ ! -f "$CDF_FILE" ]; then
    echo "Error: file not found: $CDF_FILE"
    exit 1
fi

# 1) 백업 파일 이름 결정: file.cdf.1, file.cdf.2, ...
n=1
while true; do
    BACKUP="${CDF_FILE}.${n}"
    if [ ! -e "$BACKUP" ]; then
        cp "$CDF_FILE" "$BACKUP"
        echo "Backup created: $BACKUP"
        break
    fi
    n=$((n + 1))
done

# 2) 현재 작업 디렉터리 절대 경로
CWD="$(pwd)"

# sed에서 쓸 수 있게 /, & 이스케이프
ESCAPED_CWD="$(printf '%s\n' "$CWD" | sed 's/[\/&]/\\&/g')"

# 3) PFLPath("./...") → PFLPath("<절대경로>/...")
#    원본 파일을 in-place로 수정
sed -i "s#PFLPath(\"\.\/#PFLPath(\"$ESCAPED_CWD/#" "$CDF_FILE"

echo "Updated PFLPath in: $CDF_FILE"

