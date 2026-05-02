#!/usr/bin/env bash
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"
need_root
OUT="$REPORTS/12_STATUS_SUMMARY.txt"
{
  echo '=== STREAM7 STATUS SUMMARY ==='
  date
  echo '-- IP --'; hostname -I 2>/dev/null || true
  echo '-- NetworkManager --'; nmcli device status || true
  echo '-- Battery --'; for f in /sys/class/power_supply/BAT*/capacity /sys/class/power_supply/BAT*/status; do [ -f "$f" ] && echo "$f: $(cat "$f")"; done
  echo '-- SSH --'; systemctl is-active ssh || true
  echo '-- Power key --'; grep -n 'HandlePowerKey' /etc/systemd/logind.conf || true
  echo '-- Freeze --'; cat "$STATE/freeze/state.txt" 2>/dev/null || echo 'freeze_done=no'
} | tee "$OUT"
