#!/bin/bash
source /etc/st-pusat/lib/colors.sh 2>/dev/null || NC='\033[0m'; GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'
XRAY_CONFIG="/etc/xray/config.json"; DB="/etc/trojan/.trojan.db"
read -p "Username: " user; read -p "Limit IP (0=unlimited): " limit_ip; read -p "Expiry (days): " exp_days
[[ -z "$user" || -z "$exp_days" ]] && { echo "Invalid input"; exit 1; }
grep -qw "^#! $user" "$XRAY_CONFIG" && { echo -e "${RED}User exists${NC}"; exit 1; }
PASS=$(openssl rand -base64 12 | tr -dc 'a-zA-Z0-9'); EXP=$(date -d "+${exp_days} days" +"%Y-%m-%d")
CLIENT_BLOCK=",{\"password\":\"${PASS}\",\"email\":\"${user}\"}"
sed -i "/\/\/trojanws$/ { N; s/]\n/]${CLIENT_BLOCK//$'\n'/}\n/ }" "$XRAY_CONFIG"
sed -i "/\"email\": \"${user}\"/i\      #! ${user} ${EXP}" "$XRAY_CONFIG"
echo "#! ${user} ${EXP} ${PASS} ${limit_ip} $(date +%Y-%m-%d)" >> "$DB"
[[ $limit_ip -gt 0 ]] && echo "$limit_ip" > "/etc/kyt/limit/trojan/ip/$user"
systemctl restart xray
DOMAIN=$(cat /etc/xray/domain)
echo -e "${GREEN}━━━━ TROJAN USER CREATED ━━━━${NC}"
echo "Username : $user"; echo "Password : $PASS"; echo "Domain   : $DOMAIN"; echo "Path     : /trojan-ws"
echo "Link     : trojan://${PASS}@${DOMAIN}:443?path=%2Ftrojan-ws&security=tls&host=${DOMAIN}&type=ws#${user}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
