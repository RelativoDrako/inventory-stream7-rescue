#!/usr/bin/env bash
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"
need_root
log 'Freeze temporal baseline'
OUT="$REPORTS/08_freeze.txt"
mkdir -p "$STATE/freeze"
dpkg -l > "$STATE/freeze/packages_dpkg.txt"
apt-mark showmanual > "$STATE/freeze/packages_manual.txt" || true
systemctl list-unit-files > "$STATE/freeze/services.txt"
ip addr > "$STATE/freeze/network.txt"
uname -a > "$STATE/freeze/kernel.txt"
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS > "$STATE/freeze/storage.txt"
tar czf "$STATE/freeze/etc_snapshot.tar.gz" /etc >/dev/null 2>&1 || true
HOLDS=(linux-image-686-pae firmware-realtek firmware-misc-nonfree firmware-linux-nonfree intel-microcode network-manager openssh-server xfce4-power-manager onboard)
for p in "${HOLDS[@]}"; do dpkg -s "$p" >/dev/null 2>&1 && apt-mark hold "$p" >> "$OUT" 2>&1 || true; done
echo 'freeze_done=yes' > "$STATE/freeze/state.txt"
