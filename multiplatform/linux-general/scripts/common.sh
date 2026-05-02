#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEVICE_NAME="$(cat /sys/class/dmi/id/product_name 2>/dev/null | tr ' ' '_' | tr '[:upper:]' '[:lower:]' || uname -n | tr '[:upper:]' '[:lower:]')"
OS_NAME="$(. /etc/os-release 2>/dev/null && echo "${ID}${VERSION_ID:-}" || echo linux)"
OUT_BASE="$BASE_DIR/output/$DEVICE_NAME/$OS_NAME"
REPORTS="$OUT_BASE/reports"
LOGS="$OUT_BASE/logs"
mkdir -p "$REPORTS" "$LOGS"

log(){ echo "[$(date '+%F %T')] $*" | tee -a "$LOGS/toolkit.log"; }

detect_arch_family() {
  local raw machine bits
  raw="$(uname -m 2>/dev/null || echo unknown)"
  bits="$(getconf LONG_BIT 2>/dev/null || echo unknown)"
  case "$raw" in
    x86_64|amd64) echo "x86_64|$bits|$raw" ;;
    i386|i486|i586|i686) echo "x86_32|$bits|$raw" ;;
    armv7*|armv6*|armhf) echo "armhf|$bits|$raw" ;;
    aarch64|arm64) echo "arm64|$bits|$raw" ;;
    *) echo "unknown|$bits|$raw" ;;
  esac
}

command_or_na() {
  if command -v "$1" >/dev/null 2>&1; then
    shift
    "$@"
  else
    echo "N/A"
  fi
}
