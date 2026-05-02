#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-$(pwd)}"
OUT_DIR="$ROOT/shared/ip/evidence"
mkdir -p "$OUT_DIR"

TS="$(date +%Y%m%d_%H%M%S)"
MANIFEST="$OUT_DIR/release_manifest_$TS.sha256"
INVENTORY="$OUT_DIR/release_inventory_$TS.txt"
META="$OUT_DIR/release_metadata_$TS.txt"

echo "# RELEASE METADATA" > "$META"
echo "generated_at=$TS" >> "$META"
echo "root=$ROOT" >> "$META"
echo "git_commit=$(git -C "$ROOT" rev-parse HEAD 2>/dev/null || echo not_available)" >> "$META"
echo "git_branch=$(git -C "$ROOT" rev-parse --abbrev-ref HEAD 2>/dev/null || echo not_available)" >> "$META"

find "$ROOT" -type f \
  ! -path "*/.git/*" \
  ! -path "*/output/*" \
  ! -path "*/shared/ip/evidence/*" \
  ! -name "*.zip" \
  -print | sort > "$INVENTORY"

while IFS= read -r f; do
  sha256sum "$f"
done < "$INVENTORY" > "$MANIFEST"

echo "metadata=$META"
echo "inventory=$INVENTORY"
echo "manifest=$MANIFEST"
