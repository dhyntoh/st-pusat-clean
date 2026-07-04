#!/bin/bash
source /etc/st-pusat/lib/colors.sh 2>/dev/null || NC='\033[0m'; GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'
XRAY_CONFIG="/etc/xray/config.json"; DB="/etc/shadowsocks/.shadowsocks.db"
read -p "Username: " user; read -p "Limit IP (0=unlimited): " limit_ip; read -p "Expiry (days): " exp_days
[[ -z "$user" || -z "$exp_days" ]] && { echo "Invalid input"; exit 1; }
grep -qw "^#@ $user" "$XRAY_CONFIG" && { echo -e "${RED}User exists${NC}"; exit 1; }
PASS=$(openssl rand -base64 16 | tr -dc 'a-zA-Z0-9'); EXP=$(date -d "+${exp_days} days" +"%Y-%m-%d")
CLIENT_BLOCK=",{\"method\":\"aes-128-gcm\",\"password\":\"${PASS}\",\"email\":\"${user}\"}"
sed -i "/\/\/ssws$/ { N; s/]\n/]${CLIENT_BLOCK//$'\n'/}\n/ }" "$XRAY_CONFIG"
sed -i "/\"email\": \"${user}\"/i\      #@ ${user} ${EXP}" "$XRAY_CONFIG"
echo "#@ ${user} ${EXP} ${PASS} ${limit_ip} $(date +%Y-%m-%d)" >> "$DB"
systemctl restart xray
DOMAIN=$(cat /etc/xray/domain)
echo -e "${GREEN}━━━━ SHADOWSOCKS USER CREATED ━━━━${NC}"
echo "Username : $user"; echo "Password : $PASS"; echo "Method   : aes-128-gcm"
echo "Domain   : $DOMAIN"; echo "Port     : 443"; echo "Path     : /ss-ws"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
