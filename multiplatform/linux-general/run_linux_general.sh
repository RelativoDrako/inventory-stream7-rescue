#!/usr/bin/env bash
set -euo pipefail
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODE="${1:-menu}"
run(){ bash "$BASE_DIR/scripts/$1" ${2:-}; }

help_msg(){ cat <<'EOF'
LINUX GENERAL TOOLKIT

Hint:
- Run inventory first.
- Use `help` before `full` if this is your first pass.
- Reports are written under output/<device>/<os>/reports/.

Modes:
  probe    inventory HW/SW + architecture
  assess   role / OS / stack / optimization assessment
  report   executive report
  flow     operational flow + optimization hints
  full     probe + assess + report + flow
  help     show help
EOF
}

menu(){
  while true; do
    clear
    echo '===== LINUX GENERAL MENU ====='
    echo 'Hint: start with 1) Probe, then 2) Assess, then 3) Report.'
    echo 'Hint: use 5) Help if this is the first run.'
    echo '1) Probe'
    echo '2) Assess'
    echo '3) Report'
    echo '4) Flow / optimization hints'
    echo '5) Help'
    echo '6) Full'
    echo '0) Exit'
    read -r -p 'Option: ' o
    case "$o" in
      1) run 10_probe.sh; read -r -p 'Enter...' _ ;;
      2) run 20_assess.sh; read -r -p 'Enter...' _ ;;
      3) run 30_report.sh; read -r -p 'Enter...' _ ;;
      4) run 40_operational_flow.sh; read -r -p 'Enter...' _ ;;
      5) help_msg; read -r -p 'Enter...' _ ;;
      6) run 10_probe.sh; run 20_assess.sh; run 30_report.sh; run 40_operational_flow.sh; read -r -p 'Enter...' _ ;;
      0) exit 0 ;;
      *) echo 'Invalid option'; sleep 1 ;;
    esac
  done
}

case "$MODE" in
  menu) menu ;;
  probe) run 10_probe.sh ;;
  assess) run 20_assess.sh ;;
  report) run 30_report.sh ;;
  flow) run 40_operational_flow.sh ;;
  full) run 10_probe.sh; run 20_assess.sh; run 30_report.sh; run 40_operational_flow.sh ;;
  help|-h|--help) help_msg ;;
  *) help_msg; exit 1 ;;
esac
