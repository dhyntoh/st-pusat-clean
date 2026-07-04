#!/bin/bash
source /etc/st-pusat/lib/colors.sh 2>/dev/null || NC='\033[0m'; RED='\033[0;31m'; GREEN='\033[0;32m'
echo -e "${GREEN}Current SSH users:${NC}"
awk -F: '$3>=1000 && $7~/\/(false|nologin)/ {print "  " $1}' /etc/passwd | grep -v "nobody"
read -p "Username: " user
id "$user" &>/dev/null || { echo -e "${RED}Not found${NC}"; exit 1; }
userdel -f "$user" 2>/dev/null
sed -i "/^### $user /d" /etc/ssh/.ssh.db
echo -e "${GREEN}Deleted${NC}"
