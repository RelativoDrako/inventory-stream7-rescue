#!/usr/bin/env bash
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"
need_root
MODE="${1:-}"
log 'Update selectivo'
OUT="$REPORTS/04_update_selective.txt"
: > "$OUT"
apt-get update >> "$OUT" 2>&1 || true
apt list --upgradable 2>/dev/null | tee "$REPORTS/04_upgradable_list.txt" >/dev/null || true
SAFE_PKGS=(ca-certificates openssh-server openssh-client curl wget git network-manager wpasupplicant firefox-esr intel-microcode firmware-realtek firmware-misc-nonfree firmware-linux-nonfree tzdata)
{
  echo 'SAFE_PACKAGES='
  printf '%s
' "${SAFE_PKGS[@]}"
} >> "$OUT"
if [[ "$MODE" == '--apply' ]]; then
  apt-get install -y --only-upgrade "${SAFE_PKGS[@]}" >> "$OUT" 2>&1 || true
  echo '[apply] upgrade selectivo ejecutado' >> "$OUT"
else
  echo '[dry-run] no se aplicó upgrade; usar update --apply para aplicar' >> "$OUT"
fi
log 'Update selectivo completado'
