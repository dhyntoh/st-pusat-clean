#!/bin/bash
NC='\033[0m'; GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'
NOW=$(date +%s)
echo -e "${CYAN}━━━━ ALL USERS ━━━━${NC}"
for proto in vmess vless trojan shadowsocks; do
    db="/etc/$proto/.$proto.db"
    [[ ! -f "$db" ]] && continue
    count=$(grep -c "^###\|^#&\|^#!\|^#@" "$db" 2>/dev/null || echo 0)
    echo -e "${YELLOW}${proto^}:${NC} $count users"
    grep "^" "$db" 2>/dev/null | while IFS=' ' read -r mark user exp rest; do
        [[ "$mark" != "###" && "$mark" != "#&" && "$mark" != "#!" && "$mark" != "#@" ]] && continue
        exp_sec=$(date -d "$exp" +%s 2>/dev/null)
        remain=$(( (exp_sec - NOW) / 86400 ))
        [[ $remain -lt 0 ]] && echo "  ${RED}$user (EXPIRED)${NC}" || echo "  ${GREEN}$user${NC} - ${remain}d left"
    done
done
echo ""; echo -e "${YELLOW}SSH users:${NC}"
awk -F: '$3>=1000 && $7~/\/(false|nologin)/ {print "  " $1}' /etc/passwd | grep -v "nobody"
