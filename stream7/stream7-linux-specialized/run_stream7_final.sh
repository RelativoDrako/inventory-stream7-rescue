#!/usr/bin/env bash
set -euo pipefail
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODE="${1:-menu}"
APPLY="${2:-}"

help_msg() {
cat <<'EOF'
STREAM7 FINAL TOOLKIT

Hint:
- Start with inventory first.
- Use `help` before `full` if this is the first run.
- Generate reports before applying firmware/update/optimization.
- Output paths live under stream7/stream7-linux-specialized/output/<device>/<os>/.

Usage:
  sudo bash ./run_stream7_final.sh [mode] [--apply]

Modes:
  menu       interactive menu
  probe      detailed hardware/software inventory
  firmware   offline firmware review + WiFi handling
  update     apt update + report + optional selective upgrade
  optimize   operational optimization
  ui         battery / panel / keyboard / applets
  headless   enable SSH and move to multi-user.target
  gui        return to graphical.target
  freeze     temporary baseline freeze
  unfreeze   revert baseline holds
  reports    executive + technical reports
  status     summarized status
  full       probe + firmware + update + optimize + ui + reports + status

With `update --apply` the selective upgrade path is explicitly applied.
EOF
}

run(){ bash "$BASE_DIR/scripts/$1" ${2:-}; }

menu() {
while true; do
  clear
  echo '===== STREAM7 FINAL MENU ====='
  echo 'Hint: 1) Probe -> 10) Reports -> 11) Status before optimization.'
  echo 'Hint: press 13) Help if this is the first execution.'
  echo '1) Inventario detallado'
  echo '2) Firmware / WiFi'
  echo '3) Update selectivo (solo reporte)'
  echo '4) Update selectivo (aplicar)'
  echo '5) Optimización operativa'
  echo '6) UI / batería / teclado en pantalla / panel'
  echo '7) Headless'
  echo '8) Freeze temporal'
  echo '9) Unfreeze'
  echo '10) Generar reportes'
  echo '11) Estado actual'
  echo '12) Ejecutar TODO'
  echo '13) Ayuda'
  echo '0) Salir'
  read -r -p 'Opción: ' opt
  case "$opt" in
    1) run 10_probe.sh; read -r -p 'Enter...' _ ;;
    2) run 20_firmware_wifi.sh; read -r -p 'Enter...' _ ;;
    3) run 30_update_selective.sh; read -r -p 'Enter...' _ ;;
    4) run 30_update_selective.sh --apply; read -r -p 'Enter...' _ ;;
    5) run 40_optimize.sh; read -r -p 'Enter...' _ ;;
    6) run 50_ui_power_keyboard.sh; read -r -p 'Enter...' _ ;;
    7) run 60_headless.sh; read -r -p 'Enter...' _ ;;
    8) run 70_freeze.sh; read -r -p 'Enter...' _ ;;
    9) run 80_unfreeze.sh; read -r -p 'Enter...' _ ;;
    10) run 90_reports.sh; read -r -p 'Enter...' _ ;;
    11) run 95_status.sh; read -r -p 'Enter...' _ ;;
    12) run 10_probe.sh; run 20_firmware_wifi.sh; run 30_update_selective.sh; run 40_optimize.sh; run 50_ui_power_keyboard.sh; run 90_reports.sh; run 95_status.sh; read -r -p 'Enter...' _ ;;
    13) help_msg; read -r -p 'Enter...' _ ;;
    0) exit 0 ;;
    *) echo 'Opción inválida'; sleep 1 ;;
  esac
done
}

case "$MODE" in
  menu) menu ;;
  probe) run 10_probe.sh ;;
  firmware) run 20_firmware_wifi.sh ;;
  update) run 30_update_selective.sh "$APPLY" ;;
  optimize) run 40_optimize.sh ;;
  ui) run 50_ui_power_keyboard.sh ;;
  headless) run 60_headless.sh ;;
  gui) run 61_gui_target.sh ;;
  freeze) run 70_freeze.sh ;;
  unfreeze) run 80_unfreeze.sh ;;
  reports) run 90_reports.sh ;;
  status) run 95_status.sh ;;
  full) run 10_probe.sh; run 20_firmware_wifi.sh; run 30_update_selective.sh "$APPLY"; run 40_optimize.sh; run 50_ui_power_keyboard.sh; run 90_reports.sh; run 95_status.sh ;;
  help|-h|--help) help_msg ;;
  *) echo 'Modo no reconocido'; help_msg; exit 1 ;;
esac
