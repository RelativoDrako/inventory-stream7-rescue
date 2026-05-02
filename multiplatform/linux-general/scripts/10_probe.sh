#!/usr/bin/env bash
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"
log 'Linux general probe'
OUT="$REPORTS/01_linux_general_probe.txt"
IFS='|' read -r ARCH_FAMILY ARCH_BITS ARCH_RAW <<< "$(detect_arch_family)"
CPU_MODEL="$(lscpu 2>/dev/null | awk -F: '/Model name/ {gsub(/^[ 	]+/,"",$2); print $2; exit}')"
if [ -z "${CPU_MODEL:-}" ]; then CPU_MODEL="$(awk -F: '/model name/ {gsub(/^[ 	]+/,"",$2); print $2; exit}' /proc/cpuinfo 2>/dev/null || echo unknown)"; fi

{
  echo '=== LINUX GENERAL PROBE ==='
  echo "DEVICE_NAME=$DEVICE_NAME"
  echo "OS_NAME=$OS_NAME"
  echo "ARCH_FAMILY=$ARCH_FAMILY"
  echo "ARCH_BITS=$ARCH_BITS"
  echo "ARCH_RAW=$ARCH_RAW"
  echo '=== OS ==='; cat /etc/os-release 2>/dev/null || true
  echo '=== KERNEL ==='; uname -a
  echo '=== CPU ==='; lscpu 2>/dev/null || cat /proc/cpuinfo
  echo '=== CPU MODEL ==='; echo "$CPU_MODEL"
  echo '=== MEMORY ==='; free -h
  echo '=== STORAGE ==='; lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS,MODEL
  echo '=== PCI ==='; command_or_na lspci lspci -nnk || true
  echo '=== USB ==='; command_or_na lsusb lsusb || true
  echo '=== NETWORK ==='; ip addr || true; ip route || true
  echo '=== GPU/DRM ==='; dmesg 2>/dev/null | grep -iE 'i915|nouveau|amdgpu|radeon|nvidia|vc4|panfrost|mali' || true
  echo '=== FIRMWARE ==='; dmesg 2>/dev/null | grep -i firmware || true
  echo '=== SERVICES ==='; systemctl list-unit-files 2>/dev/null | grep -E 'ssh|NetworkManager|systemd-networkd|docker|podman|libvirtd' || true
  echo '=== PACKAGE MANAGERS ==='
  for pm in apt dnf yum pacman zypper apk snap flatpak; do
    command -v "$pm" >/dev/null 2>&1 && echo "$pm=present" || echo "$pm=absent"
  done
} > "$OUT"
echo "Report: $OUT"
