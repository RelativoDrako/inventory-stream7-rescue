#!/usr/bin/env bash
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"
log 'Linux general operational flow'
OUT="$REPORTS/05_linux_general_operational_flow.md"
cat > "$OUT" <<EOF
# Linux General Operational Flow

1. Run \`probe\`
2. Run \`assess\`
3. Run \`report\`
4. Review \`04_linux_general_recommendations.md\`
5. Only then decide:
   - keep current OS
   - optimize current OS
   - migrate to lighter Linux
   - repurpose as remote / kiosk / edge node

## Optimization rule
Prefer:
- browser/desktop reduction
- startup/service cleanup
- cache control
- remote-first workflows on constrained systems

## Warning
This toolkit supports recommendation framing. It should not be treated as a blind migration tool.
EOF
echo "Report: $OUT"
