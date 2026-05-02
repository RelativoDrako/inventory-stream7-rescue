#!/usr/bin/env bash
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"
log 'Linux general assess'
OUT="$REPORTS/02_linux_general_assessment.txt"
REC="$REPORTS/04_linux_general_recommendations.md"

IFS='|' read -r ARCH_FAMILY ARCH_BITS ARCH_RAW <<< "$(detect_arch_family)"
CPU="$(lscpu 2>/dev/null | awk -F: '/Model name/ {gsub(/^[ 	]+/,"",$2); print $2; exit}')"
RAMGB="$(free -g | awk '/Mem:/ {print $2}')"
ROOT_SRC="$(findmnt -n -o SOURCE / 2>/dev/null || true)"
ROOT_DISK="$(echo "${ROOT_SRC:-}" | sed 's/[0-9]*$//; s/p[0-9]*$//')"
DISKGB="$(lsblk -bdno SIZE "$ROOT_DISK" 2>/dev/null | head -n1 | awk '{printf "%.0f", $1/1024/1024/1024}')"
GPUV='Unknown'
if command -v lspci >/dev/null 2>&1; then
  if lspci | grep -qi nvidia; then GPUV='NVIDIA'; elif lspci | grep -qi 'vga.*intel'; then GPUV='Intel'; elif lspci | grep -Eqi 'amd|radeon'; then GPUV='AMD'; elif lspci | grep -Eqi 'mali|broadcom|vc4|mediatek|qualcomm'; then GPUV='ARM_SOC'; fi
fi

ROLE='general_endpoint'
REC_OS='keep_current_or_ubuntu_lts'
STACK='ssh,browser,office,monitoring'
OVERALL=52
NOTES=()

case "$ARCH_FAMILY" in
  x86_32)
    ROLE='legacy_light_ops'
    REC_OS='debian_lxde_or_antiX'
    STACK='ssh,browser_light,terminal,monitoring'
    OVERALL=34
    NOTES+=('32-bit x86 detected: prioritize lightweight roles and avoid heavy modern desktop expectations.')
    ;;
  armhf)
    ROLE='edge_or_kiosk_light'
    REC_OS='debian_armhf_or_vendor_supported_lightweight_linux'
    STACK='ssh,browser_light,mqtt,monitoring,kiosk_optional'
    OVERALL=42
    NOTES+=('ARMHF detected: validate package availability and graphics support before committing to desktop-heavy use.')
    ;;
  arm64)
    ROLE='edge_remote_ops_or_light_desktop'
    REC_OS='ubuntu_lts_arm64_or_debian_arm64'
    STACK='ssh,browser,monitoring,python,mqtt'
    OVERALL=56
    NOTES+=('ARM64 detected: good fit for edge, remote operations, and lightweight modern Linux roles if driver support is acceptable.')
    ;;
esac

if [ "${RAMGB:-0}" -lt 4 ]; then
  ROLE='thin_client_light_ops'
  REC_OS='debian_lxde_or_xfce_light'
  STACK='ssh,rdp,browser_light,mqtt,monitoring'
  OVERALL=$((OVERALL-8))
  NOTES+=('RAM under 4 GB: prefer remote-first operation and reduce background services.')
elif [ "${RAMGB:-0}" -ge 16 ] && [ "$GPUV" = 'NVIDIA' ]; then
  ROLE='developer_workstation_or_ml_edge_control'
  REC_OS='ubuntu_lts_or_supported_workstation_linux'
  STACK='docker,python,vscode,browser,monitoring'
  OVERALL=$((OVERALL+18))
  NOTES+=('NVIDIA + 16 GB RAM or more: candidate for heavier development or remote-control workloads.')
fi

if [ "${DISKGB:-0}" -lt 64 ]; then
  NOTES+=('Disk capacity is limited: keep caches controlled and evaluate whether local-first storage is realistic.')
  OVERALL=$((OVERALL-4))
fi

{
  echo "CPU=$CPU"
  echo "RAMGB=${RAMGB:-unknown}"
  echo "DISKGB=${DISKGB:-unknown}"
  echo "GPU_VENDOR=$GPUV"
  echo "ARCH_FAMILY=$ARCH_FAMILY"
  echo "ARCH_BITS=$ARCH_BITS"
  echo "ARCH_RAW=$ARCH_RAW"
  echo "BEST_ROLE=$ROLE"
  echo "RECOMMENDED_OS=$REC_OS"
  echo "RECOMMENDED_STACK=$STACK"
  echo "OVERALL_SCORE=$OVERALL"
} > "$OUT"

{
  echo "# Linux General Recommendations"
  echo
  echo "- Device: \`$DEVICE_NAME\`"
  echo "- OS: \`$OS_NAME\`"
  echo "- Architecture: \`$ARCH_FAMILY / $ARCH_BITS-bit / $ARCH_RAW\`"
  echo "- Best role: \`$ROLE\`"
  echo "- Recommended OS path: \`$REC_OS\`"
  echo "- Recommended stack: \`$STACK\`"
  echo "- Overall score: \`$OVERALL\`"
  echo
  echo "## Optimization priorities"
  idx=1
  for note in "${NOTES[@]}"; do
    echo "$idx. $note"
    idx=$((idx+1))
  done
  if [ "${#NOTES[@]}" -eq 0 ]; then
    echo "1. No special optimization warning was generated."
  fi
  echo
  echo "## Next step"
  echo "Run \`report\` and \`flow\`, review outputs, and only then apply invasive changes."
} > "$REC"

echo "Assessment: $OUT"
echo "Recommendations: $REC"
