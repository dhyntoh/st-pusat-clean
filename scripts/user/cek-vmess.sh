#!/bin/bash
# List VMess users
DB="/etc/vmess/.vmess.db"
XRAY_CONFIG="/etc/xray/config.json"

echo -e "${GREEN}━━━━ VMESS USERS ━━━━${NC}"
printf "%-15s %-15s %-36s %-8s %-10s\n" "USERNAME" "EXPIRY" "UUID" "QUOTA" "LIMIT IP"
echo "──────────────────────────────────────────────────────────────"

grep "^### " "$DB" 2>/dev/null | while IFS=' ' read -r mark user exp uuid quota limit_ip created; do
    remaining=$(( ($(date -d "$exp" +%s) - $(date +%s)) / 86400 ))
    [[ $remaining -lt 0 ]] && status="${RED}EXPIRED${NC}" || status="${GREEN}${remaining}d${NC}"
    printf "%-15s %-15s %-36s %-8s %-10s\n" "$user" "$exp" "${uuid:0:8}..." "${quota}GB" "$limit_ip"
done

echo ""
echo -e "${YELLOW}Total: $(grep -c "^### " "$DB" 2>/dev/null || echo 0) users${NC}"
