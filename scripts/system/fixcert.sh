#!/bin/bash
source /etc/st-pusat/lib/colors.sh 2>/dev/null || NC='\033[0m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'
DOMAIN=$(cat /etc/xray/domain 2>/dev/null || cat /root/domain 2>/dev/null)
[[ -z "$DOMAIN" || "$DOMAIN" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] && { echo -e "${RED}No domain configured${NC}"; exit 1; }
if [[ -f ~/.acme.sh/acme.sh ]]; then
    ~/.acme.sh/acme.sh --renew -d "$DOMAIN" --force --ecc 2>&1
    ~/.acme.sh/acme.sh --installcert -d "$DOMAIN" --fullchainpath /etc/xray/xray.crt --keypath /etc/xray/xray.key --ecc
    systemctl restart nginx
    echo -e "${GREEN}Certificate renewed${NC}"
else
    echo -e "${RED}acme.sh not installed${NC}"
fi
