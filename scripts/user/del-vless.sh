#!/bin/bash
source /etc/st-pusat/lib/colors.sh 2>/dev/null || NC='\033[0m'; RED='\033[0;31m'; GREEN='\033[0;32m'
echo -e "${GREEN}Current VLESS:${NC}"; grep "^#& " /etc/vless/.vless.db 2>/dev/null || echo "(none)"
read -p "Username: " user; [[ -z "$user" ]] && exit 1
sed -i "/^#& $user .*/,/},{/d" /etc/xray/config.json; sed -i "/^#& $user /d" /etc/vless/.vless.db
rm -f "/etc/kyt/limit/vless/ip/$user"; systemctl restart xray; echo -e "${GREEN}Deleted${NC}"
