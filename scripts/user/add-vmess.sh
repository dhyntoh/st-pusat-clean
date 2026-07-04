#!/bin/bash
# Add VMess user
source /etc/st-pusat/lib/colors.sh 2>/dev/null || NC='\033[0m'; GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'

XRAY_CONFIG="/etc/xray/config.json"
DB="/etc/vmess/.vmess.db"

read -p "Username: " user
read -p "Quota (GB, 0=unlimited): " quota
read -p "Limit IP (0=unlimited): " limit_ip
read -p "Expiry (days): " exp_days

[[ -z "$user" || -z "$exp_days" ]] && { echo "Invalid input"; exit 1; }

# Check existing
grep -qw "^### $user" "$XRAY_CONFIG" && { echo -e "${RED}User exists${NC}"; exit 1; }

UUID=$(cat /proc/sys/kernel/random/uuid 2>/dev/null || uuidgen 2>/dev/null || python3 -c "import uuid; print(uuid.uuid4())")
EXP=$(date -d "+${exp_days} days" +"%Y-%m-%d")
EXP_SEC=$(date -d "$EXP" +%s)

# Add to config
CLIENT_BLOCK=$(cat << EOF
      ,{
        "id": "${UUID}",
        "alterId": 0,
        "email": "${user}",
        "security": "auto"
      }
EOF
)

# Find vmess inbound (port 10002)
sed -i "/\/\/vmess$/ { N; N; s/]\n        }/]\n        }${CLIENT_BLOCK//$'\n'/\\n}/ }" "$XRAY_CONFIG"

# Add marker
sed -i "/\"email\": \"${user}\"/i\      ### ${user} ${EXP}" "$XRAY_CONFIG"

# Save to DB
echo "### ${user} ${EXP} ${UUID} ${quota} ${limit_ip} $(date +%Y-%m-%d)" >> "$DB"

# Set limit
[[ $limit_ip -gt 0 ]] && echo "$limit_ip" > "/etc/kyt/limit/vmess/ip/$user"

systemctl restart xray

DOMAIN=$(cat /etc/xray/domain)
LINK="vmess://$(echo -n "{\"add\":\"${DOMAIN}\",\"aid\":\"0\",\"host\":\"${DOMAIN}\",\"id\":\"${UUID}\",\"net\":\"ws\",\"path\":\"/vmess\",\"port\":\"443\",\"ps\":\"${user}\",\"scy\":\"auto\",\"sni\":\"${DOMAIN}\",\"tls\":\"tls\",\"type\":\"\",\"v\":\"2\"}" | base64 -w0)"

echo -e "${GREEN}━━━━ VMESS USER CREATED ━━━━${NC}"
echo "Username : $user"
echo "UUID     : $UUID"
echo "Domain   : $DOMAIN"
echo "Port     : 443"
echo "Path     : /vmess"
echo "TLS      : Yes"
echo "Expiry   : $EXP"
echo "Link     : $LINK"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
