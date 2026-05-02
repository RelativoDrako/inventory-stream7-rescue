#!/usr/bin/env bash
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"
need_root
log 'Optimización operativa Stream7'
OUT="$REPORTS/05_optimize.txt"
append_once 'vm.swappiness=10' /etc/sysctl.conf
append_once 'vm.vfs_cache_pressure=150' /etc/sysctl.conf
append_once 'tmpfs /tmp tmpfs defaults,noatime,mode=1777 0 0' /etc/fstab
apt-get update >> "$OUT" 2>&1 || true
apt-get install -y htop curl wget git python3 python3-pip python3-venv sqlite3 jq rsync mosquitto-clients glances abiword gnumeric tlp powertop acpi acpid openssh-server firefox-esr mpv network-manager rfkill pavucontrol upower xfce4-power-manager onboard xdotool >> "$OUT" 2>&1 || true
systemctl enable ssh acpid tlp NetworkManager systemd-timesyncd >> "$OUT" 2>&1 || true
for svc in cups cups-browsed avahi-daemon ModemManager NetworkManager-wait-online; do systemctl disable --now "$svc" >> "$OUT" 2>&1 || true; done
systemctl restart ssh acpid tlp NetworkManager systemd-timesyncd >> "$OUT" 2>&1 || true
log 'Optimización completada'
