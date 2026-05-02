#!/usr/bin/env bash
set -euo pipefail
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEVICE_NAME="stream7"
OS_NAME="$(. /etc/os-release 2>/dev/null && echo "${ID}${VERSION_ID:-}" || echo linux)"
OUT_BASE="$BASE_DIR/output/$DEVICE_NAME/$OS_NAME"
REPORTS="$OUT_BASE/reports"
LOGS="$OUT_BASE/logs"
STATE="$OUT_BASE/state"
mkdir -p "$REPORTS" "$LOGS" "$STATE"
log(){ echo "[$(date '+%F %T')] $*" | tee -a "$LOGS/toolkit.log"; }
need_root(){ [[ "$(id -u)" -eq 0 ]] || { echo 'Ejecuta como root'; exit 1; }; }
pkg_installed(){ dpkg -s "$1" >/dev/null 2>&1; }
append_once(){ local line="$1" file="$2"; touch "$file"; grep -Fqx "$line" "$file" || echo "$line" >> "$file"; }
write_kv(){ printf '%s=%s
' "$1" "$2"; }
