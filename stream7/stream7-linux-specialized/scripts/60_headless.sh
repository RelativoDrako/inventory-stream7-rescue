#!/usr/bin/env bash
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"
need_root
log 'Activando headless'
OUT="$REPORTS/07_headless.txt"
systemctl enable ssh NetworkManager >> "$OUT" 2>&1 || true
systemctl set-default multi-user.target >> "$OUT" 2>&1 || true
systemctl restart ssh NetworkManager >> "$OUT" 2>&1 || true
hostname -I >> "$OUT" 2>/dev/null || true
echo 'Headless target = multi-user.target' >> "$OUT"
