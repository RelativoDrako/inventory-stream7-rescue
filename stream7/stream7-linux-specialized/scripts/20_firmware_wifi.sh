#!/usr/bin/env bash
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"
need_root
log 'Firmware y WiFi Stream7'
OUT="$REPORTS/03_stream7_firmware_wifi.txt"
FW_DIR="$BASE_DIR/firmware"

install_if_needed() {
  local pkgfile="$1"
  [ -f "$pkgfile" ] || return 0
  local name arch
  name="$(dpkg-deb -f "$pkgfile" Package)"
  arch="$(dpkg-deb -f "$pkgfile" Architecture)"
  if [[ "$name" == intel-microcode && "$arch" == amd64 ]]; then
    echo "[skip] $pkgfile no aplica a i386" >> "$OUT"
    return 0
  fi
  if dpkg -s "$name" >/dev/null 2>&1; then
    echo "[skip] $name ya instalado" >> "$OUT"
  else
    echo "[install] $pkgfile" >> "$OUT"
    dpkg -i "$pkgfile" >> "$OUT" 2>&1 || true
  fi
}

: > "$OUT"
for f in   "$FW_DIR/firmware-realtek_20230210-5_all.deb"   "$FW_DIR/firmware-misc-nonfree_20230210-5_all.deb"   "$FW_DIR/firmware-linux-nonfree_20230210-5_all.deb"   "$FW_DIR/intel-microcode_3.20251111.1~deb12u1_i386.deb"   "$FW_DIR/intel-microcode_3.20251111.1~deb12u1_amd64.deb"
do
  install_if_needed "$f"
done

apt-get install -f -y >> "$OUT" 2>&1 || true
mkdir -p /etc/modprobe.d /etc/NetworkManager/conf.d
cat > /etc/modprobe.d/8723bs.conf <<'EOF'
options r8723bs fwlps=0
EOF
cat > /etc/NetworkManager/conf.d/99-wifi-powersave-off.conf <<'EOF'
[connection]
wifi.powersave = 2
EOF
# ensure NetworkManager manages wlan0
if [ -f /etc/network/interfaces ]; then
  cp /etc/network/interfaces "$STATE/interfaces.before_nm" || true
  cat > /etc/network/interfaces <<'EOF'
auto lo
iface lo inet loopback
EOF
fi
modprobe -r r8723bs 2>/dev/null || true
modprobe r8723bs >> "$OUT" 2>&1 || true
systemctl enable NetworkManager >> "$OUT" 2>&1 || true
systemctl restart NetworkManager >> "$OUT" 2>&1 || true
{
  echo '=== POST ==='
  lsmod | grep r8723bs || true
  nmcli device status || true
  nmcli dev wifi list || true
} >> "$OUT"
log 'Firmware/WiFi procesado'
