#!/bin/bash
source /etc/st-pusat/lib/colors.sh 2>/dev/null || NC='\033[0m'; GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'
XRAY_CONFIG="/etc/xray/config.json"; DB="/etc/vless/.vless.db"
read -p "Username: " user; read -p "Limit IP (0=unlimited): " limit_ip; read -p "Expiry (days): " exp_days
[[ -z "$user" || -z "$exp_days" ]] && { echo "Invalid input"; exit 1; }
grep -qw "^#& $user" "$XRAY_CONFIG" && { echo -e "${RED}User exists${NC}"; exit 1; }
UUID=$(cat /proc/sys/kernel/random/uuid 2>/dev/null || uuidgen); EXP=$(date -d "+${exp_days} days" +"%Y-%m-%d")
CLIENT_BLOCK=",{\"id\":\"${UUID}\",\"email\":\"${user}\",\"flow\":\"\"}"
sed -i "/\/\/vless$/ { N; s/]\n/]${CLIENT_BLOCK//$'\n'/}\n/ }" "$XRAY_CONFIG"
sed -i "/\"email\": \"${user}\"/i\      #& ${user} ${EXP}" "$XRAY_CONFIG"
echo "#& ${user} ${EXP} ${UUID} ${limit_ip} $(date +%Y-%m-%d)" >> "$DB"
[[ $limit_ip -gt 0 ]] && echo "$limit_ip" > "/etc/kyt/limit/vless/ip/$user"
systemctl restart xray
DOMAIN=$(cat /etc/xray/domain)
LINK="vless://${UUID}@${DOMAIN}:443?type=ws&path=%2Fvless&security=tls&sni=${DOMAIN}&host=${DOMAIN}&encryption=none#${user}"
echo -e "${GREEN}━━━━ VLESS USER CREATED ━━━━${NC}"; echo "Username : $user"; echo "UUID     : $UUID"; echo "Expiry   : $EXP"; echo "Link     : $LINK"; echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
