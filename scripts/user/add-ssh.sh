#!/bin/bash
# Add SSH user
source /etc/st-pusat/lib/colors.sh 2>/dev/null || NC='\033[0m'; GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'

read -p "Username: " user
read -p "Password: " pass
read -p "Expiry (days): " exp_days

[[ -z "$user" || -z "$pass" || -z "$exp_days" ]] && { echo "Invalid input"; exit 1; }

id -u "$user" &>/dev/null && { echo -e "${RED}User exists${NC}"; exit 1; }

EXP=$(date -d "+${exp_days} days" +"%Y-%m-%d")

useradd -e "$(date -d "$EXP" +%Y-%m-%d)" -s /bin/false -M "$user" 2>/dev/null
echo -e "$pass\n$pass" | passwd "$user" 2>/dev/null

echo "### $user $EXP $pass" >> /etc/ssh/.ssh.db

echo -e "${GREEN}━━━━ SSH USER CREATED ━━━━${NC}"
echo "Username : $user"
echo "Password : $pass"
echo "Expiry   : $EXP"
echo "Ports    : 22, 2222, 2223 (SSH)"
echo "          : 109, 143 (Dropbear)"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
