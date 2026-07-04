#!/bin/bash
# Delete VMess user
source /etc/st-pusat/lib/colors.sh 2>/dev/null || NC='\033[0m'; GREEN='\033[0;32m'; RED='\033[0;31m'

XRAY_CONFIG="/etc/xray/config.json"
DB="/etc/vmess/.vmess.db"

echo -e "${GREEN}Current VMess users:${NC}"
grep "^### " "$DB" 2>/dev/null || echo "(none)"
echo ""

read -p "Username to delete: " user
[[ -z "$user" ]] && exit 1

grep -qw "^### $user" "$XRAY_CONFIG" || { echo -e "${RED}User not found${NC}"; exit 1; }

# Remove from config
sed -i "/^### $user .*/,/},{/d" "$XRAY_CONFIG"

# Remove from DB
sed -i "/^### $user /d" "$DB"

# Remove IP limit
rm -f "/etc/kyt/limit/vmess/ip/$user"

systemctl restart xray
echo -e "${GREEN}User $user deleted${NC}"
