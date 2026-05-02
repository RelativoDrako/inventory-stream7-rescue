#!/usr/bin/env bash
set -euo pipefail
ROOT="${1:-$(pwd)}"
OUT_DIR="$ROOT/shared/ip/evidence"
mkdir -p "$OUT_DIR"
TS="$(date +%Y%m%d_%H%M%S)"
OUT="$OUT_DIR/ip_manifest_$TS.txt"
echo "# IP MANIFEST" > "$OUT"
echo "generated_at=$TS" >> "$OUT"
echo "root=$ROOT" >> "$OUT"
find "$ROOT" -type f \
  ! -path "*/.git/*" \
  ! -path "*/output/*" \
  ! -name "*.zip" \
  -print0 | sort -z | xargs -0 sha256sum >> "$OUT"
echo "Manifest: $OUT"
