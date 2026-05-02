#!/usr/bin/env bash
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"
need_root
log 'Unfreeze temporal baseline'
OUT="$REPORTS/09_unfreeze.txt"
HOLDS=(linux-image-686-pae firmware-realtek firmware-misc-nonfree firmware-linux-nonfree intel-microcode network-manager openssh-server xfce4-power-manager onboard)
for p in "${HOLDS[@]}"; do dpkg -s "$p" >/dev/null 2>&1 && apt-mark unhold "$p" >> "$OUT" 2>&1 || true; done
rm -f "$STATE/freeze/state.txt"
