#!/usr/bin/env bash
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"
need_root
log 'Inventario Stream7 V6'
OUT="$REPORTS/01_stream7_full_inventory.txt"
{
  echo '========================================'
  echo 'FULL DEVICE INVENTORY - HP STREAM 7'
  echo '========================================'
  echo '=== OS ==='; cat /etc/os-release 2>/dev/null || true
  echo '=== KERNEL ==='; uname -a
  echo '=== ARCH ==='; uname -m
  echo '=== CPU ==='; lscpu 2>/dev/null || cat /proc/cpuinfo
  echo '=== RAM ==='; free -h
  echo '=== STORAGE ==='; lsblk -o NAME,MAJ:MIN,RM,SIZE,RO,TYPE,FSTYPE,MOUNTPOINTS,MODEL
  echo '=== FILESYSTEM USAGE ==='; df -hT
  echo '=== PCI DEVICES (WITH DRIVERS) ==='; lspci -nnk 2>/dev/null || true
  echo '=== USB DEVICES ==='; lsusb 2>/dev/null || true
  echo '=== NETWORK ==='; ip addr; echo; ip route || true
  echo '=== WIFI / BT / SDIO ==='; dmesg | grep -iE 'rtl|8723|wifi|bluetooth|mmc0:0001|goodix|axp288|battery|rt5640|intel_sst' || true
  echo '=== BATTERY / POWER ==='; ls /sys/class/power_supply 2>/dev/null || true; for f in /sys/class/power_supply/BAT*/capacity /sys/class/power_supply/BAT*/status /sys/class/power_supply/BAT*/voltage_now; do [ -f "$f" ] && echo "$f: $(cat "$f")"; done
  echo '=== SERVICES (subset) ==='; systemctl list-unit-files | grep -E 'ssh|NetworkManager|bluetooth|acpid|tlp|lightdm|systemd-logind' || true
  echo '=== RFKILL ==='; rfkill list || true
  echo '=== INSTALLED KEY PACKAGES ==='; dpkg -l | grep -E 'firmware-|intel-microcode|openssh-server|firefox-esr|mpv|abiword|gnumeric|mosquitto-clients|glances|powertop|tlp|upower|xfce4-power-manager|onboard|matchbox-keyboard' || true
} > "$OUT"

DEC="$REPORTS/02_stream7_decision_summary.txt"
{
  write_kv device_name stream7
  write_kv best_role thin_client_daily_ops_support_terminal
  write_kv recommended_os debian12_i386_lxde
  write_kv recommended_stack 'ssh,firefox-esr,mpv,abiword,gnumeric,mosquitto-clients,python3,git,onboard'
  write_kv potential_limitations '1GB RAM,eMMC limitado,CPU Atom'
} > "$DEC"
log 'Inventario generado'
