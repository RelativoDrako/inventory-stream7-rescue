#!/usr/bin/env bash
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"
need_root
log 'Generando reportes ejecutivos'
EXEC="$REPORTS/10_DEVICE_EXECUTIVE_REPORT.md"
STATE_R="$REPORTS/11_DEVICE_STATE_REPORT.md"
CPU="$(lscpu 2>/dev/null | awk -F: '/Model name/ {gsub(/^[ 	]+/,"",$2); print $2; exit}')"
RAM="$(free -h | awk '/Mem:/ {print $2}')"
AVAIL="$(free -h | awk '/Mem:/ {print $7}')"
IPADDR="$(hostname -I 2>/dev/null | awk '{print $1}')"
BATCAP="$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n1 || true)"
BATSTAT="$(cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -n1 || true)"
cat > "$EXEC" <<EOF
# DEVICE EXECUTIVE REPORT

## Resumen ejecutivo

- Dispositivo: HP Stream 7
- Sistema operativo: $(. /etc/os-release && echo "$PRETTY_NAME")
- Kernel: $(uname -r)
- Arquitectura: $(uname -m)
- CPU: $CPU
- RAM total: $RAM
- RAM disponible actual: $AVAIL
- IP actual: ${IPADDR:-desconocida}
- Batería: ${BATCAP:-no visible}% / ${BATSTAT:-no visible}

## Estado operativo estimado

El dispositivo es apto para:
- thin client
- navegación ligera
- terminal de soporte
- escritorio remoto
- monitoreo y utilidades operativas
- ofimática ligera

No es apto para:
- cargas pesadas locales
- virtualización local relevante
- IA/ML local

## Mejor uso del hardware

- Debian 12 i386 + LXDE
- SSH + navegador + mpv + ofimática ligera + monitoreo
- headless opcional por SSH
EOF

cat > "$STATE_R" <<EOF
# DEVICE STATE REPORT

## Red

\`nmcli device status\`

\`\`\`
$(nmcli device status 2>/dev/null || true)
\`\`\`

## Batería

\`\`\`
$(ls /sys/class/power_supply 2>/dev/null || true)
BAT_CAPACITY=${BATCAP:-no visible}
BAT_STATUS=${BATSTAT:-no visible}
\`\`\`

## Servicios críticos

\`\`\`
$(systemctl is-enabled ssh 2>/dev/null || true)
$(systemctl is-enabled NetworkManager 2>/dev/null || true)
$(systemctl is-enabled tlp 2>/dev/null || true)
$(systemctl is-enabled acpid 2>/dev/null || true)
\`\`\`

## Power key

\`\`\`
$(grep -n 'HandlePowerKey\|HandleSuspendKey' /etc/systemd/logind.conf 2>/dev/null || true)
\`\`\`

## Freeze

\`\`\`
$(cat "$STATE/freeze/state.txt" 2>/dev/null || echo 'freeze_done=no')
\`\`\`
EOF
