#!/bin/bash
# Bandwidth monitoring
NC='\033[0m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'
echo -e "${CYAN}━━━━ BANDWIDTH USAGE ━━━━${NC}"
vnstat -m 2>/dev/null || echo "vnstat not ready (collecting data...)"
