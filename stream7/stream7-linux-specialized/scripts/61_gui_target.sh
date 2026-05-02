#!/usr/bin/env bash
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"
need_root
log 'Restaurando GUI'
OUT="$REPORTS/07b_gui_target.txt"
systemctl set-default graphical.target >> "$OUT" 2>&1 || true
echo 'GUI target = graphical.target' >> "$OUT"
