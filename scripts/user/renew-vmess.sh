#!/bin/bash
source /etc/st-pusat/lib/colors.sh 2>/dev/null || NC='\033[0m'; GREEN='\033[0;32m'; RED='\033[0;31m'
DB="/etc/vmess/.vmess.db"
XRAY_CONFIG="/etc/xray/config.json"
echo -e "${GREEN}Current VMess users:${NC}"; grep "^### " "$DB" 2>/dev/null || echo "(none)"
read -p "Username: " user
read -p "Add days: " days
[[ -z "$user" || -z "$days" ]] && { echo "Invalid"; exit 1; }
grep -qw "^### $user" "$XRAY_CONFIG" || { echo -e "${RED}Not found${NC}"; exit 1; }
OLD_EXP=$(grep "^### $user " "$DB" | cut -d' ' -f3)
NEW_EXP=$(date -d "$OLD_EXP +${days} days" +"%Y-%m-%d")
sed -i "s/^### $user $OLD_EXP/### $user $NEW_EXP/" "$DB"
sed -i "s/^### $user $OLD_EXP/### $user $NEW_EXP/" "$XRAY_CONFIG"
echo -e "${GREEN}Renewed: $OLD_EXP -> $NEW_EXP${NC}"
