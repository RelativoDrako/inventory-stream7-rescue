#!/usr/bin/env bash
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"
log 'Linux general report'
OUT="$REPORTS/03_linux_general_executive_report.md"
ASSESS="$REPORTS/02_linux_general_assessment.txt"

BEST_ROLE="$(awk -F= '/BEST_ROLE/ {print $2}' "$ASSESS" 2>/dev/null || echo unknown)"
REC_OS="$(awk -F= '/RECOMMENDED_OS/ {print $2}' "$ASSESS" 2>/dev/null || echo unknown)"
STACK="$(awk -F= '/RECOMMENDED_STACK/ {print $2}' "$ASSESS" 2>/dev/null || echo unknown)"
SCORE="$(awk -F= '/OVERALL_SCORE/ {print $2}' "$ASSESS" 2>/dev/null || echo unknown)"
ARCH="$(awk -F= '/ARCH_FAMILY/ {print $2}' "$ASSESS" 2>/dev/null || echo unknown)"
BITS="$(awk -F= '/ARCH_BITS/ {print $2}' "$ASSESS" 2>/dev/null || echo unknown)"

cat > "$OUT" <<EOF
# LINUX GENERAL EXECUTIVE REPORT

## Device
- Name: $DEVICE_NAME
- OS: $OS_NAME
- Architecture: $ARCH / ${BITS}-bit

## Summary
- Best role: $BEST_ROLE
- Recommended OS path: $REC_OS
- Recommended stack: $STACK
- Overall score: $SCORE

## Base artifacts
- 01_linux_general_probe.txt
- 02_linux_general_assessment.txt
- 04_linux_general_recommendations.md
- 05_linux_general_operational_flow.md

## Reading rule
Review the recommendations and operational flow before applying optimization or migration actions.
EOF
echo "Report: $OUT"
