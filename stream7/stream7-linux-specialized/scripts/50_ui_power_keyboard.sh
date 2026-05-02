#!/usr/bin/env bash
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"
need_root
log 'UI, batería, energía y teclado en pantalla'
OUT="$REPORTS/06_ui_power_keyboard.txt"

# Power key behavior: short press suspend, long press remains hardware-controlled
cat > /etc/systemd/logind.conf <<'EOF'
[Login]
HandlePowerKey=suspend
HandleSuspendKey=suspend
HandleHibernateKey=ignore
HandleLidSwitch=ignore
EOF
systemctl restart systemd-logind >> "$OUT" 2>&1 || true

# LXDE autostart helpers
USER_HOME=$(getent passwd ${SUDO_USER:-$(logname 2>/dev/null || echo root)} | cut -d: -f6)
[ -n "$USER_HOME" ] || USER_HOME="/root"
mkdir -p "$USER_HOME/.config/autostart" "$USER_HOME/.config/lxpanel/LXDE/panels"
cat > "$USER_HOME/.config/autostart/xfce4-power-manager.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=XFCE4 Power Manager
Exec=xfce4-power-manager
X-GNOME-Autostart-enabled=true
EOF
cat > "$USER_HOME/.config/autostart/nm-applet.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=NetworkManager Applet
Exec=nm-applet
X-GNOME-Autostart-enabled=true
EOF
cat > "$USER_HOME/.config/autostart/onboard.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Onboard
Exec=onboard --not-show-in=GNOME --xid
X-GNOME-Autostart-enabled=true
EOF
chown -R ${SUDO_USER:-root}:${SUDO_USER:-root} "$USER_HOME/.config" || true

# Panel lateral izquierdo if panel file exists or create minimal guidance file
PANEL="$USER_HOME/.config/lxpanel/LXDE/panels/panel"
if [ ! -f "$PANEL" ]; then
cat > "$PANEL" <<'EOF'
Global {
  edge=left
  allign=left
  margin=0
  widthtype=percent
  width=12
  height=32
  transparent=0
  tintcolor=#000000
  alpha=0
  autohide=0
}
EOF
else
  sed -i 's/^edge=.*/edge=left/' "$PANEL" || true
  sed -i 's/^width=.*/width=12/' "$PANEL" || true
fi
chown -R ${SUDO_USER:-root}:${SUDO_USER:-root} "$USER_HOME/.config/lxpanel" || true

cat > "$REPORTS/06_wifi_cli_usage.txt" <<'EOF'
Si el cuadro gráfico de LXDE corta la contraseña WiFi:

nmcli dev wifi list
nmcli dev wifi connect "SSID" password "CONTRASEÑA"
EOF

{
  echo 'Power policy set to suspend on short press'
  echo 'Onboard enabled in autostart'
  echo 'XFCE4 power manager enabled in autostart'
  echo 'NetworkManager applet enabled in autostart'
  echo 'Panel set to left side (or seeded)'
} > "$OUT"
log 'UI/energía/teclado completados'
