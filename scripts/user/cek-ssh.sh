#!/bin/bash
NC='\033[0m'; GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'
echo -e "${GREEN}━━━━ SSH USERS ━━━━${NC}"
printf "%-15s %-15s %-10s\n" "USERNAME" "EXPIRY" "STATUS"
awk -F: '$3>=1000 && $7~/\/(false|nologin)/ {print $1}' /etc/passwd | grep -v "nobody" | while IFS= read -r user; do
    exp=$(chage -l "$user" 2>/dev/null | grep "Account expires" | cut -d: -f2 | sed 's/^ //')
    if [[ -z "$exp" || "$exp" == "never" ]]; then
        echo "  $user  -  ${GREEN}ACTIVE${NC}"
    else
        remain=$(( ($(date -d "$exp" +%s) - $(date +%s)) / 86400 ))
        [[ $remain -lt 0 ]] && echo "  $user  $exp  ${RED}EXPIRED${NC}" || echo "  $user  $exp  ${GREEN}${remain}d${NC}"
    fi
done
